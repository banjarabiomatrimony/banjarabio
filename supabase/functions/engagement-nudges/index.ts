import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  const { type } = await req.json()

  try {
    let results = []

    if (type === 'sunday_fomo') {
      const { data: users, error } = await supabase
        .from('profiles')
        .select('user_id, fcm_token')
        .not('fcm_token', 'is', null)
        .eq('is_active', true)

      if (error) throw error

      for (const user of users) {
        await supabase.functions.invoke('send-push-notification', {
          body: {
            fcm_token: user.fcm_token,
            title: "Busiest day of the week! 🔍",
            body: "The community is very active right now. Your perfect match might be online. Tap to explore!",
            data: { type: 'sunday_fomo', route: '/home_screen' }
          }
        })
        results.push(user.user_id)
      }
    } 
    
    else if (type === 'mummy_nudge') {
      const threeDaysAgo = new Date()
      threeDaysAgo.setDate(threeDaysAgo.getDate() - 3)

      const { data: users, error } = await supabase
        .from('profiles')
        .select('user_id, fcm_token')
        .lt('last_seen', threeDaysAgo.toISOString()) 
        .not('fcm_token', 'is', null)

      if (error) throw error

      for (const user of users) {
        await supabase.functions.invoke('send-push-notification', {
          body: {
            fcm_token: user.fcm_token,
            title: "Mummy is asking... 🤫",
            body: "\"Beta, any news?\" Tell her the community is growing with many new families today. Tap to see them!",
            data: { type: 'mummy_nudge', route: '/home_screen' }
          }
        })
        results.push(user.user_id)
      }
    }

    else if (type === 'profile_completion') {
      const { data: users, error } = await supabase
        .from('profiles')
        .select('user_id, fcm_token, gotra')
        .is('gotra', null)
        .not('fcm_token', 'is', null)

      if (error) throw error

      for (const user of users) {
        await supabase.functions.invoke('send-push-notification', {
          body: {
            fcm_token: user.fcm_token,
            title: "The missing piece... 🧩",
            body: "Profiles with full details get much more interest. Add your Gotra and photos now to unlock better matches!",
            data: { type: 'profile_completion', route: '/profile_form' }
          }
        })
        results.push(user.user_id)
      }
    }

    else if (type === 'biodata_perfection') {
      // Phase 9: Validation for high-completion profiles
      const { data: users, error } = await supabase
        .from('profiles')
        .select('user_id, fcm_token')
        .not('gotra', 'is', null)
        .not('district', 'is', null)
        .not('fcm_token', 'is', null)
        .limit(100) // Quality subset

      if (error) throw error

      for (const user of users) {
        await supabase.functions.invoke('send-push-notification', {
          body: {
            fcm_token: user.fcm_token,
            title: "Looking Sharp! ✨",
            body: "Your biodata looks professional and premium. This is exactly what families look for. Ready to explore new matches today?",
            data: { type: 'biodata_perfection', route: '/home_screen' }
          }
        })
        results.push(user.user_id)
      }
    }

    else if (type === 'social_proof') {
      // Phase 9: General community activity proof
      const { data: users, error } = await supabase
        .from('profiles')
        .select('user_id, fcm_token')
        .not('fcm_token', 'is', null)
        .limit(100)

      if (error) throw error

      for (const user of users) {
        await supabase.functions.invoke('send-push-notification', {
          body: {
            fcm_token: user.fcm_token,
            title: "Conversations are blooming! 💬",
            body: "The community is busy connecting today. Many families are already in talks. Jump in and say hello!",
            data: { type: 'social_proof', route: '/chat_list' }
          }
        })
        results.push(user.user_id)
      }
    }

    else if (type === 'marriage_season') {
      // Phase 9: Seasonal FOMO
      const { data: users, error } = await supabase
        .from('profiles')
        .select('user_id, fcm_token')
        .not('fcm_token', 'is', null)

      if (error) throw error

      for (const user of users) {
        await supabase.functions.invoke('send-push-notification', {
          body: {
            fcm_token: user.fcm_token,
            title: "Marriage season is here! 🎺",
            body: "Activity is surging on BanjaraBio right now. It's the perfect time to find your life partner. Don't let this season pass!",
            data: { type: 'marriage_season', route: '/home_screen' }
          }
        })
        results.push(user.user_id)
      }
    }

    else if (type === 'daily_reward_reminder') {
      const { data: users, error } = await supabase
        .from('profiles')
        .select('user_id, fcm_token')
        .not('fcm_token', 'is', null)

      if (error) throw error

      for (const user of users) {
        await supabase.functions.invoke('send-push-notification', {
          body: {
            fcm_token: user.fcm_token,
            title: "Your Daily Reward is waiting! 🎁",
            body: "Don't break your streak! Open the app now to claim your free profile views, bookmarks, or messages. Jackpot is on Day 7!",
            data: { type: 'daily_reward', route: '/home_screen' }
          }
        })
        results.push(user.user_id)
      }
    }

    return new Response(JSON.stringify({ type, count: results.length }), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: (error as Error).message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})
