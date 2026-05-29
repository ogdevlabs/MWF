-- Add FCM token column for push notification delivery
ALTER TABLE students ADD COLUMN fcm_token text;
