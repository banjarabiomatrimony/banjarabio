// Create Razorpay Order - Server-side order creation for secure checkout.
// Required: RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET in Supabase project secrets.
// Deploy: supabase functions deploy create-razorpay-order

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Not authenticated' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const body = await req.json()
    const amount = body.amount
    const planType = body.plan_type ?? 'biodata_unlock'
    const currency = body.currency ?? 'INR'
    const appSlug = body.app_slug ?? 'banjara'

    if (!amount || typeof amount !== 'number' || amount < 100) {
      return new Response(
        JSON.stringify({ error: 'Invalid amount (min 100 paise)' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const keyId = Deno.env.get('RAZORPAY_KEY_ID')
    const keySecret = Deno.env.get('RAZORPAY_KEY_SECRET')
    if (!keyId || !keySecret) {
      return new Response(
        JSON.stringify({ error: 'Razorpay secrets not configured' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const receipt = `${appSlug}_${user.id.slice(0, 8)}_${Date.now()}`
    // Razorpay notes: keys and values must be strings. Webhook reads user_id, plan_type.
    const orderPayload = {
      amount,
      currency,
      receipt,
      notes: {
        user_id: String(user.id),
        plan_type: String(planType),
        app: String(body.app_name ?? appSlug),
      },
    }

    const auth = btoa(`${keyId}:${keySecret}`)
    const razorpayRes = await fetch('https://api.razorpay.com/v1/orders', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Basic ${auth}`,
      },
      body: JSON.stringify(orderPayload),
    })

    if (!razorpayRes.ok) {
      const errText = await razorpayRes.text()
      console.error('Razorpay order creation failed:', razorpayRes.status, errText)
      return new Response(
        JSON.stringify({ error: 'Failed to create Razorpay order', details: errText }),
        { status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const orderData = await razorpayRes.json()
    return new Response(
      JSON.stringify({ id: orderData.id, amount, currency, plan_type: planType }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (e) {
    console.error('create-razorpay-order error:', e)
    return new Response(
      JSON.stringify({ error: String(e) }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
