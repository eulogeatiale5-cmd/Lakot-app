-- ================================================================
-- LAKOTA-GUEYO v2 — Données initiales + ratios de référence
-- ================================================================
DO $$
DECLARE
  v_site UUID; v_el UUID; v_ct UUID; v_vl UUID;
  v_mo UUID; v_ge UUID; v_cv UUID; v_in UUID;
BEGIN
  SELECT id INTO v_site FROM sites WHERE code='LAKOTA-GUEYO';
  SELECT id INTO v_el FROM categories WHERE code='ENGIN_LOURD';
  SELECT id INTO v_ct FROM categories WHERE code='CAMION_TRANSPORT';
  SELECT id INTO v_vl FROM categories WHERE code='VEHICULE_LEGER';
  SELECT id INTO v_mo FROM categories WHERE code='MOTO';
  SELECT id INTO v_ge FROM categories WHERE code='GROUPE_ELECTROGENE';
  SELECT id INTO v_cv FROM categories WHERE code='CUVE_GASOIL';
  SELECT id INTO v_in FROM categories WHERE code='INSTALLATION';

  -- CUVES
  INSERT INTO cuves(site_id,code,capacite,stock_actuel,seuil_alerte,affectation) VALUES
    (v_site,'CC16',40000,4147,3000,'Principal'),
    (v_site,'CC15',15000,5000,1500,'Base Vie'),
    (v_site,'CC13',30000,8000,2000,'Base Vie'),
    (v_site,'CC10',2000,1200,300,'Ravitailleur');

  -- ═══ BULLDOZERS — ratio_reference_lh = L/h ═══
  INSERT INTO equipements(site_id,categorie_id,numero,code,type_engin,marque,date_mobilisation,etat,affectation,observation,ratio_reference_lh,seuil_alerte_pct,compteur_actuel) VALUES
    (v_site,v_el,1,'BD02','BULLDOZER','JOHN DEERE','2026-02-07','BON','OUVRAGE','',22.0,25,3200),
    (v_site,v_el,2,'BD06','BULLDOZER','CATERPILLAR','2026-01-14','BON','TERRASSEMENT','',24.0,25,5100),
    (v_site,v_el,3,'BD09','BULLDOZER','CATERPILLAR','2025-11-08','BON','TERRASSEMENT','Retour service 08/05',24.0,25,4890),
    (v_site,v_el,4,'BD10','BULLDOZER','CATERPILLAR','2025-11-08','PANNE','TERRASSEMENT','Transféré PK42 15/04',24.0,25,6230),
    (v_site,v_el,5,'BD11','BULLDOZER','CATERPILLAR','2025-11-08','PANNE','TERRASSEMENT','Panne depuis 15/04',24.0,25,7810),
    (v_site,v_el,6,'BD12','BULLDOZER','CATERPILLAR','2025-11-08','BON','TERRASSEMENT','',24.0,25,5560),
    (v_site,v_el,7,'BD13','BULLDOZER','CATERPILLAR','2026-03-19','BON','OUVRAGE','',22.0,25,1240),
    (v_site,v_el,8,'BD14','BULLDOZER','CATERPILLAR','2026-03-19','BON','TERRASSEMENT','',24.0,25,1890),
    (v_site,v_el,NULL,'BD15','BULLDOZER','CATERPILLAR','2026-04-30','BON','TERRASSEMENT','',24.0,25,320);

  -- AUTO-BETONNIÈRES
  INSERT INTO equipements(site_id,categorie_id,numero,code,type_engin,marque,date_mobilisation,etat,affectation,observation,ratio_reference_lh,seuil_alerte_pct) VALUES
    (v_site,v_el,9,'AB01','AUTO-BETONNIERE','MERLO','2026-03-16','BON','OUVRAGE','BASE VIE',8.0,30),
    (v_site,v_el,10,'AB05','AUTO-BETONNIERE','MERLO','2026-03-16','BON','OUVRAGE','BASE VIE',8.0,30);

  -- PELLES CHENILLES
  INSERT INTO equipements(site_id,categorie_id,numero,code,type_engin,marque,date_mobilisation,etat,affectation,observation,ratio_reference_lh,seuil_alerte_pct,compteur_actuel) VALUES
    (v_site,v_el,11,'EXC02','PELLE CHENILLE','KOMATSU','2026-02-24','BON','TERRASSEMENT','',18.0,25,8764),
    (v_site,v_el,13,'EXC10','PELLE CHENILLE','LIEBHERR','2026-01-07','BON','TERRASSEMENT','',17.0,25,5230),
    (v_site,v_el,14,'EXC11','PELLE CHENILLE','CATERPILLAR','2026-02-21','BON','BLOC TECHNIQUE','',17.0,25,272),
    (v_site,v_el,15,'EXC12','PELLE CHENILLE','CATERPILLAR','2026-02-21','BON','TERRASSEMENT','',17.0,25,1880),
    (v_site,v_el,16,'EXC13','PELLE CHENILLE','CATERPILLAR','2026-03-14','BON','OUVRAGE','',17.0,25,1340),
    (v_site,v_el,17,'EXC14','PELLE CHENILLE','CATERPILLAR','2026-04-18','BON','TERRASSEMENT','BASE VIE',17.0,25,560),
    (v_site,v_el,18,'EXC15','PELLE CHENILLE','CATERPILLAR','2026-04-18','BON','OUVRAGE','BASE VIE',17.0,25,430);

  -- AUTRES ENGINS LOURDS
  INSERT INTO equipements(site_id,categorie_id,numero,code,type_engin,marque,date_mobilisation,etat,affectation,ratio_reference_lh,seuil_alerte_pct) VALUES
    (v_site,v_el,19,'TP03','TRACTOPELLE','CASE','2026-04-26','BON','LABO',7.0,30),
    (v_site,v_el,20,'EXP01','PELLE PNEU','CATERPILLAR','2026-02-16','BON','OUVRAGE',14.0,25);

  -- CHARGEUSES
  INSERT INTO equipements(site_id,categorie_id,numero,code,type_engin,marque,date_mobilisation,etat,affectation,ratio_reference_lh,seuil_alerte_pct,compteur_actuel) VALUES
    (v_site,v_el,21,'CHP01','CHARGEUSE','CATERPILLAR','2025-12-03','BON','CENTRALE BETON PK25',12.0,25,4210),
    (v_site,v_el,22,'CHP04','CHARGEUSE','CATERPILLAR','2026-04-22','BON','BASE VIE',12.0,25,340),
    (v_site,v_el,23,'CHP05','CHARGEUSE','CATERPILLAR','2026-02-07','PANNE','','Panne 08/04',12.0,25,1560),
    (v_site,v_el,24,'CHP11','CHARGEUSE','CATERPILLAR','2026-04-03','BON','TERRASSEMENT',12.0,25,780),
    (v_site,v_el,25,'CHP12','CHARGEUSE','CATERPILLAR','2026-04-03','BON','TERRASSEMENT',12.0,25,650),
    (v_site,v_el,26,'CHP13','CHARGEUSE','CATERPILLAR','2026-04-11','BON','TERRASSEMENT',12.0,25,490),
    (v_site,v_el,27,'CHP14','CHARGEUSE','CATERPILLAR','2026-04-11','BON','TERRASSEMENT',12.0,25,510),
    (v_site,v_el,28,'CHP15','CHARGEUSE','CATERPILLAR','2026-04-15','BON','TERRASSEMENT',12.0,25,420),
    (v_site,v_el,29,'CHP16','CHARGEUSE','CATERPILLAR','2026-04-15','BON','TERRASSEMENT',12.0,25,380),
    (v_site,v_el,30,'CHP17','CHARGEUSE','CATERPILLAR','2026-04-15','BON','OUVRAGE',12.0,25,390);

  -- COMPACTEURS
  INSERT INTO equipements(site_id,categorie_id,numero,code,type_engin,marque,date_mobilisation,etat,affectation,ratio_reference_lh,seuil_alerte_pct) VALUES
    (v_site,v_el,31,'CPM01','COMPACTEUR RL','BOMAG','2025-11-18','BON','TERRASSEMENT',8.0,30),
    (v_site,v_el,32,'CPM03','COMPACTEUR RL','BOMAG','2025-12-10','BON','TERRASSEMENT',8.0,30),
    (v_site,v_el,33,'CPM09','COMPACTEUR RL','BOMAG','2026-04-21','BON','TERRASSEMENT',8.0,30),
    (v_site,v_el,34,'CPM11','COMPACTEUR RL','BOMAG','2026-02-06','BON','TERRASSEMENT',8.0,30),
    (v_site,v_el,35,'CPM04','COMPACTEUR PM','DYNAPAC','2026-04-17','BON','TERRASSEMENT',6.0,30),
    (v_site,v_el,36,'CPM07','COMPACTEUR PM','DYNAPAC','2025-12-10','BON','TERRASSEMENT',6.0,30),
    (v_site,v_el,37,'CPM10','COMPACTEUR PM','DYNAPAC','2026-02-07','BON','TERRASSEMENT',6.0,30),
    (v_site,v_el,38,'CPT09','COMPACTEUR MAIN','BOMAG','2026-01-07','BON','TERRASSEMENT',3.0,35);

  -- NIVELEUSES
  INSERT INTO equipements(site_id,categorie_id,numero,code,type_engin,marque,date_mobilisation,etat,affectation,ratio_reference_lh,seuil_alerte_pct,compteur_actuel) VALUES
    (v_site,v_el,39,'NV01','NIVELEUSE','JOHN DEERE','2026-02-07','BON','TERRASSEMENT',16.0,25,6907),
    (v_site,v_el,40,'NV07','NIVELEUSE','CATERPILLAR','2025-12-07','BON','TERRASSEMENT',15.0,25,3890),
    (v_site,v_el,41,'NV11','NIVELEUSE','CATERPILLAR','2026-01-26','BON','TERRASSEMENT',15.0,25,2340),
    (v_site,v_el,42,'NV12','NIVELEUSE','CATERPILLAR','2026-02-21','BON','TERRASSEMENT',15.0,25,161),
    (v_site,v_el,43,'NV13','NIVELEUSE','CATERPILLAR','2026-02-21','BON','TERRASSEMENT',15.0,25,200),
    (v_site,v_el,44,'NV14','NIVELEUSE','CATERPILLAR','2026-03-23','BON','TERRASSEMENT',15.0,25,980),
    (v_site,v_el,45,'NV15','NIVELEUSE','CATERPILLAR','2026-04-03','BON','TERRASSEMENT','BASE VIE',15.0,25,560);

  -- CHARIOTS + MATS + RECYCLEUSE
  INSERT INTO equipements(site_id,categorie_id,numero,code,type_engin,marque,date_mobilisation,etat,affectation,ratio_reference_lh) VALUES
    (v_site,v_el,46,'EL02','CHARIOT TELESCOPIQUE','MERLO','2026-04-17','BON','DIVERS TRAVAUX',6.0),
    (v_site,v_el,47,'EL03','CHARIOT TELESCOPIQUE','MERLO','2026-02-02','PANNE','DIVERS TRAVAUX',6.0),
    (v_site,v_el,48,'TE01','MAT ECLAIRAGE','CATERPILLAR','2026-02-16','BON','DIVERS TRAVAUX',2.0),
    (v_site,v_el,49,'TE02','MAT ECLAIRAGE','','2026-02-16','BON','DIVERS TRAVAUX',2.0),
    (v_site,v_el,50,'TE03','MAT ECLAIRAGE','','2026-02-28','BON','DIVERS TRAVAUX',2.0),
    (v_site,v_el,51,'TE04','MAT ECLAIRAGE','','2026-05-08','BON','OUVRAGE',2.0),
    (v_site,v_el,52,'RC01','RECYCLEUSE','BOMAG','2025-12-10','BON','STAND BY',20.0);

  -- BENNES 10 ROUES — ratio L/100km
  INSERT INTO equipements(site_id,categorie_id,numero,code,type_engin,marque,date_mobilisation,etat,affectation,ratio_reference_l100,seuil_alerte_pct,compteur_actuel) VALUES
    (v_site,v_ct,53,'CB03','BENNE 10 ROUES','SINOTRUK','2025-09-11','BON','TRANSPORT PERSONNEL',35.0,25,142000),
    (v_site,v_ct,54,'CB07','BENNE 10 ROUES','SINOTRUK','2026-02-18','BON','TRANSPORT PERSONNEL',35.0,25,68000),
    (v_site,v_ct,55,'CB04','BENNE 10 ROUES','SINOTRUK','2026-03-07','BON','CAMION ENTRETIEN',38.0,25,52000),
    (v_site,v_ct,56,'CB06','BENNE 10 ROUES','SINOTRUK','2026-01-15','BON','CAMION ENTRETIEN',38.0,25,89000),
    (v_site,v_ct,57,'CB09','BENNE 10 ROUES','SINOTRUK','2025-08-12','BON','RAVITAILLEUR',35.0,25,178000);

  -- BENNES 12 ROUES SHACMAN
  INSERT INTO equipements(site_id,categorie_id,numero,code,type_engin,marque,date_mobilisation,etat,affectation,ratio_reference_l100,seuil_alerte_pct) VALUES
    (v_site,v_ct,58,'CBC01','BENNE 12 ROUES','SHACMAN','2026-03-15','BON','TERRASSEMENT',42.0,25),
    (v_site,v_ct,59,'CBC02','BENNE 12 ROUES','SHACMAN','2026-03-15','BON','TERRASSEMENT',42.0,25),
    (v_site,v_ct,60,'CBC03','BENNE 12 ROUES','SHACMAN','2026-03-15','BON','TERRASSEMENT',42.0,25),
    (v_site,v_ct,61,'CBC04','BENNE 12 ROUES','SHACMAN','2026-04-04','BON','TERRASSEMENT',42.0,25),
    (v_site,v_ct,62,'CBC05','BENNE 12 ROUES','SHACMAN','2026-03-15','BON','TERRASSEMENT',42.0,25),
    (v_site,v_ct,63,'CBC06','BENNE 12 ROUES','SHACMAN','2026-03-15','BON','TERRASSEMENT',42.0,25),
    (v_site,v_ct,64,'CBC07','BENNE 12 ROUES','SHACMAN','2026-03-15','BON','TERRASSEMENT',42.0,25),
    (v_site,v_ct,65,'CBC08','BENNE 12 ROUES','SHACMAN','2026-03-15','BON','TERRASSEMENT',42.0,25),
    (v_site,v_ct,66,'CBC09','BENNE 12 ROUES','SHACMAN','2026-03-15','BON','TERRASSEMENT',42.0,25),
    (v_site,v_ct,67,'CBC10','BENNE 12 ROUES','SHACMAN','2026-04-22','BON','TERRASSEMENT',42.0,25),
    (v_site,v_ct,68,'CBC11','BENNE 12 ROUES','SHACMAN','2026-03-15','BON','TERRASSEMENT',42.0,25),
    (v_site,v_ct,69,'CBC12','BENNE 12 ROUES','SHACMAN','2026-03-15','BON','TERRASSEMENT',42.0,25),
    (v_site,v_ct,70,'CBC13','BENNE 12 ROUES','SHACMAN','2026-03-15','BON','TERRASSEMENT',42.0,25),
    (v_site,v_ct,71,'CBC14','BENNE 12 ROUES','SHACMAN','2026-03-15','BON','TERRASSEMENT',42.0,25),
    (v_site,v_ct,72,'CBC15','BENNE 12 ROUES','SHACMAN','2026-03-15','BON','TERRASSEMENT',42.0,25),
    (v_site,v_ct,73,'CBC16','BENNE 12 ROUES','SHACMAN','2026-03-15','BON','TERRASSEMENT',42.0,25),
    (v_site,v_ct,74,'CBC17','BENNE 12 ROUES','SHACMAN','2026-03-15','BON','TERRASSEMENT',42.0,25),
    (v_site,v_ct,75,'CBC18','BENNE 12 ROUES','SHACMAN','2026-03-15','BON','TERRASSEMENT',42.0,25),
    (v_site,v_ct,76,'CBC19','BENNE 12 ROUES','SHACMAN','2026-03-15','BON','TERRASSEMENT',42.0,25),
    (v_site,v_ct,77,'CBC20','BENNE 12 ROUES','SHACMAN','2026-03-15','BON','OUVRAGE',42.0,25);

  -- BENNES 12 ROUES SINOTRUK
  INSERT INTO equipements(site_id,categorie_id,numero,code,type_engin,marque,date_mobilisation,etat,affectation,ratio_reference_l100,seuil_alerte_pct) VALUES
    (v_site,v_ct,78,'CB11','BENNE 12 ROUES','SINOTRUK','2025-12-09','BON','OUVRAGE',40.0,25),
    (v_site,v_ct,79,'CB16','BENNE 12 ROUES','SINOTRUK','2026-02-07','BON','OUVRAGE',40.0,25),
    (v_site,v_ct,80,'CB17','BENNE 12 ROUES','SINOTRUK','2025-12-09','BON','OUVRAGE',40.0,25),
    (v_site,v_ct,81,'CB18','BENNE 12 ROUES','SINOTRUK','2026-02-07','BON','OUVRAGE',40.0,25),
    (v_site,v_ct,82,'CB19','BENNE 12 ROUES','SINOTRUK','2025-12-09','BON','OUVRAGE',40.0,25),
    (v_site,v_ct,83,'CB20','BENNE 12 ROUES','SINOTRUK','2025-12-09','PANNE','OUVRAGE','Panne 04/05',40.0,25),
    (v_site,v_ct,84,'CB21','BENNE 12 ROUES','SINOTRUK','2025-11-23','BON','OUVRAGE',40.0,25),
    (v_site,v_ct,85,'CB25','BENNE 12 ROUES','SINOTRUK','2025-12-09','PANNE','OUVRAGE','Panne 04/05',40.0,25),
    (v_site,v_ct,86,'CB28','BENNE 12 ROUES','SINOTRUK','2025-11-23','BON','OUVRAGE',40.0,25),
    (v_site,v_ct,87,'CB29','BENNE 12 ROUES','SINOTRUK','2025-12-09','BON','OUVRAGE',40.0,25);

  -- CITERNES & CAMIONS GRUE
  INSERT INTO equipements(site_id,categorie_id,numero,code,type_engin,marque,date_mobilisation,etat,affectation,ratio_reference_l100) VALUES
    (v_site,v_ct,88,'CCE01','CITERNE A EAU','SINOTRUK','2026-01-22','BON','TERRASSEMENT',32.0),
    (v_site,v_ct,89,'CCE02','CITERNE A EAU','SINOTRUK','2026-02-10','BON','TERRASSEMENT',32.0),
    (v_site,v_ct,90,'CCE04','CITERNE A EAU','SINOTRUK','2026-01-24','BON','TERRASSEMENT',32.0),
    (v_site,v_ct,91,'CPG02','CAMION GRUE','SINOTRUK','2026-04-24','PANNE','LOGISTIQUE',30.0),
    (v_site,v_ct,92,'CPG03','CAMION GRUE','SINOTRUK','2026-02-28','BON','OUVRAGE',30.0),
    (v_site,v_ct,93,'CPG04','CAMION GRUE','SINOTRUK','2025-12-09','BON','DIVERS TRAVAUX',30.0);

  -- TOUPIES & PORTE-CHARS
  INSERT INTO equipements(site_id,categorie_id,numero,code,type_engin,marque,date_mobilisation,etat,affectation,ratio_reference_l100) VALUES
    (v_site,v_ct,94,'CT01','CAMION TOUPIE','SINOTRUK','2026-04-14','BON','OUVRAGE',35.0),
    (v_site,v_ct,95,'CT02','CAMION TOUPIE','SINOTRUK','2026-04-14','BON','OUVRAGE',35.0),
    (v_site,v_ct,96,'CT03','CAMION TOUPIE','SINOTRUK','2026-03-03','BON','OUVRAGE',35.0),
    (v_site,v_ct,97,'CT05','CAMION TOUPIE','SINOTRUK','2025-12-09','BON','OUVRAGE',35.0),
    (v_site,v_ct,98,'CT06','CAMION TOUPIE','SINOTRUK','2025-12-09','BON','OUVRAGE',35.0),
    (v_site,v_ct,99,'TR02','PORTE-CHAR','SINOTRUK','2026-04-22','BON','MOUVEMENT ENGIN',28.0),
    (v_site,v_ct,100,'TR05','PORTE-CHAR','SINOTRUK','2025-12-17','BON','MOUVEMENT ENGIN',28.0);

  -- CUVES ÉQUIPEMENTS
  INSERT INTO equipements(site_id,categorie_id,numero,code,type_engin,marque,date_mobilisation,etat,affectation) VALUES
    (v_site,v_cv,101,'CC10','CUVE A GASOIL','XXX','2025-09-17','BON','RAVITAILLEUR'),
    (v_site,v_cv,102,'CC13','CUVE A GASOIL','XXX','2025-09-17','BON','BASE VIE'),
    (v_site,v_cv,103,'CC15','CUVE A GASOIL','XXX','2025-09-17','BON','BASE VIE'),
    (v_site,v_cv,104,'CC(4000L)','CUVE A GASOIL','XXX','2026-03-07','BON','RAVITAILLEUR');

  -- VÉHICULES LÉGERS — ratio L/100km
  INSERT INTO equipements(site_id,categorie_id,numero,code,type_engin,marque,date_mobilisation,etat,affectation,observation,ratio_reference_l100,seuil_alerte_pct,compteur_actuel) VALUES
    (v_site,v_vl,105,'VL 04','PICK-UP','TOYOTA','2026-04-18','BON','INFIRMIER','',12.0,25,8900),
    (v_site,v_vl,106,'VL 12','PICK-UP','MITSUBISHI','2026-02-18','BON','LOGISTIQUE','',12.0,25,42000),
    (v_site,v_vl,107,'VL 14','PICK-UP','MITSUBISHI','2025-08-03','BON','Chef Équipe Mécano','',12.0,25,98000),
    (v_site,v_vl,108,'VL 24','PICK-UP','MITSUBISHI','2026-01-12','BON','OUVRAGE','',12.0,25,61000),
    (v_site,v_vl,109,'VL 34','PICK-UP','MITSUBISHI','2025-09-17','BON','Chef Brigade Topo','',12.0,25,87000),
    (v_site,v_vl,110,'VL 37','PICK-UP','MITSUBISHI','2026-01-12','BON','Conducteur Travaux','',12.0,25,55000),
    (v_site,v_vl,111,'VL 41','PICK-UP','ISUZU','2026-03-07','BON','Responsable TOP','',11.0,25,38000),
    (v_site,v_vl,112,'VL 43','PICK-UP','MITSUBISHI','2025-09-18','BON','Responsable Atelier','',12.0,25,92000),
    (v_site,v_vl,113,'VL 52','PICK-UP','MITSUBISHI','2025-10-01','BON','Chef Brigade Topo','',12.0,25,78000),
    (v_site,v_vl,114,'VL 60','PICK-UP','MITSUBISHI','2026-03-23','BON','Responsable Industrie','',12.0,25,31000),
    (v_site,v_vl,115,'VL 51','PICK-UP','MITSUBISHI','2026-05-06','PANNE','LOGISTIQUE','Panne chauffage/clim',12.0,25,19000),
    (v_site,v_vl,116,'VL 66','PICK-UP','MITSUBISHI','2026-03-07','BON','Conducteur Travaux Ouvrage','',12.0,25,33000),
    (v_site,v_vl,117,'VL 69','PICK-UP','MITSUBISHI','2026-03-07','BON','Responsable Étude','',12.0,25,29000),
    (v_site,v_vl,118,'VL 72','PICK-UP','MITSUBISHI','2025-09-18','BON','Coordinateur HSE','',12.0,25,81000),
    (v_site,v_vl,119,'VL 81','PICK-UP','MITSUBISHI','2025-09-09','PANNE','Chef Labo Géotech','Transféré CFAO 27/01',12.0,25,110000),
    (v_site,v_vl,120,'VL 82','PICK-UP','MITSUBISHI','2025-10-05','BON','Responsable Labo','',12.0,25,96000),
    (v_site,v_vl,121,'VL 84','PICK-UP','MITSUBISHI','2025-10-28','PANNE','Directeur Projet','Transféré PK42 02/04',12.0,25,108000),
    (v_site,v_vl,122,'VL 86','PICK-UP','MITSUBISHI','2026-03-25','BON','Responsable HSE','',12.0,25,27000),
    (v_site,v_vl,123,'VL 87','PICK-UP','MITSUBISHI','2026-02-12','BON','Ingénieur Labo','',12.0,25,44000),
    (v_site,v_vl,124,'VL 88','PICK-UP','MITSUBISHI','2026-03-04','BON','Conducteur Travaux Terrassement','',12.0,25,36000),
    (v_site,v_vl,125,'VL 90','PICK-UP','MITSUBISHI','2026-01-27','BON','Conducteur Travaux Ouvrage','',12.0,25,58000),
    (v_site,v_vl,126,'VL 91','PICK-UP','MITSUBISHI','2026-03-12','BON','Directeur Projet Adjoint','',12.0,25,34000),
    (v_site,v_vl,127,'VL 94','PICK-UP','MITSUBISHI','2026-03-04','BON','Ingénieur TOPO','',12.0,25,37000),
    (v_site,v_vl,128,'VL 54','DUSTER','RENAULT','2026-05-11','BON','CONTROLEUR TECHNIQUE','',10.0,25,12000);

  -- CAMIONNETTES
  INSERT INTO equipements(site_id,categorie_id,numero,code,type_engin,marque,date_mobilisation,etat,affectation,ratio_reference_l100,seuil_alerte_pct) VALUES
    (v_site,v_vl,129,'CN13','CAMIONNETTE','EICHER','2025-12-09','BON','LABO',14.0,25),
    (v_site,v_vl,130,'CN15','CAMIONNETTE','EICHER','2026-03-02','BON','HSE',14.0,25),
    (v_site,v_vl,131,'CN16','CAMIONNETTE','EICHER','2026-05-07','BON','TOPO',14.0,25),
    (v_site,v_vl,132,'CN17','CAMIONNETTE','EICHER','2026-05-08','BON','CENTRALE BETON PK25',14.0,25);

  -- GROUPES ÉLECTROGÈNES — ratio L/h
  INSERT INTO equipements(site_id,categorie_id,numero,code,type_engin,marque,date_mobilisation,etat,affectation,ratio_reference_lh,seuil_alerte_pct,compteur_actuel) VALUES
    (v_site,v_ge,133,'GE05','GROUPE ELECTROGENE','CATERPILLAR','2025-11-21','BON','CENTRALE BETON PK25',6.5,20,11316),
    (v_site,v_ge,134,'GE25','GROUPE ELECTROGENE','CHIMAISA','2026-01-07','BON','BASE VIE',5.0,20,3200),
    (v_site,v_ge,135,'GE26','GROUPE ELECTROGENE','CGM','2026-01-12','BON','BASE VIE',5.5,20,1174),
    (v_site,v_ge,136,'GE XX-F','GROUPE ELECTROGENE','FANTASTIQUE','2026-01-15','BON','PLATEFORME',4.0,25,2100),
    (v_site,v_ge,137,'GE XX-I','GROUPE ELECTROGENE','INGCO','2025-11-08','BON','RAVITAILLEUR',3.5,25,4800);

  -- MOTOS
  INSERT INTO equipements(site_id,categorie_id,numero,code,type_engin,marque,date_mobilisation,etat,affectation,ratio_reference_l100,seuil_alerte_pct) VALUES
    (v_site,v_mo,138,'ML10','MOTO','APSONIC','2026-04-06','BON','ELECTRICIEN',3.5,30),
    (v_site,v_mo,139,'ML-A','MOTO','APSONIC','2026-04-27','BON','OUVRAGE',3.5,30),
    (v_site,v_mo,140,'ML-B','MOTO','APSONIC','2026-04-27','BON','MECANICIEN',3.5,30),
    (v_site,v_mo,141,'ML14','MOTO','APSONIC','2025-11-08','BON','ELECTRICIEN',3.5,30),
    (v_site,v_mo,142,'ML28','MOTO','LEOPARD','2025-11-08','BON','LABO',4.0,30),
    (v_site,v_mo,143,'ML21','MOTO','APSONIC','2025-11-08','BON','POMPISTE',3.5,30),
    (v_site,v_mo,144,'MT32','MOTO','APSONIC','2026-03-02','BON','LABO',3.5,30),
    (v_site,v_mo,145,'MT33','MOTO','APSONIC','2025-11-08','BON','RH',3.5,30),
    (v_site,v_mo,146,'MT35','MOTO','APSONIC','2025-11-08','BON','LABO',3.5,30),
    (v_site,v_mo,147,'MT39','MOTO','APSONIC','2026-03-04','BON','SERVICE INDUSTRIE',3.5,30);

  -- INSTALLATIONS
  INSERT INTO equipements(site_id,categorie_id,numero,code,type_engin,marque,date_mobilisation,etat,affectation) VALUES
    (v_site,v_in,148,'PIB 01','CENTRALE A BETON','XXX','2025-11-21','BON','PRODUCTION BETON'),
    (v_site,v_in,149,'PTB01','PONT BASCUL','XXX','2025-11-21','PANNE','SERVICE INDUSTRIE');

  RAISE NOTICE '148 équipements insérés avec ratios de référence.';
END $$;
