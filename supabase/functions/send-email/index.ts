/**
 * 📧 Smart Email Dispatcher — BanjaraBio
 *
 * Rotates between 3 free email providers to maximize daily capacity:
 *   1. Brevo   → 300/day (Priority 1)
 *   2. Resend  → ~100/day (Priority 2)
 *   3. SendGrid → 100/day (Priority 3)
 *
 * Total free capacity: ~500 emails/day
 *
 * Called internally by:
 *   - pg_cron scheduled jobs (daily picks, weekly digest)
 *   - Database webhook triggers (new match, new interest)
 *   - Other Edge Functions
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { sendViaBrevo } from './providers/brevo.ts'
import type { EmailPayload, SendResult } from './providers/brevo.ts'
import { sendViaResend } from './providers/resend.ts'
import { sendViaSendGrid } from './providers/sendgrid.ts'

// Provider priority order (highest free quota first)
const providers = [
  { name: 'brevo', send: sendViaBrevo },
  { name: 'resend', send: sendViaResend },
  { name: 'sendgrid', send: sendViaSendGrid },
]

/**
 * Smart dispatcher: tries each provider in order.
 * If a provider's quota is exceeded, falls through to the next one.
 */
async function dispatchEmail(payload: EmailPayload): Promise<SendResult> {
  for (const provider of providers) {
    const result = await provider.send(payload)

    if (result.success) {
      console.log(`✅ Email sent via ${provider.name}: ${result.messageId}`)
      return result
    }

    if (result.quotaExceeded) {
      console.warn(`⚠️ ${provider.name} quota exceeded, trying next provider...`)
      continue
    }

    // Non-quota error — log but still try next provider
    console.error(`❌ ${provider.name} failed: ${result.error}`)
  }

  return {
    success: false,
    provider: 'none',
    error: 'All email providers exhausted or unavailable',
    quotaExceeded: true,
  }
}

// ─── HTML Email Templates ────────────────────────────────────────────────────

function buildEmailHtml(title: string, bodyContent: string, ctaText?: string, ctaUrl?: string): string {
  const ctaButton = ctaText && ctaUrl
    ? `<a href="${ctaUrl}" style="display:inline-block;padding:14px 28px;background:linear-gradient(135deg,#FF6B35,#F7931E);color:#fff;text-decoration:none;border-radius:8px;font-weight:bold;margin-top:20px;">${ctaText}</a>`
    : ''

  return `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
<body style="margin:0;padding:0;background:#f4f0eb;font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;">
  <div style="max-width:600px;margin:20px auto;background:#fff;border-radius:16px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,0.08);">
    <div style="background:linear-gradient(135deg,#8B1A1A,#C0392B);padding:30px;text-align:center;">
      <h1 style="color:#fff;margin:0;font-size:24px;">🪷 BanjaraBio</h1>
      <p style="color:rgba(255,255,255,0.8);margin:5px 0 0;font-size:14px;">Your Trusted Matrimony Community</p>
    </div>
    <div style="padding:30px;">
      <h2 style="color:#8B1A1A;margin-top:0;font-size:20px;">${title}</h2>
      <div style="color:#333;font-size:15px;line-height:1.6;">${bodyContent}</div>
      <div style="text-align:center;margin-top:24px;">${ctaButton}</div>
    </div>
    <div style="background:#f9f6f2;padding:20px;text-align:center;font-size:12px;color:#888;">
      <p style="margin:0;">BanjaraBio Matrimony • Finding your perfect match</p>
      <p style="margin:5px 0 0;"><a href="https://banjarabio.com/unsubscribe" style="color:#8B1A1A;">Unsubscribe</a></p>
    </div>
  </div>
</body>
</html>`
}

const templates: Record<string, (data: Record<string, unknown>) => { subject: string; html: string }> = {
  // ── Real-time triggers ──
  new_match: (data) => ({
    subject: `🎉 It's a Match! ${data.matchName} is interested in you`,
    html: buildEmailHtml(
      "It's a Match! 🎉",
      `<p>Great news! <strong>${data.matchName}</strong> from <strong>${data.matchDistrict ?? 'your community'}</strong> has also shown interest in your profile.</p>
       <p>This is a mutual connection — both of you are interested! Don't keep them waiting.</p>`,
      'View Your Match', 'https://banjarabio.com/app'
    ),
  }),

  new_interest: (data) => ({
    subject: `❤️ Someone bookmarked your profile on BanjaraBio`,
    html: buildEmailHtml(
      'Someone is interested in you! ❤️',
      `<p>A family member just saved your profile to their favorites list on BanjaraBio.</p>
       <p>Open the app to see who it is and explore their profile in return.</p>`,
      'See Who It Is', 'https://banjarabio.com/app'
    ),
  }),

  // ── Scheduled triggers ──
  daily_recommendation: (data) => ({
    subject: `🌟 Your Daily Match Picks are ready`,
    html: buildEmailHtml(
      'Your Daily Match Picks 🌟',
      `<p>We've handpicked <strong>${data.matchCount ?? 3} profiles</strong> that align with your preferences today.</p>
       <p>Fresh faces are joining the community daily. Check them out before others do!</p>`,
      'See Today\'s Picks', 'https://banjarabio.com/app'
    ),
  }),

  weekly_digest: (data) => ({
    subject: `📊 Your Weekly BanjaraBio Update`,
    html: buildEmailHtml(
      'Your Weekly Community Update 📊',
      `<p>Here's what happened in your community this week:</p>
       <ul style="padding-left:20px;">
         <li><strong>${data.newProfiles ?? 0}</strong> new profiles joined</li>
         <li><strong>${data.newInDistrict ?? 0}</strong> new members in your district</li>
         <li><strong>${data.viewsReceived ?? 0}</strong> people viewed your profile</li>
       </ul>
       <p>Stay active to get noticed by more families!</p>`,
      'Explore New Profiles', 'https://banjarabio.com/app'
    ),
  }),

  monthly_digest: (data) => ({
    subject: `📅 Your Monthly BanjaraBio Report`,
    html: buildEmailHtml(
      'Your Monthly Report 📅',
      `<p>Here's your month at a glance:</p>
       <ul style="padding-left:20px;">
         <li><strong>${data.totalNewProfiles ?? 0}</strong> profiles joined this month</li>
         <li><strong>${data.matchesCount ?? 0}</strong> new matches created</li>
         <li><strong>${data.bookmarksReceived ?? 0}</strong> families bookmarked your profile</li>
       </ul>
       <p>The community is growing fast — perfect time to find your match!</p>`,
      'Open BanjaraBio', 'https://banjarabio.com/app'
    ),
  }),

  new_local_profile: (data) => ({
    subject: `📍 New profile in ${data.district}!`,
    html: buildEmailHtml(
      `New Profile in ${data.district}! 📍`,
      `<p><strong>${data.profileName}</strong> just joined from <strong>${data.district}</strong>.</p>
       <p>Local matches are the most sought after. Be the first to connect!</p>`,
      'View Profile', 'https://banjarabio.com/app'
    ),
  }),

  special_offer: (data) => ({
    subject: `🎁 ${data.offerTitle ?? 'Special Offer'} on BanjaraBio`,
    html: buildEmailHtml(
      `${data.offerTitle ?? 'Special Offer'} 🎁`,
      `<p>${data.offerDescription ?? 'We have a special deal for you!'}</p>
       <p>This offer is valid until <strong>${data.expiresAt ?? 'limited time'}</strong>. Don't miss out!</p>`,
      'Claim Offer', 'https://banjarabio.com/app'
    ),
  }),
}

// ─── Preference column mapping ───────────────────────────────────────────────

const prefColumnMap: Record<string, string> = {
  daily_recommendation: 'daily_recommendations',
  weekly_digest: 'weekly_digest',
  monthly_digest: 'monthly_digest',
  new_match: 'match_alerts',
  new_interest: 'interest_alerts',
  new_local_profile: 'local_profiles',
  special_offer: 'offers',
}

// ─── Batch Processing (for pg_cron scheduled jobs) ───────────────────────────

async function handleBatch(
  type: string,
  supabase: ReturnType<typeof createClient>,
): Promise<{ sent: number; failed: number; skipped: number }> {
  const prefColumn = prefColumnMap[type]
  const stats = { sent: 0, failed: 0, skipped: 0 }

  // Get users with email who opted in to this type
  let query = supabase
    .from('profiles')
    .select('user_id, full_name, email, district, gender')
    .not('email', 'is', null)
    .eq('is_active', true)
    .limit(500) // Daily cap

  const { data: users, error } = await query
  if (error || !users) {
    console.error('Failed to fetch users for batch:', error?.message)
    return stats
  }

  // Get email preferences for opted-in users
  const userIds = users.map((u: { user_id: string }) => u.user_id)
  const { data: prefs } = prefColumn
    ? await supabase
        .from('email_preferences')
        .select('user_id')
        .in('user_id', userIds)
        .eq(prefColumn, true)
    : { data: userIds.map((id: string) => ({ user_id: id })) }

  const optedInUserIds = new Set((prefs ?? []).map((p: { user_id: string }) => p.user_id))

  // Compute aggregate stats for digest emails
  let weeklyStats: Record<string, unknown> = {}
  if (type === 'weekly_digest') {
    const weekAgo = new Date()
    weekAgo.setDate(weekAgo.getDate() - 7)
    const { count: newProfiles } = await supabase
      .from('profiles')
      .select('*', { count: 'exact', head: true })
      .gte('created_at', weekAgo.toISOString())
    weeklyStats = { newProfiles: newProfiles ?? 0 }
  } else if (type === 'monthly_digest') {
    const monthAgo = new Date()
    monthAgo.setMonth(monthAgo.getMonth() - 1)
    const { count: totalNewProfiles } = await supabase
      .from('profiles')
      .select('*', { count: 'exact', head: true })
      .gte('created_at', monthAgo.toISOString())
    const { count: matchesCount } = await supabase
      .from('profile_shares')
      .select('*', { count: 'exact', head: true })
      .eq('status', 'matched')
      .gte('updated_at', monthAgo.toISOString())
    weeklyStats = { totalNewProfiles: totalNewProfiles ?? 0, matchesCount: matchesCount ?? 0 }
  }

  for (const user of users) {
    if (!optedInUserIds.has(user.user_id)) {
      stats.skipped++
      continue
    }
    if (!user.email) {
      stats.skipped++
      continue
    }

    const template = templates[type]
    if (!template) { stats.skipped++; continue }

    const emailData = { ...weeklyStats, district: user.district, profileName: user.full_name }
    const { subject, html } = template(emailData)

    const result = await dispatchEmail({ to: [user.email], subject, html })

    // Log each email
    try {
      await supabase.from('email_logs').insert({
        email_type: type,
        recipients: [user.email],
        provider: result.provider,
        success: result.success,
        message_id: result.messageId,
        error: result.error,
      })
    } catch (_) { /* non-critical */ }

    if (result.success) {
      stats.sent++
    } else {
      stats.failed++
      if (result.quotaExceeded) {
        console.warn(`📛 All providers exhausted after ${stats.sent} emails. Stopping batch.`)
        break
      }
    }
  }

  return stats
}

// ─── Main Handler ────────────────────────────────────────────────────────────

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  try {
    const { type, to, data } = await req.json() as {
      type: string
      to: string | string[]
      data?: Record<string, unknown>
    }

    if (!type || !to) {
      return new Response(JSON.stringify({ error: 'Missing required fields: type, to' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // ── Batch mode (called by pg_cron) ──
    if (to === 'batch') {
      const stats = await handleBatch(type, supabase)
      return new Response(JSON.stringify({ mode: 'batch', type, ...stats }), {
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // ── Single/direct email mode ──
    const template = templates[type]
    if (!template) {
      return new Response(JSON.stringify({ error: `Unknown email type: ${type}` }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    const { subject, html } = template(data ?? {})
    const recipients = Array.isArray(to) ? to : [to]

    const result = await dispatchEmail({ to: recipients, subject, html })

    // Log to database
    try {
      await supabase.from('email_logs').insert({
        email_type: type,
        recipients,
        provider: result.provider,
        success: result.success,
        message_id: result.messageId,
        error: result.error,
      })
    } catch (_) { /* non-critical */ }

    return new Response(JSON.stringify(result), {
      status: result.success ? 200 : 502,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: (error as Error).message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})
