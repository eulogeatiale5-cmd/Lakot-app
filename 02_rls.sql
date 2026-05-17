-- ================================================================
-- LAKOTA-GUEYO v2 — Row Level Security
-- ================================================================

ALTER TABLE profils              ENABLE ROW LEVEL SECURITY;
ALTER TABLE sites                ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories           ENABLE ROW LEVEL SECURITY;
ALTER TABLE equipements          ENABLE ROW LEVEL SECURITY;
ALTER TABLE cuves                ENABLE ROW LEVEL SECURITY;
ALTER TABLE distributions        ENABLE ROW LEVEL SECURITY;
ALTER TABLE releves_compteurs    ENABLE ROW LEVEL SECURITY;
ALTER TABLE ratios_historique    ENABLE ROW LEVEL SECURITY;
ALTER TABLE seuils_carburant     ENABLE ROW LEVEL SECURITY;
ALTER TABLE approvisionnements   ENABLE ROW LEVEL SECURITY;
ALTER TABLE mouvements           ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenances         ENABLE ROW LEVEL SECURITY;
ALTER TABLE alertes              ENABLE ROW LEVEL SECURITY;

-- Helpers
CREATE OR REPLACE FUNCTION get_user_role() RETURNS TEXT AS $$
  SELECT role FROM profils WHERE id=auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION get_user_site() RETURNS UUID AS $$
  SELECT site_id FROM profils WHERE id=auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Catégories : lecture publique
CREATE POLICY "cat_read" ON categories FOR SELECT TO authenticated USING (TRUE);

-- Sites
CREATE POLICY "sites_read" ON sites FOR SELECT TO authenticated
  USING (id=get_user_site() OR get_user_role()='admin');

-- Profils
CREATE POLICY "profils_own" ON profils FOR SELECT TO authenticated
  USING (id=auth.uid() OR get_user_role()='admin');
CREATE POLICY "profils_update" ON profils FOR UPDATE TO authenticated
  USING (id=auth.uid() OR get_user_role()='admin');

-- Équipements
CREATE POLICY "equip_read"   ON equipements FOR SELECT TO authenticated USING (site_id=get_user_site() OR get_user_role()='admin');
CREATE POLICY "equip_insert" ON equipements FOR INSERT TO authenticated WITH CHECK (site_id=get_user_site() AND get_user_role() IN ('admin','responsable','operateur'));
CREATE POLICY "equip_update" ON equipements FOR UPDATE TO authenticated USING (site_id=get_user_site() AND get_user_role() IN ('admin','responsable','operateur'));
CREATE POLICY "equip_delete" ON equipements FOR DELETE TO authenticated USING (get_user_role()='admin');

-- Cuves
CREATE POLICY "cuves_read"   ON cuves FOR SELECT TO authenticated USING (site_id=get_user_site() OR get_user_role()='admin');
CREATE POLICY "cuves_update" ON cuves FOR UPDATE TO authenticated USING (site_id=get_user_site() AND get_user_role() IN ('admin','responsable','operateur'));

-- Distributions
CREATE POLICY "dist_read"   ON distributions FOR SELECT TO authenticated USING (site_id=get_user_site() OR get_user_role()='admin');
CREATE POLICY "dist_insert" ON distributions FOR INSERT TO authenticated WITH CHECK (site_id=get_user_site() AND get_user_role() IN ('admin','responsable','operateur'));

-- Relevés compteurs
CREATE POLICY "releves_read"   ON releves_compteurs FOR SELECT TO authenticated USING (site_id=get_user_site() OR get_user_role()='admin');
CREATE POLICY "releves_insert" ON releves_compteurs FOR INSERT TO authenticated WITH CHECK (site_id=get_user_site() AND get_user_role() IN ('admin','responsable','operateur'));

-- Ratios
CREATE POLICY "ratios_read" ON ratios_historique FOR SELECT TO authenticated USING (site_id=get_user_site() OR get_user_role()='admin');

-- Seuils
CREATE POLICY "seuils_read"   ON seuils_carburant FOR SELECT TO authenticated USING (site_id=get_user_site() OR get_user_role()='admin');
CREATE POLICY "seuils_update" ON seuils_carburant FOR UPDATE TO authenticated USING (site_id=get_user_site() AND get_user_role() IN ('admin','responsable'));

-- Approvisionnements
CREATE POLICY "appro_read"   ON approvisionnements FOR SELECT TO authenticated USING (site_id=get_user_site() OR get_user_role()='admin');
CREATE POLICY "appro_insert" ON approvisionnements FOR INSERT TO authenticated WITH CHECK (site_id=get_user_site() AND get_user_role() IN ('admin','responsable','operateur'));

-- Mouvements
CREATE POLICY "mvt_read"   ON mouvements FOR SELECT TO authenticated USING (site_id=get_user_site() OR get_user_role()='admin');
CREATE POLICY "mvt_insert" ON mouvements FOR INSERT TO authenticated WITH CHECK (site_id=get_user_site() AND get_user_role() IN ('admin','responsable','operateur'));

-- Maintenances
CREATE POLICY "maint_read"   ON maintenances FOR SELECT TO authenticated USING (site_id=get_user_site() OR get_user_role()='admin');
CREATE POLICY "maint_insert" ON maintenances FOR INSERT TO authenticated WITH CHECK (site_id=get_user_site() AND get_user_role() IN ('admin','responsable','operateur'));
CREATE POLICY "maint_update" ON maintenances FOR UPDATE TO authenticated USING (site_id=get_user_site() AND get_user_role() IN ('admin','responsable','operateur'));

-- Alertes
CREATE POLICY "alertes_read"   ON alertes FOR SELECT TO authenticated USING (site_id=get_user_site() OR get_user_role()='admin');
CREATE POLICY "alertes_update" ON alertes FOR UPDATE TO authenticated USING (site_id=get_user_site());
