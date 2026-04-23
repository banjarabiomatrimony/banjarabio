import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  try {
    // 1. Get all users with FCM tokens
    const { data: users, error: userError } = await supabase
      .from('profiles')
      .select('id, user_id, fcm_token, gender')
      .not('fcm_token', 'is', null)
      .eq('is_active', true)

    if (userError) throw userError

    const results = []

    for (const user of users) {
      // 2. Find 3 potential matches (opposite gender, recently updated)
      const oppositeGender = user.gender === 'Male' ? 'Female' : 'Male'
      
      const { data: matches, error: matchError } = await supabase
        .from('profiles')
        .select('id, full_name, district')
        .eq('gender', oppositeGender)
        .eq('is_active', true)
        .order('updated_at', { ascending: false })
        .limit(3)

      if (matchError || !matches || matches.length === 0) continue

      // 3. Trigger notification
      const { data: notifyData, error: notifyError } = await supabase.functions.invoke('send-push-notification', {
        body: {
          fcm_token: user.fcm_token,
          title: 'Your Daily Match Picks 🌟',
          body: `We found ${matches.length} profiles matching your preferences. Tap to see them!`,
          data: {
            type: 'daily_match_pick',
            route: '/home_screen' // or a specific "Discover" tab
          }
        }
      })

      results.push({ user_id: user.user_id, status: notifyError ? 'failed' : 'sent' })
    }

    return new Response(JSON.stringify({ processed: results.length, results }), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})
