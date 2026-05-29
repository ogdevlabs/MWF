'use client'

import { useActionState } from 'react'
import { postCoachReply } from '@/app/actions/feedback'
import { Textarea } from '@/components/ui/textarea'
import { Button } from '@/components/ui/button'

interface Props {
  threadId: string
}

export function FeedbackReplyForm({ threadId }: Props) {
  const boundAction = postCoachReply.bind(null, threadId)
  const [state, action, pending] = useActionState(boundAction, undefined)

  if (state && 'success' in state && state.success) {
    return (
      <p className="text-green-700 font-medium">
        Reply sent! The student will be notified.
      </p>
    )
  }

  const fieldErrors =
    state && 'errors' in state ? (state.errors as Record<string, string[]>) : {}

  return (
    <form action={action} className="space-y-3">
      <Textarea
        name="reply"
        placeholder="Type your reply..."
        rows={5}
        disabled={pending}
        className="resize-none"
      />
      {fieldErrors?.reply && (
        <p className="text-sm text-red-600">{fieldErrors.reply[0]}</p>
      )}
      <Button type="submit" disabled={pending}>
        {pending ? 'Sending…' : 'Send reply'}
      </Button>
    </form>
  )
}
