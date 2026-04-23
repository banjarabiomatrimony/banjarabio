/**
 * Brevo (formerly Sendinblue) Email Provider
 * Free tier: 300 emails/day
 * Docs: https://developers.brevo.com/docs/send-a-transactional-email
 */

export interface EmailPayload {
  to: string[];
  subject: string;
  html: string;
  from?: string;
  fromName?: string;
}

export interface SendResult {
  success: boolean;
  provider: string;
  messageId?: string;
  error?: string;
  quotaExceeded?: boolean;
}

export async function sendViaBrevo(payload: EmailPayload): Promise<SendResult> {
  const apiKey = Deno.env.get('BREVO_API_KEY');
  if (!apiKey) {
    return { success: false, provider: 'brevo', error: 'BREVO_API_KEY not set', quotaExceeded: false };
  }

  try {
    const response = await fetch('https://api.brevo.com/v3/smtp/email', {
      method: 'POST',
      headers: {
        'accept': 'application/json',
        'api-key': apiKey,
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        sender: {
          name: payload.fromName ?? 'BanjaraBio',
          email: payload.from ?? 'noreply@banjarabio.com',
        },
        to: payload.to.map((email) => ({ email })),
        subject: payload.subject,
        htmlContent: payload.html,
      }),
    });

    if (response.status === 429 || response.status === 402) {
      return { success: false, provider: 'brevo', error: 'Quota exceeded', quotaExceeded: true };
    }

    if (!response.ok) {
      const errorBody = await response.text();
      return { success: false, provider: 'brevo', error: `HTTP ${response.status}: ${errorBody}`, quotaExceeded: false };
    }

    const data = await response.json();
    return {
      success: true,
      provider: 'brevo',
      messageId: data.messageId ?? data.messageIds?.[0],
    };
  } catch (error) {
    return { success: false, provider: 'brevo', error: (error as Error).message, quotaExceeded: false };
  }
}
