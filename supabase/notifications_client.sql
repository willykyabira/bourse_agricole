-- =====================================================================
-- CORRECTION DU SCHÉMA : notifications temps réel pour le CLIENT (acheteur)
-- =====================================================================
-- La table "notifications" ne référence que le vendeur (vendeur_id).
-- Pour notifier le client quand sa commande change de statut
-- (validée / livrée), on ajoute une colonne acheteur_id et on crée
-- des triggers qui insèrent automatiquement une notification à chaque
-- changement de statut d'une commande.
--
-- NOTE : ce script est fourni pour exécution manuelle dans l'éditeur SQL
-- de Supabase (ou via la CLI). Il n'est pas exécuté par l'application.
-- =====================================================================

-- 1) Ajout de la colonne acheteur_id (celui qui reçoit la notification)
ALTER TABLE public.notifications
  ADD COLUMN IF NOT EXISTS acheteur_id uuid REFERENCES auth.users(id);

-- Index pour le filtrage temps réel côté client
CREATE INDEX IF NOT EXISTS idx_notifications_acheteur
  ON public.notifications (acheteur_id);

-- 2) Fonction : notifier le client lors d'un changement de statut de commande
CREATE OR REPLACE FUNCTION public.notifier_client_commande()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_acheteur uuid;
  v_message text;
BEGIN
  -- L'acheteur est stocké dans user_id (voir creerCommande)
  v_acheteur := NEW.user_id;

  IF v_acheteur IS NULL THEN
    RETURN NEW;
  END IF;

  -- Construire le message selon le nouveau statut
  IF TG_OP = 'INSERT' THEN
    v_message := 'Votre commande ' || COALESCE(NEW.reference_facture, NEW.id::text)
              || ' a été enregistrée avec succès.';
  ELSIF OLD.statut IS DISTINCT FROM NEW.statut THEN
    CASE NEW.statut
      WHEN 'validee' THEN
        v_message := 'Bonne nouvelle ! Votre commande '
                  || COALESCE(NEW.reference_facture, NEW.id::text)
                  || ' a été validée par la BAN.';
      WHEN 'livree' THEN
        v_message := 'Votre commande '
                  || COALESCE(NEW.reference_facture, NEW.id::text)
                  || ' a été livrée. Merci de confirmer la réception.';
      WHEN 'annulee' THEN
        v_message := 'Votre commande '
                  || COALESCE(NEW.reference_facture, NEW.id::text)
                  || ' a été annulée.';
      ELSE
        v_message := 'Mise à jour de votre commande '
                  || COALESCE(NEW.reference_facture, NEW.id::text)
                  || ' : statut « ' || NEW.statut || ' ».';
    END CASE;
  ELSE
    RETURN NEW;
  END IF;

  INSERT INTO public.notifications (acheteur_id, message, date_notification, is_read)
  VALUES (v_acheteur, v_message, now(), false);

  RETURN NEW;
END;
$$;

-- 3) Trigger sur INSERT et UPDATE de commandes
DROP TRIGGER IF EXISTS trg_notifier_client_commande ON public.commandes;
CREATE TRIGGER trg_notifier_client_commande
  AFTER INSERT OR UPDATE OF statut
  ON public.commandes
  FOR EACH ROW
  EXECUTE FUNCTION public.notifier_client_commande();

-- 4) (Optionnel) Statuts possibles de la commande.
--    Les valeurs déjà utilisées : 'En cours de livraison', 'validee', 'livree', 'annulee'
--    Aucune contrainte n'est imposée ici pour ne pas casser les données existantes.

-- 5) Activation de la réplication temps réel (Realtime) sur les tables concernées
--    À faire dans le dashboard Supabase > Database > Replication > Tables,
--    ou via la commande SQL ci-dessous si votre projet le permet :
ALTER TABLE public.notifications REPLICA IDENTITY FULL;
ALTER TABLE public.commandes REPLICA IDENTITY FULL;
