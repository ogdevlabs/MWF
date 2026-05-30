-- Migration 006: Storage buckets for exercise 3D models and program thumbnails
--
-- exercise-models: public read — GLB files served directly to Flutter app
-- program-thumbnails: public read — cover images served directly to Flutter app
--
-- feedback-photos (authenticated) and program-assets (authenticated) are in earlier migrations.

INSERT INTO storage.buckets (id, name, public)
VALUES ('exercise-models', 'exercise-models', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('program-thumbnails', 'program-thumbnails', true)
ON CONFLICT (id) DO NOTHING;

-- exercise-models: coach uploads, public read
CREATE POLICY "Coach uploads exercise models"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'exercise-models');

CREATE POLICY "Public reads exercise models"
ON storage.objects FOR SELECT
USING (bucket_id = 'exercise-models');

CREATE POLICY "Coach deletes exercise models"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'exercise-models');

-- program-thumbnails: coach uploads, public read
CREATE POLICY "Coach uploads program thumbnails"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'program-thumbnails');

CREATE POLICY "Public reads program thumbnails"
ON storage.objects FOR SELECT
USING (bucket_id = 'program-thumbnails');

CREATE POLICY "Coach deletes program thumbnails"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'program-thumbnails');
