'use server'

import { revalidatePath } from 'next/cache'
import { z } from 'zod'
import { createServiceClient } from '@/lib/supabase/service'

const ReplySchema = z.object({
  reply: z.string().min(1, 'Reply cannot be empty').max(2000),
})

export async function postCoachReply(
  threadId: string,
  prevState: unknown,
  formData: FormData
) {
  const raw = { reply: formData.get('reply') }
  const result = ReplySchema.safeParse(raw)

  if (!result.success) {
    return {
      errors: result.error.flatten().fieldErrors,
    }
  }

  const { reply } = result.data
  const supabase = createServiceClient()

  // Update the feedback thread with the coach reply
  const { data: thread, error } = await supabase
    .from('feedback_threads')
    .update({
      coach_reply: reply,
      replied_at: new Date().toISOString(),
      notification_sent: false,
    })
    .eq('id', threadId)
    .select('student_id')
    .single()

  if (error || !thread) {
    return { errors: { reply: ['Failed to save reply. Please try again.'] } }
  }

  // Fire FCM push notification via Supabase Edge Function
  try {
    await fetch(
      `${process.env.NEXT_PUBLIC_SUPABASE_URL}/functions/v1/send-fcm`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${process.env.SUPABASE_SERVICE_ROLE_KEY}`,
        },
        body: JSON.stringify({ threadId, studentId: thread.student_id }),
      }
    )
  } catch {
    // FCM failure is non-fatal — reply is already saved
    console.error('Failed to send FCM push notification for thread', threadId)
  }

  revalidatePath('/feedback')
  revalidatePath(`/feedback/${threadId}`)

  return { success: true }
}
