-- =====================================================================
-- LIEUX / ENTREPÔTS LIÉS AUX PRODUITS, COMMANDES ET FACTURES
-- =====================================================================
-- À exécuter dans l'éditeur SQL de Supabase (ou via la CLI).
-- Permet à chaque produit d'être rattaché à un entrepôt (lieu) et de
-- propager automatiquement ce lieu vers la commande et la facture.
-- =====================================================================

-- 1) Colonnes manquantes
ALTER TABLE public.factures
  ADD COLUMN IF NOT EXISTS entrepot_id uuid,
  ADD COLUMN IF NOT EXISTS lieu_retrait text;

ALTER TABLE public.commandes
  ADD COLUMN IF NOT EXISTS entrepot_id uuid;

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS entrepot_id uuid;

ALTER TABLE public.produits
  ADD COLUMN IF NOT EXISTS entrepot_id uuid;

ALTER TABLE public.stocks
  ADD COLUMN IF NOT EXISTS entrepot_id uuid;

-- 2) Contraintes FK
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'profiles_entrepot_id_fkey') THEN
    ALTER TABLE public.profiles ADD CONSTRAINT profiles_entrepot_id_fkey
      FOREIGN KEY (entrepot_id) REFERENCES public.entrepots(id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'produits_entrepot_id_fkey') THEN
    ALTER TABLE public.produits ADD CONSTRAINT produits_entrepot_id_fkey
      FOREIGN KEY (entrepot_id) REFERENCES public.entrepots(id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commandes_entrepot_id_fkey') THEN
    ALTER TABLE public.commandes ADD CONSTRAINT commandes_entrepot_id_fkey
      FOREIGN KEY (entrepot_id) REFERENCES public.entrepots(id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'factures_entrepot_id_fkey') THEN
    ALTER TABLE public.factures ADD CONSTRAINT factures_entrepot_id_fkey
      FOREIGN KEY (entrepot_id) REFERENCES public.entrepots(id);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'stocks_entrepot_id_fkey') THEN
    ALTER TABLE public.stocks ADD CONSTRAINT stocks_entrepot_id_fkey
      FOREIGN KEY (entrepot_id) REFERENCES public.entrepots(id);
  END IF;
END $$;

-- 3) Trigger : remplissage auto de l'entrepôt sur la commande (depuis le produit)
CREATE OR REPLACE FUNCTION public.remplir_entrepot_commande()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.entrepot_id IS NULL THEN
    SELECT p.entrepot_id INTO NEW.entrepot_id
    FROM public.produits p WHERE p.id = NEW.produit_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_remplir_entrepot_commande ON public.commandes;
CREATE TRIGGER trigger_remplir_entrepot_commande
  BEFORE INSERT ON public.commandes
  FOR EACH ROW
  EXECUTE FUNCTION public.remplir_entrepot_commande();

-- 4) Trigger : remplissage auto de la facture (entrepot + lieu) depuis la commande
CREATE OR REPLACE FUNCTION public.remplir_facture_depuis_commande()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.entrepot_id IS NULL THEN
    SELECT c.entrepot_id INTO NEW.entrepot_id
    FROM public.commandes c WHERE c.id = NEW.commande_id;
  END IF;

  IF NEW.lieu_retrait IS NULL THEN
    SELECT COALESCE(e.nom_entrepot, 'Non spécifié') INTO NEW.lieu_retrait
    FROM public.entrepots e WHERE e.id = NEW.entrepot_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_remplir_facture_depuis_commande ON public.factures;
CREATE TRIGGER trigger_remplir_facture_depuis_commande
  BEFORE INSERT ON public.factures
  FOR EACH ROW
  EXECUTE FUNCTION public.remplir_facture_depuis_commande();

-- 5) Vue : facture avec lieu d'entreposage
CREATE OR REPLACE VIEW public.v_factures_avec_lieu AS
SELECT
  f.id AS facture_id,
  f.commande_id,
  f.date_facture,
  f.type,
  f.montant,
  f.description,
  COALESCE(e.nom_entrepot, prod.nom_produit, 'Non spécifié') AS lieu_retrait,
  e.id AS entrepot_id,
  c.nom_client,
  c.quantite,
  c.prix_total,
  c.statut AS statut_commande,
  c.created_at AS date_commande,
  prod.nom_produit,
  prod.prix_unitaire
FROM public.factures f
JOIN public.commandes c ON c.id = f.commande_id
LEFT JOIN public.produits prod ON prod.id = c.produit_id
LEFT JOIN public.entrepots e ON e.id = COALESCE(f.entrepot_id, c.entrepot_id, prod.entrepot_id);

-- 6) Vue : produits avec leur entrepôt (lieu)
CREATE OR REPLACE VIEW public.v_produits_avec_lieu AS
SELECT
  p.*,
  e.nom_entrepot AS nom_entrepot,
  e.territoire AS territoire_entrepot
FROM public.produits p
LEFT JOIN public.entrepots e ON e.id = p.entrepot_id;
