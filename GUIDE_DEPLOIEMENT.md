# LAKOTA-GUEYO v2 — Guide de Déploiement Production
## Architecture Supabase + Vercel + Module Ratio Carburant

---

## 📁 STRUCTURE DES FICHIERS LIVRÉS

```
lakota-v2/
├── index.html                 ← Application complète (frontend + Supabase + Ratios)
├── sql/
│   ├── 01_schema.sql          ← 12 tables + vues + 6 triggers automatiques
│   ├── 02_rls.sql             ← Sécurité Row Level Security (4 rôles)
│   └── 03_seed.sql            ← 148 équipements + ratios de référence constructeur
└── docs/
    └── GUIDE_DEPLOIEMENT.md   ← Ce fichier
```

---

## ARCHITECTURE TECHNIQUE

```
┌─────────────────────────────────────────────────────┐
│                    UTILISATEURS                      │
│         (Chef chantier, Pompiste, Directeur)         │
└──────────────────────┬──────────────────────────────┘
                       │ HTTPS
┌──────────────────────▼──────────────────────────────┐
│              VERCEL (Frontend)                       │
│              index.html                              │
│         Hébergement gratuit · CDN mondial            │
└──────────────────────┬──────────────────────────────┘
                       │ Supabase JS SDK v2
┌──────────────────────▼──────────────────────────────┐
│              SUPABASE (Backend)                      │
├─────────────────┬────────────────┬──────────────────┤
│   Auth (JWT)    │  PostgreSQL DB │  Realtime WS     │
│   Connexion     │  12 tables     │  Sync instantané │
│   Rôles         │  Vues SQL      │  Multi-users     │
│   Sessions      │  Triggers auto │  Multi-sites     │
└─────────────────┴────────────────┴──────────────────┘
```

---

## ÉTAPE 1 — CRÉER LE PROJET SUPABASE (10 min)

### 1.1 Créer le compte
1. → **https://supabase.com** → **Start your project** → compte gratuit
2. → **New Project**
3. Renseigner :
   - **Name** : `lakota-gueyo`
   - **Database Password** : mot de passe fort (le noter précieusement)
   - **Region** : `West EU (Ireland)` — le plus proche de la Côte d'Ivoire
4. Attendre ~2 min (initialisation)

### 1.2 Récupérer les clés API
→ **Settings** (engrenage) → **API** :

```
Project URL  : https://XXXXXXXXXX.supabase.co      ← copier
anon public  : eyJhbGciOiJIUzI1...                 ← copier (longue clé)
```

⚠️ Ne jamais partager la clé `service_role` — utiliser uniquement `anon`.

---

## ÉTAPE 2 — CRÉER LA BASE DE DONNÉES (15 min)

Aller dans **SQL Editor** → **New Query** → coller + exécuter dans l'ordre :

### Script 1 — Schéma complet
Coller **`sql/01_schema.sql`** → **Run**

Ce script crée :
- `sites`, `profils`, `categories`, `equipements`
- `cuves`, `distributions` (avec champs ratio)
- `releves_compteurs`, `ratios_historique`, `seuils_carburant`
- `approvisionnements`, `mouvements`, `maintenances`, `alertes`
- 3 vues : `vue_dashboard`, `vue_ratios_equip`, `vue_top_conso_30j`
- 6 triggers automatiques

Vérifier le message : **"Success. No rows returned"**

### Script 2 — Sécurité
Coller **`sql/02_rls.sql`** → **Run**

### Script 3 — Données initiales
Coller **`sql/03_seed.sql`** → **Run**

Vérifier : **"148 équipements insérés avec ratios de référence."**

### Vérification
→ **Table Editor** :
- `equipements` → 148 lignes ✓
- `categories` → 7 lignes ✓
- `cuves` → 4 lignes (CC16, CC15, CC13, CC10) ✓
- `seuils_carburant` → 4 lignes ✓

---

## ÉTAPE 3 — CONFIGURER L'APPLICATION (5 min)

Ouvrir `index.html` dans un éditeur de texte.

Trouver les lignes 1-2 du script (vers la ligne 780) :

```javascript
const SUPABASE_URL      = 'VOTRE_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'VOTRE_SUPABASE_ANON_KEY';
```

Remplacer par vos vraies valeurs :

```javascript
const SUPABASE_URL      = 'https://abcdefghij.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiO...';
```

Sauvegarder le fichier.

---

## ÉTAPE 4 — DÉPLOYER SUR VERCEL (5 min)

### Option A — Glisser-déposer (le plus rapide)
1. → **https://vercel.com** → créer compte gratuit (avec email ou GitHub)
2. → **Add New** → **Project**
3. Cliquer **Upload** (pas besoin de GitHub)
4. Glisser-déposer uniquement le fichier **`index.html`**
5. → **Deploy**
6. En 30 secondes : votre URL → ex: `https://lakota-gueyo.vercel.app`

### Option B — Via GitHub (recommandé pour mises à jour)
1. Créer un dépôt GitHub, mettre `index.html` à la racine
2. Vercel → **Import Git Repository** → sélectionner → **Deploy**
3. Chaque commit redéploie automatiquement

### 4.1 Configurer l'URL dans Supabase Auth
→ Supabase → **Authentication** → **URL Configuration** :
- **Site URL** : `https://lakota-gueyo.vercel.app` (votre URL Vercel)
- **Redirect URLs** : ajouter la même URL
→ **Save**

---

## ÉTAPE 5 — CRÉER LES UTILISATEURS (10 min)

### 5.1 Créer le premier compte (Admin)
1. Ouvrir l'application sur Vercel
2. Onglet **"Créer compte"** → renseigner nom, email, mot de passe
3. Se connecter

### 5.2 Assigner rôle Admin et site
→ Supabase → **Table Editor** → table `profils` :
1. Cliquer sur la ligne de votre utilisateur
2. Modifier :
   - `role` → `admin`
   - `site_id` → copier l'UUID depuis la table `sites` (ligne LAKOTA-GUEYO)
3. Sauvegarder

### 5.3 Créer les autres utilisateurs
Répéter pour chaque personne du chantier :

| Utilisateur | Rôle | Accès |
|------------|------|-------|
| Directeur Projet | `admin` | Tout voir, tout modifier |
| Chef de chantier | `responsable` | Saisie + validation |
| Pompiste | `operateur` | Saisie carburant uniquement |
| Auditeur | `lecteur` | Consultation seule |

---

## ÉTAPE 6 — ACTIVER LE TEMPS RÉEL

→ Supabase → **Database** → **Replication** → activer sur :
- ✅ `equipements`
- ✅ `alertes`
- ✅ `cuves`
- ✅ `distributions`

Résultat : toute modification visible instantanément sur tous les postes connectés.

---

## FONCTIONNALITÉS DU MODULE RATIO CARBURANT

### Comment utiliser le module ratio

#### 1. Lors d'une distribution gasoil
Dans **Distribution** → formulaire :

1. Sélectionner l'engin → le système détecte automatiquement le type de mesure
2. Si **Engin Lourd** ou **Groupe Électrogène** → affiche **"Heures début / Heures fin"**
3. Si **Camion / Véhicule Léger** → affiche **"Km début / Km fin"**
4. Renseigner les compteurs → la **preview calcule en temps réel** :
   - Delta (heures ou km parcourus)
   - Ratio calculé (L/h ou L/100km)
   - Comparaison avec la référence constructeur
   - Alerte immédiate si écart > seuil

#### 2. Traitement automatique (trigger SQL)
Lors de l'enregistrement, le trigger `process_distribution()` :
- ✅ Calcule le ratio automatiquement
- ✅ Compare avec le ratio de référence de l'engin
- ✅ Marque la distribution comme "anomalie" si écart > seuil
- ✅ Génère une alerte dans le système
- ✅ Crée une maintenance préventive si écart > 40%
- ✅ Met à jour le compteur actuel de l'engin
- ✅ Déduit la quantité du stock de la cuve

#### 3. Page Ratios & KPIs
Quatre onglets :

**Top Consommateurs** — Volume total + engins avec les pires écarts de ratio

**Engins (L/h)** — Tableau comparatif pour tous les engins horaires :
- Ratio de référence constructeur
- Ratio observé calculé
- Écart en %
- Statut : ✓ Normal / ⚠ Élevé / ▼ Bas

**Véhicules (L/100km)** — Même logique pour camions et VL

**Dérive & Alertes** — Liste des équipements avec écart > 20%

---

## RATIOS DE RÉFÉRENCE PRÉPROGRAMMÉS

| Type d'engin | Ratio réf. | Unité | Tolérance |
|-------------|-----------|-------|----------|
| Bulldozer CATERPILLAR | 24 | L/h | ±25% |
| Bulldozer JOHN DEERE | 22 | L/h | ±25% |
| Pelle Chenille CAT | 17 | L/h | ±25% |
| Pelle Chenille KOMATSU | 18 | L/h | ±25% |
| Pelle Chenille LIEBHERR | 17 | L/h | ±25% |
| Chargeuse CAT | 12 | L/h | ±25% |
| Niveleuse CAT | 15 | L/h | ±25% |
| Compacteur RL BOMAG | 8 | L/h | ±30% |
| Compacteur PM DYNAPAC | 6 | L/h | ±30% |
| Groupe Élec. CAT | 6,5 | L/h | ±20% |
| Groupe Élec. CGM | 5,5 | L/h | ±20% |
| Benne 12R SHACMAN | 42 | L/100km | ±25% |
| Benne 12R SINOTRUK | 40 | L/100km | ±25% |
| Benne 10R SINOTRUK | 35–38 | L/100km | ±25% |
| Pick-up MITSUBISHI | 12 | L/100km | ±25% |
| Camionnette EICHER | 14 | L/100km | ±25% |
| Moto APSONIC | 3,5 | L/100km | ±30% |

Pour modifier un ratio → Supabase → **Table Editor** → `equipements` → colonne `ratio_reference_lh` ou `ratio_reference_l100`.

---

## AJOUT D'UN NOUVEAU SITE (Multi-sites)

```sql
-- Dans Supabase SQL Editor :

INSERT INTO sites (code, nom, localisation)
VALUES ('PK42', 'Chantier PK42', 'Côte d''Ivoire');

INSERT INTO cuves (site_id, code, capacite, stock_actuel, affectation)
SELECT id, 'CC01', 20000, 0, 'Principal'
FROM sites WHERE code = 'PK42';

-- Assigner un utilisateur au nouveau site :
UPDATE profils
SET site_id = (SELECT id FROM sites WHERE code = 'PK42'),
    role = 'responsable'
WHERE email = 'chef.pk42@email.com';
```

---

## MAINTENANCE & ALERTES AUTOMATIQUES

### Ce que le système génère automatiquement

| Déclencheur | Action automatique |
|------------|-------------------|
| Distribution avec écart ratio > seuil | Alerte WARN dans le système |
| Distribution avec écart ratio > 40% | Alerte DANGER + maintenance préventive créée |
| Stock cuve < seuil alerte | Alerte DANGER stock bas |
| Engin passe en état PANNE | Alerte DANGER panne |

### Modifier les seuils d'alerte par défaut
```sql
-- Modifier le seuil d'une cuve (ex: alerter à 5 000 L au lieu de 3 000)
UPDATE cuves SET seuil_alerte = 5000 WHERE code = 'CC16';

-- Modifier la tolérance d'un engin spécifique
UPDATE equipements SET seuil_alerte_pct = 15 WHERE code = 'EXC02';
-- Alerte si écart > 15% (plus strict que les 25% par défaut)
```

---

## EXPORT DES DONNÉES

### Export CSV (depuis l'application)
**Rapports** → sélectionner filtres → **⬇ CSV**
→ Téléchargement direct dans le navigateur

### Export Excel (via Supabase)
→ **Table Editor** → sélectionner la table → **Export** → CSV
→ Ouvrir dans Excel/LibreOffice

### Export PDF
→ **Rapports** → **Générer** → **🖨️ PDF** → impression navigateur → "Enregistrer en PDF"

### Export SQL complet (sauvegarde)
→ **Settings** → **Database** → **Backups** → **Download**

---

## COÛTS

| Service | Plan | Coût |
|---------|------|------|
| Supabase Free | 500 MB DB, 50 000 utilisateurs/mois | **0 €** |
| Vercel Hobby | Illimité pour 1 fichier HTML | **0 €** |
| **TOTAL** | | **0 €/mois** |

Pour aller plus loin :
- **Supabase Pro** : 25 $/mois — 8 GB, sauvegardes 30j, logs avancés
- **Vercel Pro** : 20 $/mois — équipes, domaine custom, analytics

---

## CHECKLIST DÉPLOIEMENT FINAL

- [ ] Compte Supabase créé, projet initialisé
- [ ] `01_schema.sql` exécuté sans erreur
- [ ] `02_rls.sql` exécuté sans erreur
- [ ] `03_seed.sql` exécuté → 148 équipements visibles
- [ ] URL et clé API Supabase insérées dans `index.html`
- [ ] Application déployée sur Vercel → URL fonctionnelle
- [ ] URL Vercel configurée dans Supabase Auth
- [ ] Compte admin créé, rôle et site assignés
- [ ] Replication activée sur `equipements`, `alertes`, `cuves`, `distributions`
- [ ] Test connexion multi-utilisateur (2 onglets)
- [ ] Test saisie distribution avec compteurs → ratio calculé automatiquement
- [ ] Test alerte stock bas (réduire stock d'une cuve manuellement)
- [ ] Test export CSV

---

## SUPPORT TECHNIQUE

- Supabase docs : https://supabase.com/docs
- Vercel docs   : https://vercel.com/docs
- Logs API      : Supabase → Logs Explorer
- Diagnostic SQL: Supabase → SQL Editor → tester les requêtes
