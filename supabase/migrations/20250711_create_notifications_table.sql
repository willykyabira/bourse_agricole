-- =====================================================================
-- BAN ITURI - Système de notifications
-- Création de la table notifications et activation du realtime
-- =====================================================================

-- 1. Création de la table notifications
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  titre TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('produit', 'transaction', 'livraison', 'retrait', 'info')),
  reference_id TEXT,
  est_lu BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Index pour améliorer les performances des requêtes par utilisateur
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON public.notifications(type);

-- 3. Activation de Row Level Security (RLS)
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 4. Politiques RLS
-- Un utilisateur ne peut voir que ses propres notifications
CREATE POLICY "Users can view their own notifications"
  ON public.notifications
  FOR SELECT
  USING (auth.uid()::text = user_id OR user_id = 'system');

-- Un utilisateur peut marquer ses notifications comme lues
CREATE POLICY "Users can update their own notifications"
  ON public.notifications
  FOR UPDATE
  USING (auth.uid()::text = user_id OR user_id = 'system');

-- Un utilisateur peut supprimer ses notifications
CREATE POLICY "Users can delete their own notifications"
  ON public.notifications
  FOR DELETE
  USING (auth.uid()::text = user_id OR user_id = 'system');

-- Insertion autorisée pour les services système et les utilisateurs authentifiés
CREATE POLICY "Allow notification creation"
  ON public.notifications
  FOR INSERT
  WITH CHECK (true);

-- 5. Activation du Realtime sur la table notifications
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
