'use client'

import MuxUploader from '@mux/mux-uploader-react'
import { useState } from 'react'
import { Button } from '@/components/ui/button'

interface VideoUploaderProps {
  onUploadComplete: (uploadId: string) => void
  currentAssetId?: string | null
}

type Status = 'idle' | 'ready' | 'uploading' | 'complete'

export function VideoUploader({ onUploadComplete, currentAssetId }: VideoUploaderProps) {
  const [uploadUrl, setUploadUrl] = useState<string | null>(null)
  const [uploadId, setUploadId] = useState<string | null>(null)
  const [status, setStatus] = useState<Status>('idle')
  const [error, setError] = useState<string | null>(null)

  async function initUpload() {
    setError(null)
    setStatus('ready')
    try {
      const res = await fetch('/api/mux-upload', { method: 'POST' })
      if (!res.ok) {
        throw new Error('Failed to get upload URL')
      }
      const { uploadId: uid, url } = await res.json()
      setUploadId(uid)
      setUploadUrl(url)
    } catch (err) {
      setError('Failed to initialise upload. Please try again.')
      setStatus('idle')
    }
  }

  return (
    <div className="space-y-2">
      <p className="text-sm font-medium text-slate-700">Video</p>

      {currentAssetId && status === 'idle' && (
        <div className="flex items-center gap-3 text-sm text-slate-600">
          <span>Current video: {currentAssetId}</span>
          <Button type="button" variant="outline" size="sm" onClick={initUpload}>
            Replace
          </Button>
        </div>
      )}

      {!currentAssetId && status === 'idle' && (
        <Button type="button" variant="outline" size="sm" onClick={initUpload}>
          Upload Video
        </Button>
      )}

      {status === 'ready' && !uploadUrl && (
        <p className="text-sm text-slate-500">Preparing upload...</p>
      )}

      {uploadUrl && status !== 'complete' && (
        <MuxUploader
          endpoint={uploadUrl}
          onUploadStart={() => setStatus('uploading')}
          onSuccess={() => {
            setStatus('complete')
            if (uploadId) onUploadComplete(uploadId)
          }}
          onError={() => {
            setError('Upload failed. Please try again.')
            setStatus('idle')
            setUploadUrl(null)
            setUploadId(null)
          }}
        />
      )}

      {status === 'complete' && (
        <p className="text-sm text-green-600 font-medium">Upload complete — processing</p>
      )}

      {error && <p className="text-sm text-red-600">{error}</p>}
    </div>
  )
}
