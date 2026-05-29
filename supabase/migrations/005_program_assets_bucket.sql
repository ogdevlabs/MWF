INSERT INTO storage.buckets (id, name, public)
VALUES ('program-assets', 'program-assets', false)
ON CONFLICT (id) DO NOTHING;

-- Coach (service role) can upload thumbnails and GLB assets
CREATE POLICY "Service role can upload program assets"
ON storage.objects FOR INSERT
TO service_role
WITH CHECK (bucket_id = 'program-assets');

-- Authenticated users (students) can read thumbnails and GLB assets
CREATE POLICY "Authenticated users can read program assets"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'program-assets');

-- Service role can update and delete program assets (e.g. when replacing a thumbnail)
CREATE POLICY "Service role can manage program assets"
ON storage.objects FOR ALL
TO service_role
USING (bucket_id = 'program-assets');
