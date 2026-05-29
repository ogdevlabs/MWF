'use client'

import { useRef, useState } from 'react'
import { uploadAsset } from '@/app/actions/exercises'
import { Button } from '@/components/ui/button'

interface GlbUploaderProps {
  exerciseId: string
  programId: string
  currentPath?: string | null
  onUploadComplete: (path: string) => void
}

type Status = 'idle' | 'uploading' | 'complete' | 'error'

export function GlbUploader({
  exerciseId,
  programId,
  currentPath,
  onUploadComplete,
}: GlbUploaderProps) {
  const inputRef = useRef<HTMLInputElement>(null)
  const [status, setStatus] = useState<Status>('idle')
  const [error, setError] = useState<string | null>(null)

  async function handleFileChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0]
    if (!file) return

    setStatus('uploading')
    setError(null)

    const formData = new FormData()
    formData.append('file', file)
    formData.append('type', 'glb')
    formData.append('programId', programId)
    formData.append('exerciseId', exerciseId)

    const result = await uploadAsset(formData)

    if (result.error || !result.path) {
      setError(result.error ?? 'Upload failed')
      setStatus('error')
      return
    }

    setStatus('complete')
    onUploadComplete(result.path)
  }

  const filename = currentPath ? currentPath.split('/').pop() : null

  return (
    <div className="space-y-2">
      <p className="text-sm font-medium text-slate-700">3D Model (GLB)</p>

      {filename && status === 'idle' && (
        <div className="flex items-center gap-3 text-sm text-slate-600">
          <span>Current: {filename}</span>
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={() => inputRef.current?.click()}
          >
            Replace
          </Button>
        </div>
      )}

      {!filename && status === 'idle' && (
        <Button
          type="button"
          variant="outline"
          size="sm"
          onClick={() => inputRef.current?.click()}
        >
          Upload GLB
        </Button>
      )}

      <input
        ref={inputRef}
        type="file"
        accept=".glb,.gltf"
        className="hidden"
        onChange={handleFileChange}
      />

      {status === 'uploading' && (
        <p className="text-sm text-slate-500">Uploading...</p>
      )}

      {status === 'complete' && (
        <p className="text-sm text-green-600 font-medium">Upload complete</p>
      )}

      {status === 'error' && error && (
        <p className="text-sm text-red-600">{error}</p>
      )}
    </div>
  )
}
