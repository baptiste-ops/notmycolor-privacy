-- ============================================================
-- NotMyColor — Supabase schema
-- À coller dans : app.supabase.com > SQL Editor > New query
-- ============================================================

-- ─── Table profiles ──────────────────────────────────────────
-- Stocke le nom, la saison et l'état d'onboarding de l'utilisateur.
-- L'id est le même UUID que celui de auth.users.

create table if not exists public.profiles (
  id           uuid primary key references auth.users (id) on delete cascade,
  name         text,
  season_slug  text,               -- ex. 'dark-autumn', 'true-spring'
  onboarded    boolean default false,
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

-- Active Row Level Security
alter table public.profiles enable row level security;

-- Chaque utilisateur ne peut lire / écrire que son propre profil
create policy "profiles: own read"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles: own write"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "profiles: own update"
  on public.profiles for update
  using (auth.uid() = id);

-- ─── Table scans ─────────────────────────────────────────────
-- Historique des scans vestimentaires de chaque utilisateur.

create table if not exists public.scans (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid references public.profiles (id) on delete cascade,
  garment_name  text,
  color_name    text,
  color_hex     text,
  tag           text,     -- 'wear' | 'depends' | 'avoid'
  score         int,
  cat           text,     -- catégorie de couleur
  photo_url     text,     -- URL dans Supabase Storage (optionnel)
  created_at    timestamptz default now()
);

-- Active Row Level Security
alter table public.scans enable row level security;

create policy "scans: own read"
  on public.scans for select
  using (auth.uid() = user_id);

create policy "scans: own insert"
  on public.scans for insert
  with check (auth.uid() = user_id);

create policy "scans: own delete"
  on public.scans for delete
  using (auth.uid() = user_id);

-- ─── Trigger : créer un profil vide à l'inscription ──────────
-- Évite les erreurs "profile not found" juste après signUp.

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id)
  values (new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
