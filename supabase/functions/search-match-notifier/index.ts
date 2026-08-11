import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * search-match-notifier
 * 
 * Sends push notifications to Search Users (relatives browsing for candidates)
 * when new profiles match their browse intents.
 * 
 * Triggered every 3 days via pg_cron + pg_net.
 * 
 * Flow:
 * 1. Query user_browse_intents for users not notified in last 3 days
 * 2. Find new profiles matching their intent (gender, district)
 * 3. Send FCM push via the existing send-push-notification Edge Function
 * 4. Log the notification to prevent duplicate sends
 */

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS")
    return new Response("ok", { headers: corsHeaders });

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  const supabase = createClient(supabaseUrl, supabaseServiceKey);

  const firebaseProject = Deno.env.get("FIREBASE_PROJECT_ID");
  const serviceAccount = JSON.parse(
    Deno.env.get("FIREBASE_SERVICE_ACCOUNT") || "{}",
  );

  try {
    // ─── STEP 1: Find eligible users with browse intents ───
    // Users who:
    // - Logged a browse intent in the last 60 days
    // - Haven't received a match notification in the last 3 days
    // - Have a valid FCM token in user_devices
    const { data: eligibleUsers, error: queryError } = await supabase.rpc(
      "fn_get_search_match_candidates",
      { p_notify_interval_days: 3, p_limit: 100 },
    );

    if (queryError) {
      console.error("Query error:", queryError);
      return new Response(
        JSON.stringify({ error: "Failed to query eligible users", details: queryError }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    if (!eligibleUsers || eligibleUsers.length === 0) {
      return new Response(
        JSON.stringify({ message: "No eligible users to notify", sent: 0 }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    console.log(`Found ${eligibleUsers.length} eligible users for match notifications`);

    // ─── STEP 2: Send FCM push to each eligible user ───
    let sentCount = 0;
    let failedCount = 0;
    let skippedCount = 0;

    // Get Firebase access token once for all sends
    let accessToken: string | null = null;
    if (firebaseProject && serviceAccount.client_email) {
      accessToken = await getAccessToken(serviceAccount);
    }

    for (const user of eligibleUsers) {
      if (!user.fcm_token || !accessToken) {
        skippedCount++;
        continue;
      }

      try {
        // Build localized notification
        const relationLabel = getRelationLabel(user.relation);
        const genderLabel = user.target_gender === "Female" ? "वधू" : "वर";
        const matchCount = user.match_count || 0;
        const districtLabel = user.district ? ` (${user.district})` : "";

        const title = `💕 ${matchCount} नवीन ${genderLabel} प्रोफाईल${districtLabel}`;
        const body = `तुमच्या ${relationLabel} साठी ${matchCount} नवीन प्रोफाईल आले आहेत. आताच पहा!`;

        const result = await sendFcm(
          firebaseProject!,
          accessToken,
          user.fcm_token,
          title,
          body,
          {
            event_type: "search_match_alert",
            category: "matchAlert",
            match_count: String(matchCount),
            target_gender: user.target_gender || "",
            district: user.district || "",
            route: "/home",
          },
        );

        if (result.ok) {
          sentCount++;

          // Log successful notification to prevent re-sending
          await supabase.from("search_match_notifications").insert({
            user_id: user.user_id,
            intent_id: user.intent_id,
            match_count: matchCount,
            status: "sent",
          });
        } else {
          failedCount++;
          const errBody = await result.text();
          console.error(`FCM failed for ${user.user_id}: ${errBody}`);
        }
      } catch (fcmErr) {
        failedCount++;
        console.error(`Error sending to ${user.user_id}:`, fcmErr);
      }
    }

    const summary = {
      message: `Processed ${eligibleUsers.length} users: sent=${sentCount}, failed=${failedCount}, skipped=${skippedCount}`,
      total: eligibleUsers.length,
      sent: sentCount,
      failed: failedCount,
      skipped: skippedCount,
    };

    console.log(summary.message);

    return new Response(JSON.stringify(summary), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Unhandled error:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

// ─── HELPERS ───

function getRelationLabel(relation: string | null): string {
  const labels: Record<string, string> = {
    son: "मुलासाठी",
    daughter: "मुलीसाठी",
    brother: "भावासाठी",
    sister: "बहिणीसाठी",
    relative: "नातेवाईकासाठी",
    self: "स्वतःसाठी",
  };
  return labels[relation || "relative"] || "नातेवाईकासाठी";
}

// ─── FCM SENDER ───

async function sendFcm(
  projectId: string,
  accessToken: string,
  token: string,
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<Response> {
  return fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data,
          android: {
            notification: {
              channel_id: "matches_channel",
              priority: "high",
              default_vibrate_timings: false,
              vibrate_timings: ["0s", "0.5s", "0.2s", "0.5s"],
            },
            priority: "high",
          },
        },
      }),
    },
  );
}

// ─── JWT / Auth Helpers ───

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
