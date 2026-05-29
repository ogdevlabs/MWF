INSERT INTO storage.buckets (id, name, public)
VALUES ('feedback-photos', 'feedback-photos', false)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Students upload own feedback photos"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'feedback-photos' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Students read own feedback photos"
ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'feedback-photos' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Coach reads all feedback photos"
ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'feedback-photos');
