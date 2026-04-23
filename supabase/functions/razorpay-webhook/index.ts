// Razorpay webhook – payment.captured fallback when client callback fails.
// Required: RAZORPAY_WEBHOOK_SECRET, RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET in Supabase secrets.
// Deploy: supabase functions deploy razorpay-webhook
// Configure in Razorpay Dashboard: Webhooks → Add → payment.captured → URL: https://<project>.supabase.co/functions/v1/razorpay-webhook

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-razorpay-signature',
}

async function verifyWebhookSignature(body: string, signature: string, secret: string): Promise<boolean> {
  const encoder = new TextEncoder()
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  )
  const sig = await crypto.subtle.sign('HMAC', key, encoder.encode(body))
  const hex = Array.from(new Uint8Array(sig)).map((b) => b.toString(16).padStart(2, '0')).join('')
  return hex === signature
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const webhookSecret = Deno.env.get('RAZORPAY_WEBHOOK_SECRET')
    const keyId = Deno.env.get('RAZORPAY_KEY_ID')
    const keySecret = Deno.env.get('RAZORPAY_KEY_SECRET')
    if (!webhookSecret || !keyId || !keySecret) {
      console.error('Razorpay webhook: missing RAZORPAY_WEBHOOK_SECRET, RAZORPAY_KEY_ID, or RAZORPAY_KEY_SECRET')
      return new Response(
        JSON.stringify({ error: 'Webhook not configured' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const signature = req.headers.get('X-Razorpay-Signature')
    if (!signature) {
      return new Response(
        JSON.stringify({ error: 'Missing X-Razorpay-Signature' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const rawBody = await req.text()
    const valid = await verifyWebhookSignature(rawBody, signature, webhookSecret)
    if (!valid) {
      return new Response(
        JSON.stringify({ error: 'Invalid signature' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const event = JSON.parse(rawBody)
    if (event.event !== 'payment.captured') {
      return new Response(
        JSON.stringify({ received: event.event }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const payment = event.payload?.payment?.entity
    if (!payment?.order_id || !payment?.id || !payment?.amount) {
      return new Response(
        JSON.stringify({ error: 'Invalid payment payload' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const orderId = payment.order_id
    const paymentId = payment.id
    const amount = payment.amount

    const auth = btoa(`${keyId}:${keySecret}`)
    const orderRes = await fetch(`https://api.razorpay.com/v1/orders/${orderId}`, {
      headers: { Authorization: `Basic ${auth}` },
    })
    if (!orderRes.ok) {
      console.error('Razorpay order fetch failed:', orderRes.status, await orderRes.text())
      return new Response(
        JSON.stringify({ error: 'Failed to fetch order' }),
        { status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const orderData = await orderRes.json()
    const notes = orderData.notes || {}
    const userId = notes.user_id
    const planType = notes.plan_type || 'biodata_unlock'
    const appSlug = notes.app || notes.app_slug || 'banjara'

    if (!userId) {
      console.error('Razorpay webhook: order missing user_id in notes', orderId)
      return new Response(
        JSON.stringify({ error: 'Order missing user_id' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { data, error } = await supabase.rpc('fn_webhook_razorpay_payment_captured', {
      p_user_id: userId,
      p_order_id: orderId,
      p_payment_id: paymentId,
      p_amount: amount,
      p_plan_type: planType,
      p_app_slug: appSlug,
    })

    if (error) {
      console.error('fn_webhook_razorpay_payment_captured error:', error)
      return new Response(
        JSON.stringify({ error: error.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ status: 'ok', result: data }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (e) {
    console.error('razorpay-webhook error:', e)
    return new Response(
      JSON.stringify({ error: String(e) }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
