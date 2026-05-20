-- v6: Add avatar_url column for profile photos
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
