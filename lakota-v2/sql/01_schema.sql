-- ================================================================
-- LAKOTA-GUEYO v2 — Schéma Supabase complet
-- Inclut : parc, carburant, ratios, alertes, maintenance
-- Exécuter dans : Supabase > SQL Editor
-- ================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================================================================
-- 1. SITES
-- ================================================================
CREATE TABLE sites (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code        TEXT NOT NULL UNIQUE,
  nom         TEXT NOT NULL,
  localisation TEXT,
  actif       BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO sites (code, nom, localisation)
VALUES ('LAKOTA-GUEYO', 'Chantier LAKOTA-GUEYO', 'Côte d''Ivoire');

-- ================================================================
-- 2. PROFILS UTILISATEURS
-- ================================================================
CREATE TABLE profils (
  id         UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nom        TEXT NOT NULL,
  prenom     TEXT,
  email      TEXT NOT NULL,
  role       TEXT NOT NULL DEFAULT 'operateur'
               CHECK (role IN ('admin','responsable','operateur','lecteur')),
  site_id    UUID REFERENCES sites(id),
  actif      BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================================
-- 3. CATÉGORIES D'ÉQUIPEMENTS
-- ================================================================
CREATE TABLE categories (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  code        TEXT NOT NULL UNIQUE,
  nom         TEXT NOT NULL,
  icone       TEXT,
  type_mesure TEXT NOT NULL DEFAULT 'HEURES'
                CHECK (type_mesure IN ('HEURES','KM','AUCUN'))
  -- HEURES = engins (L/h), KM = véhicules (L/100km), AUCUN = cuves/installations
);

INSERT INTO categories (code, nom, icone, type_mesure) VALUES
  ('ENGIN_LOURD',       'Engin Lourd',           '🏗️', 'HEURES'),
  ('CAMION_TRANSPORT',  'Camion / Transport',     '🚛', 'KM'),
  ('VEHICULE_LEGER',    'Véhicule Léger',         '🚗', 'KM'),
  ('MOTO',              'Moto',                   '🏍️', 'KM'),
  ('GROUPE_ELECTROGENE','Groupe Électrogène',     '⚡', 'HEURES'),
  ('CUVE_GASOIL',       'Cuve à Gasoil',          '⛽', 'AUCUN'),
  ('INSTALLATION',      'Installation',           '🏭', 'AUCUN');

-- ================================================================
-- 4. ÉQUIPEMENTS
-- ================================================================
CREATE TABLE equipements (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id             UUID NOT NULL REFERENCES sites(id),
  categorie_id        UUID NOT NULL REFERENCES categories(id),
  numero              INTEGER,
  code                TEXT NOT NULL,
  type_engin          TEXT NOT NULL,
  marque              TEXT,
  modele              TEXT,
  immatriculation     TEXT,
  date_mobilisation   DATE,
  etat                TEXT NOT NULL DEFAULT 'BON'
                        CHECK (etat IN ('BON','PANNE','MAINTENANCE','STAND_BY','DEMOBILISE')),
  affectation         TEXT,
  responsable         TEXT,
  observation         TEXT,
  -- Seuils de ratio carburant
  ratio_reference_lh  NUMERIC(6,2),   -- L/h de référence constructeur (engins)
  ratio_reference_l100 NUMERIC(6,2),  -- L/100km référence (véhicules)
  seuil_alerte_pct    INTEGER DEFAULT 20, -- % d'écart déclenchant une alerte
  -- Compteurs actuels
  compteur_actuel     NUMERIC(10,1) DEFAULT 0, -- km ou heures actuels
  actif               BOOLEAN DEFAULT TRUE,
  created_by          UUID REFERENCES profils(id),
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(site_id, code)
);

CREATE INDEX idx_equip_site     ON equipements(site_id);
CREATE INDEX idx_equip_etat     ON equipements(etat);
CREATE INDEX idx_equip_cat      ON equipements(categorie_id);

-- ================================================================
-- 5. CUVES GASOIL
-- ================================================================
CREATE TABLE cuves (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id       UUID NOT NULL REFERENCES sites(id),
  code          TEXT NOT NULL,
  capacite      NUMERIC(10,0) NOT NULL,
  stock_actuel  NUMERIC(10,0) DEFAULT 0,
  seuil_alerte  NUMERIC(10,0) DEFAULT 2000,
  affectation   TEXT,
  actif         BOOLEAN DEFAULT TRUE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(site_id, code)
);

-- ================================================================
-- 6. DISTRIBUTIONS GASOIL (enrichies pour ratios)
-- ================================================================
CREATE TABLE distributions (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id             UUID NOT NULL REFERENCES sites(id),
  cuve_id             UUID NOT NULL REFERENCES cuves(id),
  equipement_id       UUID REFERENCES equipements(id),
  date_distribution   DATE NOT NULL DEFAULT CURRENT_DATE,
  quantite            NUMERIC(10,0) NOT NULL,        -- litres distribués

  -- Compteurs pour calcul ratio
  compteur_debut      NUMERIC(10,1),  -- km ou heures au départ
  compteur_fin        NUMERIC(10,1),  -- km ou heures à l'arrivée
  compteur_delta      NUMERIC(10,1),  -- calculé automatiquement (fin - debut)

  -- Ratio calculé automatiquement
  ratio_calcule       NUMERIC(8,3),   -- L/h ou L/100km
  type_mesure         TEXT,           -- 'HEURES' ou 'KM' (copié de categorie)
  ecart_reference_pct NUMERIC(6,1),   -- % d'écart vs ratio de référence
  anomalie            BOOLEAN DEFAULT FALSE,

  -- Contexte
  beneficiaire        TEXT,
  activite            TEXT,
  chantier            TEXT,
  stock_avant         NUMERIC(10,0),
  stock_apres         NUMERIC(10,0),
  note                TEXT,

  created_by          UUID REFERENCES profils(id),
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_dist_site    ON distributions(site_id);
CREATE INDEX idx_dist_equip   ON distributions(equipement_id);
CREATE INDEX idx_dist_cuve    ON distributions(cuve_id);
CREATE INDEX idx_dist_date    ON distributions(date_distribution DESC);
CREATE INDEX idx_dist_anomalie ON distributions(anomalie) WHERE anomalie = TRUE;

-- ================================================================
-- 7. RELEVÉS COMPTEURS (suivi kilométrique / horaire indépendant)
-- ================================================================
CREATE TABLE releves_compteurs (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id        UUID NOT NULL REFERENCES sites(id),
  equipement_id  UUID NOT NULL REFERENCES equipements(id),
  date_releve    DATE NOT NULL DEFAULT CURRENT_DATE,
  valeur         NUMERIC(10,1) NOT NULL,  -- km ou heures
  type_mesure    TEXT NOT NULL CHECK (type_mesure IN ('HEURES','KM')),
  note           TEXT,
  created_by     UUID REFERENCES profils(id),
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_releves_equip ON releves_compteurs(equipement_id);
CREATE INDEX idx_releves_date  ON releves_compteurs(date_releve DESC);

-- ================================================================
-- 8. RATIOS CALCULÉS (agrégats journaliers/hebdo/mensuels)
-- ================================================================
CREATE TABLE ratios_historique (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id         UUID NOT NULL REFERENCES sites(id),
  equipement_id   UUID NOT NULL REFERENCES equipements(id),
  periode         DATE NOT NULL,         -- date de début de la période
  type_periode    TEXT NOT NULL DEFAULT 'JOUR'
                    CHECK (type_periode IN ('JOUR','SEMAINE','MOIS')),
  total_litres    NUMERIC(10,0) DEFAULT 0,
  total_delta     NUMERIC(10,1) DEFAULT 0, -- km ou heures totales
  ratio_moyen     NUMERIC(8,3),            -- L/h ou L/100km moyen
  ratio_min       NUMERIC(8,3),
  ratio_max       NUMERIC(8,3),
  nb_distributions INTEGER DEFAULT 0,
  type_mesure     TEXT,
  anomalies_count INTEGER DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(equipement_id, periode, type_periode)
);

CREATE INDEX idx_ratios_equip  ON ratios_historique(equipement_id);
CREATE INDEX idx_ratios_period ON ratios_historique(periode DESC);

-- ================================================================
-- 9. SEUILS D'ALERTE CARBURANT
-- ================================================================
CREATE TABLE seuils_carburant (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id         UUID NOT NULL REFERENCES sites(id),
  categorie_id    UUID REFERENCES categories(id),
  equipement_id   UUID REFERENCES equipements(id), -- si spécifique à 1 engin
  type_mesure     TEXT NOT NULL CHECK (type_mesure IN ('HEURES','KM')),
  ratio_min       NUMERIC(8,3),   -- en dessous = sous-utilisation
  ratio_max       NUMERIC(8,3),   -- au dessus = surconsommation
  ratio_reference NUMERIC(8,3),   -- valeur cible
  pct_tolerance   INTEGER DEFAULT 20, -- tolérance en %
  actif           BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Seuils par défaut par type d'engin
INSERT INTO seuils_carburant (site_id, categorie_id, type_mesure, ratio_min, ratio_max, ratio_reference, pct_tolerance)
SELECT s.id, c.id, 'HEURES', 10.0, 30.0, 18.0, 25
FROM sites s, categories c WHERE s.code='LAKOTA-GUEYO' AND c.code='ENGIN_LOURD';

INSERT INTO seuils_carburant (site_id, categorie_id, type_mesure, ratio_min, ratio_max, ratio_reference, pct_tolerance)
SELECT s.id, c.id, 'HEURES', 2.0, 12.0, 6.0, 25
FROM sites s, categories c WHERE s.code='LAKOTA-GUEYO' AND c.code='GROUPE_ELECTROGENE';

INSERT INTO seuils_carburant (site_id, categorie_id, type_mesure, ratio_min, ratio_max, ratio_reference, pct_tolerance)
SELECT s.id, c.id, 'KM', 15.0, 45.0, 28.0, 25
FROM sites s, categories c WHERE s.code='LAKOTA-GUEYO' AND c.code='CAMION_TRANSPORT';

INSERT INTO seuils_carburant (site_id, categorie_id, type_mesure, ratio_min, ratio_max, ratio_reference, pct_tolerance)
SELECT s.id, c.id, 'KM', 8.0, 20.0, 12.0, 25
FROM sites s, categories c WHERE s.code='LAKOTA-GUEYO' AND c.code='VEHICULE_LEGER';

-- ================================================================
-- 10. APPROVISIONNEMENTS
-- ================================================================
CREATE TABLE approvisionnements (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id         UUID NOT NULL REFERENCES sites(id),
  cuve_id         UUID NOT NULL REFERENCES cuves(id),
  date_reception  DATE NOT NULL DEFAULT CURRENT_DATE,
  quantite        NUMERIC(10,0) NOT NULL,
  compteur_camion TEXT,
  stock_avant     NUMERIC(10,0),
  stock_apres     NUMERIC(10,0),
  fournisseur     TEXT,
  bon_livraison   TEXT,
  receptionne_par TEXT,
  note            TEXT,
  created_by      UUID REFERENCES profils(id),
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================================
-- 11. MOUVEMENTS
-- ================================================================
CREATE TABLE mouvements (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id        UUID NOT NULL REFERENCES sites(id),
  equipement_id  UUID NOT NULL REFERENCES equipements(id),
  type_mouvement TEXT NOT NULL CHECK (type_mouvement IN (
    'MOBILISATION','DEMOBILISATION','TRANSFERT',
    'RETOUR_ATELIER','CHANGEMENT_ETAT','MISSION')),
  etat_avant     TEXT,
  etat_apres     TEXT,
  destination    TEXT,
  note           TEXT,
  date_mouvement DATE NOT NULL DEFAULT CURRENT_DATE,
  created_by     UUID REFERENCES profils(id),
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================================
-- 12. MAINTENANCES
-- ================================================================
CREATE TABLE maintenances (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id           UUID NOT NULL REFERENCES sites(id),
  equipement_id     UUID NOT NULL REFERENCES equipements(id),
  type_intervention TEXT NOT NULL CHECK (type_intervention IN (
    'PANNE_MECANIQUE','PANNE_HYDRAULIQUE','PANNE_ELECTRIQUE',
    'ENTRETIEN_PREVENTIF','REVISION','TRANSFERT_REPARATION',
    'ALERTE_RATIO','AUTRE')),
  priorite          TEXT DEFAULT 'NORMALE' CHECK (priorite IN ('HAUTE','NORMALE','BASSE')),
  description       TEXT,
  date_debut        DATE NOT NULL DEFAULT CURRENT_DATE,
  date_fin          DATE,
  statut            TEXT NOT NULL DEFAULT 'EN_COURS'
                      CHECK (statut IN ('EN_COURS','RESOLU','PLANIFIE')),
  -- Lien avec anomalie carburant
  distribution_id   UUID REFERENCES distributions(id),
  ratio_observe     NUMERIC(8,3),
  ratio_reference   NUMERIC(8,3),
  note_resolution   TEXT,
  created_by        UUID REFERENCES profils(id),
  updated_by        UUID REFERENCES profils(id),
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================================
-- 13. ALERTES SYSTÈME
-- ================================================================
CREATE TABLE alertes (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  site_id        UUID NOT NULL REFERENCES sites(id),
  type_alerte    TEXT NOT NULL CHECK (type_alerte IN (
    'PANNE','STOCK_BAS','MAINTENANCE_DUE',
    'RATIO_ELEVE','RATIO_BAS','ANOMALIE_CARBURANT','INFO')),
  niveau         TEXT DEFAULT 'WARN' CHECK (niveau IN ('DANGER','WARN','INFO')),
  titre          TEXT NOT NULL,
  message        TEXT,
  equipement_id  UUID REFERENCES equipements(id),
  cuve_id        UUID REFERENCES cuves(id),
  distribution_id UUID REFERENCES distributions(id),
  lue            BOOLEAN DEFAULT FALSE,
  resolue        BOOLEAN DEFAULT FALSE,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================================
-- 14. VUES ANALYTIQUES
-- ================================================================

-- Vue dashboard global
CREATE VIEW vue_dashboard AS
SELECT
  s.id AS site_id, s.code AS site_code, s.nom AS site_nom,
  COUNT(e.id)                                        AS total_equips,
  COUNT(e.id) FILTER (WHERE e.etat='BON')            AS nb_bon,
  COUNT(e.id) FILTER (WHERE e.etat='PANNE')          AS nb_panne,
  ROUND(COUNT(e.id) FILTER (WHERE e.etat='BON')::NUMERIC / NULLIF(COUNT(e.id),0)*100,1) AS taux_dispo,
  COUNT(m.id) FILTER (WHERE m.statut='EN_COURS')     AS pannes_actives,
  COALESCE(SUM(c.stock_actuel),0)                    AS stock_gasoil_total,
  COUNT(a.id) FILTER (WHERE a.resolue=FALSE)         AS alertes_actives
FROM sites s
LEFT JOIN equipements e ON e.site_id=s.id AND e.actif=TRUE
LEFT JOIN maintenances m ON m.site_id=s.id
LEFT JOIN cuves c ON c.site_id=s.id AND c.actif=TRUE
LEFT JOIN alertes a ON a.site_id=s.id
GROUP BY s.id, s.code, s.nom;

-- Vue consommation et ratio par engin
CREATE VIEW vue_ratios_equip AS
SELECT
  d.site_id,
  d.equipement_id,
  e.code                          AS code_equip,
  e.type_engin,
  e.marque,
  cat.type_mesure,
  e.ratio_reference_lh,
  e.ratio_reference_l100,
  COUNT(d.id)                     AS nb_distributions,
  SUM(d.quantite)                 AS total_litres,
  SUM(d.compteur_delta)           AS total_delta,
  -- Ratio moyen global
  CASE
    WHEN cat.type_mesure='HEURES' AND SUM(d.compteur_delta)>0
      THEN ROUND(SUM(d.quantite)::NUMERIC / SUM(d.compteur_delta), 2)
    WHEN cat.type_mesure='KM' AND SUM(d.compteur_delta)>0
      THEN ROUND(SUM(d.quantite)::NUMERIC / SUM(d.compteur_delta) * 100, 2)
    ELSE NULL
  END                             AS ratio_moyen,
  -- Ratio du dernier ravitaillement
  (SELECT ratio_calcule FROM distributions d2
   WHERE d2.equipement_id=d.equipement_id
   ORDER BY d2.date_distribution DESC, d2.created_at DESC LIMIT 1) AS dernier_ratio,
  COUNT(d.id) FILTER (WHERE d.anomalie=TRUE) AS nb_anomalies,
  MAX(d.date_distribution)        AS derniere_distribution,
  MIN(d.date_distribution)        AS premiere_distribution
FROM distributions d
JOIN equipements e   ON e.id = d.equipement_id
JOIN categories cat  ON cat.id = e.categorie_id
WHERE d.compteur_delta IS NOT NULL AND d.compteur_delta > 0
GROUP BY d.site_id, d.equipement_id, e.code, e.type_engin, e.marque,
         cat.type_mesure, e.ratio_reference_lh, e.ratio_reference_l100
ORDER BY total_litres DESC;

-- Vue top consommateurs (30 derniers jours)
CREATE VIEW vue_top_conso_30j AS
SELECT
  d.site_id,
  d.equipement_id,
  e.code, e.type_engin, e.marque,
  cat.type_mesure,
  SUM(d.quantite)      AS litres_30j,
  COUNT(d.id)          AS distribs_30j,
  CASE WHEN SUM(d.compteur_delta)>0 AND cat.type_mesure='HEURES'
    THEN ROUND(SUM(d.quantite)::NUMERIC/SUM(d.compteur_delta),2) END AS ratio_lh,
  CASE WHEN SUM(d.compteur_delta)>0 AND cat.type_mesure='KM'
    THEN ROUND(SUM(d.quantite)::NUMERIC/SUM(d.compteur_delta)*100,2) END AS ratio_l100
FROM distributions d
JOIN equipements e  ON e.id=d.equipement_id
JOIN categories cat ON cat.id=e.categorie_id
WHERE d.date_distribution >= CURRENT_DATE - 30
GROUP BY d.site_id,d.equipement_id,e.code,e.type_engin,e.marque,cat.type_mesure
ORDER BY litres_30j DESC;

-- ================================================================
-- 15. FONCTIONS & TRIGGERS
-- ================================================================

-- updated_at automatique
CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at=NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_ts_equipements BEFORE UPDATE ON equipements FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
CREATE TRIGGER set_ts_maintenances BEFORE UPDATE ON maintenances FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
CREATE TRIGGER set_ts_cuves BEFORE UPDATE ON cuves FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- Calcul automatique ratio + stock cuve à chaque distribution
CREATE OR REPLACE FUNCTION process_distribution()
RETURNS TRIGGER AS $$
DECLARE
  v_type_mesure  TEXT;
  v_ratio_ref    NUMERIC;
  v_seuil_pct    INTEGER;
  v_ratio        NUMERIC;
  v_ecart        NUMERIC;
  v_code_equip   TEXT;
  v_type_engin   TEXT;
BEGIN
  -- Stock cuve
  SELECT stock_actuel INTO NEW.stock_avant FROM cuves WHERE id=NEW.cuve_id;
  NEW.stock_apres := NEW.stock_avant - NEW.quantite;
  UPDATE cuves SET stock_actuel=NEW.stock_apres, updated_at=NOW() WHERE id=NEW.cuve_id;

  -- Alerte stock bas
  IF NEW.stock_apres < (SELECT seuil_alerte FROM cuves WHERE id=NEW.cuve_id) THEN
    INSERT INTO alertes(site_id,type_alerte,niveau,titre,message,cuve_id)
    SELECT NEW.site_id,'STOCK_BAS','DANGER',
      'Stock bas : '||(SELECT code FROM cuves WHERE id=NEW.cuve_id),
      'Stock restant : '||NEW.stock_apres||' L',NEW.cuve_id;
  END IF;

  -- Calcul ratio si compteurs renseignés
  IF NEW.equipement_id IS NOT NULL AND NEW.compteur_debut IS NOT NULL AND NEW.compteur_fin IS NOT NULL THEN
    NEW.compteur_delta := NEW.compteur_fin - NEW.compteur_debut;

    IF NEW.compteur_delta > 0 THEN
      -- Type de mesure
      SELECT cat.type_mesure, e.ratio_reference_lh, e.ratio_reference_l100,
             e.seuil_alerte_pct, e.code, e.type_engin
      INTO v_type_mesure, v_ratio_ref, v_ratio, v_seuil_pct, v_code_equip, v_type_engin
      FROM equipements e JOIN categories cat ON cat.id=e.categorie_id
      WHERE e.id=NEW.equipement_id;

      NEW.type_mesure := v_type_mesure;

      IF v_type_mesure = 'HEURES' THEN
        v_ratio := ROUND(NEW.quantite::NUMERIC / NEW.compteur_delta, 2);
        v_ratio_ref := COALESCE(v_ratio_ref, 18.0);
      ELSIF v_type_mesure = 'KM' THEN
        v_ratio := ROUND(NEW.quantite::NUMERIC / NEW.compteur_delta * 100, 2);
        v_ratio_ref := COALESCE(v_ratio, 25.0);
      END IF;

      NEW.ratio_calcule := v_ratio;

      -- Calcul écart vs référence
      IF v_ratio_ref > 0 THEN
        v_ecart := ROUND((v_ratio - v_ratio_ref) / v_ratio_ref * 100, 1);
        NEW.ecart_reference_pct := v_ecart;
        -- Anomalie si écart > seuil
        IF ABS(v_ecart) > COALESCE(v_seuil_pct, 20) THEN
          NEW.anomalie := TRUE;
          -- Alerte anomalie
          INSERT INTO alertes(site_id,type_alerte,niveau,titre,message,equipement_id,distribution_id)
          VALUES(NEW.site_id,
            CASE WHEN v_ecart > 0 THEN 'RATIO_ELEVE' ELSE 'RATIO_BAS' END,
            CASE WHEN ABS(v_ecart) > 40 THEN 'DANGER' ELSE 'WARN' END,
            CASE WHEN v_ecart > 0
              THEN 'Surconsommation : '||v_code_equip
              ELSE 'Sous-consommation : '||v_code_equip
            END,
            v_type_engin||' — Ratio : '||v_ratio||
            CASE WHEN v_type_mesure='HEURES' THEN ' L/h' ELSE ' L/100km' END||
            ' (réf : '||v_ratio_ref||') — Écart : '||v_ecart||'%',
            NEW.equipement_id, NEW.id);
          -- Suggérer maintenance préventive si surconsommation forte
          IF v_ecart > 40 THEN
            INSERT INTO maintenances(site_id,equipement_id,type_intervention,
              priorite,description,statut,distribution_id,ratio_observe,ratio_reference)
            VALUES(NEW.site_id,NEW.equipement_id,'ALERTE_RATIO','HAUTE',
              'Surconsommation détectée : ratio '||v_ratio||
              ' (réf '||v_ratio_ref||') — Écart '||v_ecart||'% — Vérification moteur recommandée',
              'PLANIFIE',NEW.id,v_ratio,v_ratio_ref);
          END IF;
        END IF;
      END IF;

      -- Mise à jour compteur actuel de l'engin
      UPDATE equipements SET compteur_actuel=NEW.compteur_fin, updated_at=NOW()
      WHERE id=NEW.equipement_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_process_distribution
  BEFORE INSERT ON distributions
  FOR EACH ROW EXECUTE FUNCTION process_distribution();

-- Trigger alerte panne équipement
CREATE OR REPLACE FUNCTION alerte_panne_equipement()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.etat='PANNE' AND (OLD.etat IS NULL OR OLD.etat<>'PANNE') THEN
    INSERT INTO alertes(site_id,type_alerte,niveau,titre,message,equipement_id)
    VALUES(NEW.site_id,'PANNE','DANGER',
      'Panne : '||NEW.code,
      NEW.type_engin||' '||COALESCE(NEW.marque,'')||' — '||COALESCE(NEW.affectation,''),
      NEW.id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_alerte_panne
  AFTER UPDATE ON equipements
  FOR EACH ROW EXECUTE FUNCTION alerte_panne_equipement();

-- Appro : maj stock cuve
CREATE OR REPLACE FUNCTION process_approvisionnement()
RETURNS TRIGGER AS $$
BEGIN
  SELECT stock_actuel INTO NEW.stock_avant FROM cuves WHERE id=NEW.cuve_id;
  NEW.stock_apres := NEW.stock_avant + NEW.quantite;
  UPDATE cuves SET stock_actuel=NEW.stock_apres, updated_at=NOW() WHERE id=NEW.cuve_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_process_appro
  BEFORE INSERT ON approvisionnements
  FOR EACH ROW EXECUTE FUNCTION process_approvisionnement();

-- Création profil automatique à l'inscription
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profils(id,nom,email,role)
  VALUES(NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'nom', split_part(NEW.email,'@',1)),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'role','operateur'));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
