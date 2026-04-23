import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  try {
    // 1. Get districts with new profiles in the last 7 days
    const sevenDaysAgo = new Date()
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7)

    const { data: newProfiles, error: profileError } = await supabase
      .from('profiles')
      .select('district')
      .gt('created_at', sevenDaysAgo.toISOString())
      .not('district', 'is', null)

    if (profileError) throw profileError

    // Find unique districts with new members
    const activeDistricts = [...new Set(newProfiles.map(p => p.district))]

    // 2. Find users in those districts to notify
    const results = []

    if (activeDistricts.length > 0) {
      const { data: usersToNotify, error: userError } = await supabase
        .from('profiles')
        .select('id, user_id, fcm_token, district')
        .in('district', activeDistricts)
        .not('fcm_token', 'is', null)

      if (userError) throw userError

      for (const user of usersToNotify) {
        // QUALITATIVE: Instead of showing "12 families", we say "New families" or "The community is growing"
        await supabase.functions.invoke('send-push-notification', {
          body: {
            fcm_token: user.fcm_token,
            title: 'Community Milestone! 📍',
            body: `Several new Banjara families from ${user.district} joined this week. Welcome them to the community!`,
            data: {
              type: 'community_milestone',
              district: user.district,
              route: '/home_screen'
            }
          }
        })
        results.push(user.user_id)
      }
    }

    return new Response(JSON.stringify({ processed: results.length, districts: activeDistricts }), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})
