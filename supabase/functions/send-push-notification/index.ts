import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface NotificationRequest {
  event_type: string;
  title: string;
  body: string;
  data?: Record<string, unknown>;
  triggered_by_user_id?: string;
  target_role?: string;      // 'admin' | 'staff' | 'user'
  target_user_id?: string;   // specific user (overrides target_role)
  // Legacy single-token mode (backward compatible)
  fcm_token?: string;
}

serve(async (req) => {
  if (req.method === "OPTIONS")
    return new Response("ok", { headers: corsHeaders });

  try {
    const payload: NotificationRequest = await req.json();
    const {
      event_type, title, body, data,
      triggered_by_user_id, target_role, target_user_id,
      fcm_token,
    } = payload;

    if (!title || !body) {
      return new Response(JSON.stringify({ error: "Missing required fields: title, body" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const firebaseProject = Deno.env.get("FIREBASE_PROJECT_ID");
    const serviceAccount = JSON.parse(
      Deno.env.get("FIREBASE_SERVICE_ACCOUNT") || "{}",
    );

    if (!firebaseProject || !serviceAccount.client_email) {
      return new Response(
        JSON.stringify({ error: "Firebase credentials not configured" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const accessToken = await getAccessToken(serviceAccount);
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Auto-sync real service_role_key to private.notification_settings for pg_cron
    try {
      await supabase.rpc("fn_sync_notification_service_key", { p_key: supabaseServiceKey });
    } catch (_err) {
      // Non-critical if RPC isn't deployed yet
    }

    // Determine FCM category for the notification
    const fcmCategory = target_role === "staff"
      ? "staffTask"
      : target_role === "admin"
      ? "adminAlert"
      : "general";

    // ---------------------------------------------------------------------------
    // Mode 1: Legacy single-token mode (backward compatible)
    // ---------------------------------------------------------------------------
    if (fcm_token) {
      const result = await sendFcm(
        firebaseProject, accessToken, fcm_token, title, body, { ...data, event_type, category: fcmCategory }
      );

      // Log
      await supabase.from("notification_log").insert({
        target_user_id: triggered_by_user_id,
        target_role: target_role || "user",
        event_type: event_type || "direct",
        title, body,
        data: data || {},
        delivery_status: result.ok ? "sent" : "failed",
        triggered_by_user_id: triggered_by_user_id,
      }).then(() => {});

      const fcmResult = await result.json();
      return new Response(JSON.stringify(fcmResult), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: result.status,
      });
    }

    // ---------------------------------------------------------------------------
    // Mode 2: Role-based multi-target dispatch
    // ---------------------------------------------------------------------------
    let query = supabase
      .from("profiles")
      .select("user_id, fcm_token, full_name")
      .not("fcm_token", "is", null);

    if (target_user_id) {
      query = query.eq("user_id", target_user_id);
    } else if (target_role) {
      query = query.eq("role", target_role);
    } else {
      query = query.eq("role", "admin");
    }

    let { data: targets, error: queryError } = await query;

    if (queryError) {
      return new Response(
        JSON.stringify({ error: "Failed to query targets", details: queryError }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Fallback: If targeting a specific user with no profile, check user_devices
    if (target_user_id && (!targets || targets.length === 0)) {
      const { data: deviceTargets } = await supabase
        .from("user_devices")
        .select("user_id, fcm_token")
        .eq("user_id", target_user_id)
        .not("fcm_token", "is", null);
      
      if (deviceTargets && deviceTargets.length > 0) {
        targets = deviceTargets.map(d => ({ ...d, full_name: null }));
      }
    }

    if (!targets || targets.length === 0) {
      return new Response(
        JSON.stringify({ message: "No targets found", sent: 0 }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Send to all targets
    let sentCount = 0;
    let failedCount = 0;
    const logEntries: Array<Record<string, unknown>> = [];

    for (const target of targets) {
      try {
        const result = await sendFcm(
          firebaseProject, accessToken, target.fcm_token!,
          title, body, { ...data, event_type, category: fcmCategory }
        );

        const status = result.ok ? "sent" : "failed";
        if (result.ok) sentCount++; else failedCount++;

        logEntries.push({
          target_user_id: target.user_id,
          target_role: target_role || "admin",
          event_type: event_type || "unknown",
          title, body,
          data: data || {},
          delivery_status: status,
          triggered_by_user_id: triggered_by_user_id || null,
        });
      } catch (fcmErr) {
        failedCount++;
        logEntries.push({
          target_user_id: target.user_id,
          target_role: target_role || "admin",
          event_type: event_type || "unknown",
          title, body,
          data: data || {},
          delivery_status: "failed",
          triggered_by_user_id: triggered_by_user_id || null,
        });
      }
    }

    // Batch insert logs (non-blocking)
    if (logEntries.length > 0) {
      await supabase.from("notification_log").insert(logEntries).then(() => {});
    }

    return new Response(
      JSON.stringify({
        message: `Sent ${sentCount}, failed ${failedCount}`,
        sent: sentCount,
        failed: failedCount,
        targets: targets.length,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});

// ---------------------------------------------------------------------------
// FCM Sender: Firebase HTTP v1 API
// ---------------------------------------------------------------------------
async function sendFcm(
  projectId: string, accessToken: string,
  token: string, title: string, body: string,
  data: Record<string, unknown>
): Promise<Response> {
  // Stringify all data values (FCM requires string values)
  const stringData: Record<string, string> = {};
  for (const [k, v] of Object.entries(data || {})) {
    stringData[k] = String(v ?? "");
  }

  const imageUrl = stringData.image_url || stringData.avatar_url || stringData.image;

  const messagePayload: Record<string, unknown> = {
    token,
    notification: {
      title,
      body,
      ...(imageUrl ? { image: imageUrl } : {}),
    },
    data: stringData,
    android: {
      notification: {
        channel_id: data.category === "staffTask" ? "staff_channel"
          : data.category === "adminAlert" ? "admin_channel"
          : "matches_channel",
        priority: "high",
        default_vibrate_timings: false,
        vibrate_timings: ["0s", "0.5s", "0.2s", "0.5s"],
        default_light_settings: false,
        light_settings: {
          color: { red: 0.788, green: 0.294, blue: 0.294, alpha: 1 },
          light_on_duration: "1s",
          light_off_duration: "0.5s",
        },
        ...(imageUrl ? { image: imageUrl } : {}),
      },
      priority: "high",
    },
    apns: {
      payload: {
        aps: {
          alert: { title, body },
          sound: "default",
          badge: 1,
          "content-available": 1,
        },
      },
      fcm_options: {
        ...(imageUrl ? { image: imageUrl } : {}),
      },
      headers: { "apns-priority": "10" },
    },
  };

  return fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({ message: messagePayload }),
    },
  );
}

// ---------------------------------------------------------------------------
// JWT / Auth Helpers (unchanged from original)
// ---------------------------------------------------------------------------
async function getAccessToken(serviceAccount: any): Promise<string> {
  const jwtHeader = b64url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const iat = Math.floor(Date.now() / 1000);
  const exp = iat + 3600;
  const jwtClaim = b64url(
    JSON.stringify({
      iss: serviceAccount.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      exp,
      iat,
    }),
  );

  const signatureInput = `${jwtHeader}.${jwtClaim}`;
  const privateKey = serviceAccount.private_key.replace(/\\n/g, "\n");
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToBinary(privateKey),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(signatureInput),
  );
  const jwt = `${signatureInput}.${b64urlUint8(new Uint8Array(signature))}`;

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });

  const { access_token } = await response.json();
  return access_token;
}

function b64url(str: string): string {
  return btoa(str).replace(/\+/g, "-").replace(/\//g, "_").replace(/=/g, "");
}

function b64urlUint8(bytes: Uint8Array): string {
  let binary = "";
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return b64url(binary);
}

function pemToBinary(pem: string): ArrayBuffer {
  const base64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}
