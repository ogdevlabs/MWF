'use client'

import { useState } from 'react'
import { uploadThumbnail } from '@/app/actions/programs'
import { Label } from '@/components/ui/label'

interface ThumbnailUploaderProps {
  programId: string
  currentThumbnailUrl?: string | null
}

export function ThumbnailUploader({
  programId,
  currentThumbnailUrl,
}: ThumbnailUploaderProps) {
  const [uploading, setUploading] = useState(false)
  const [previewUrl, setPreviewUrl] = useState<string | null>(
    currentThumbnailUrl
      ? `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public/program-assets/${currentThumbnailUrl}`
      : null
  )

  async function handleFileChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0]
    if (!file) return

    setUploading(true)
    try {
      const formData = new FormData()
      formData.append('file', file)
      const result = await uploadThumbnail(programId, formData)
      if (result.success && result.path) {
        setPreviewUrl(
          `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public/program-assets/${result.path}`
        )
      }
    } finally {
      setUploading(false)
    }
  }

  return (
    <div className="space-y-2">
      <Label>Program Thumbnail</Label>
      {previewUrl && (
        // eslint-disable-next-line @next/next/no-img-element
        <img
          src={previewUrl}
          alt="Program thumbnail"
          className="w-48 h-32 object-cover rounded-md border"
        />
      )}
      <input
        type="file"
        accept="image/*"
        onChange={handleFileChange}
        disabled={uploading}
        className="block text-sm text-slate-500 file:mr-4 file:py-1 file:px-3 file:rounded-md file:border-0 file:text-sm file:font-medium file:bg-slate-100 file:text-slate-700 hover:file:bg-slate-200 disabled:opacity-50"
      />
      {uploading && (
        <p className="text-sm text-slate-500">Uploading...</p>
      )}
    </div>
  )
}
