-- ─── Migration v4: Supabase Storage for scan photos ────────────────────────
-- Run this in: Supabase Dashboard → SQL Editor → New query → Run

-- 1. Create the public bucket (photos are served via public URL, no signed tokens needed)
insert into storage.buckets (id, name, public)
values ('scan-photos', 'scan-photos', true)
on conflict (id) do update set public = true;

-- 2. Allow authenticated users to upload to their own folder (userId/filename.jpg)
create policy "Users upload their own scan photos"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'scan-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- 3. Allow anyone to read photos (bucket is public, but paths are opaque)
create policy "Public read scan photos"
  on storage.objects for select
  to public
  using (bucket_id = 'scan-photos');

-- 4. Allow authenticated users to delete their own photos
create policy "Users delete their own scan photos"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'scan-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
