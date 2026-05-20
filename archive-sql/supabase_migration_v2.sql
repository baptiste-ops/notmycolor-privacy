-- ============================================================
-- NotMyColor — Migration v2
-- Ajoute les colonnes pour stocker toutes les réponses
-- de l'onboarding et l'email de l'utilisateur.
--
-- À coller dans : Supabase > SQL Editor > New query → Run
-- ============================================================

alter table public.profiles
  add column if not exists email              text,
  add column if not exists age                int,
  add column if not exists gender             text,
  add column if not exists photo_reaction     text,
  add column if not exists be_honest          text[],
  add column if not exists spend              text,
  add column if not exists skin               text,
  add column if not exists jewelry            text,
  add column if not exists color_pref         text,
  add column if not exists what_change        text[],
  add column if not exists honest_choice      text,
  add column if not exists season_confidence  int,     -- confiance de l'IA (0-100)
  add column if not exists season_runner_up   text;    -- 2ème saison possible selon l'IA
