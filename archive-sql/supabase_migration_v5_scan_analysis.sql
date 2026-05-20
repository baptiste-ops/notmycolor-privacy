-- ─── Migration v5: Add analysis_text and garment_type to scans ───────────────
-- Run this in: Supabase Dashboard → SQL Editor → New query → Run

alter table public.scans
  add column if not exists analysis_text text,
  add column if not exists garment_type  text;
