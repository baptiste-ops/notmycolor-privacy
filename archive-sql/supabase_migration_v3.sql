-- ============================================================
-- NotMyColor — Migration v3
-- 1. Ajoute la colonne analyzed_at pour stocker la date d'analyse
-- 2. Crée la fonction RPC delete_account pour la suppression compte
--
-- À coller dans : Supabase > SQL Editor > New query → Run
-- ============================================================

-- ─── analyzed_at : date réelle de l'analyse couleur ──────────
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS analyzed_at TIMESTAMPTZ;

-- ─── delete_account : supprime le compte auth depuis le client ─
-- La fonction tourne en SECURITY DEFINER (droits postgres) pour
-- pouvoir supprimer dans auth.users. La cascade supprime
-- automatiquement profiles + scans.
CREATE OR REPLACE FUNCTION public.delete_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM auth.users WHERE id = auth.uid();
END;
$$;

-- Seuls les utilisateurs authentifiés peuvent appeler cette fonction
GRANT EXECUTE ON FUNCTION public.delete_account() TO authenticated;
