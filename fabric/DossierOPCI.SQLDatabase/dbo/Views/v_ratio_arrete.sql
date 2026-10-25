-- 2. Les 3 vues
-- --- n° 13 a 16 : v_ratio_arrete ----------------------------------------
CREATE   VIEW dbo.v_ratio_arrete AS
-- L'ACTIF SE LIT DE LA BALANCE, non de dbo.v_patrimoine_valorise :
-- celle-ci ne porte que les 4 familles d'actifs valorises, sans les
-- liquidites du compte 511 ni les depots. La balance porte en outre les
-- differences d'estimation aux comptes 27x : la somme du compte d'actif
-- et de sa difference EST la valeur actuelle, ce que l'article 113-2 du
-- reglement ANC 2021-09 prescrit.
--
-- n° 13 : seules les entites qui portent une forme de vehicule (SPPICAV
-- ou FPI) rendent des ratios ; L. 214-37 et L. 214-39 visent l'actif et
-- les emprunts d'un OPCI, non ceux de ses filiales.
--
-- n° 14, R. 214-89 : au denominateur des 60 % et 51 %, les actifs des 1°,
-- 4° et 6° a 9° detenus directement, ceux des societes des 2° et 3° au
-- prorata, les participations relevant de R. 214-85 et celles dans les
-- organismes du 5° ; les avances en compte courant (10°) n'y sont pas.
-- Une filiale est lue par transparence quand elle n'est pas un vehicule
-- et que v_eligibilite_participation ne la declare pas ineligible ; une
-- filiale ineligible (eligible = 0) releve de R. 214-85 et compte pour
-- la valeur actuelle de ses titres (v_patrimoine_valorise, famille
-- TITRE). Les titres des filiales lues par transparence et leurs
-- differences d'estimation (252, 254, 275) sortent du denominateur :
-- leurs actifs y entrent a leur place. La detention en base est directe
-- (aucune filiale n'est mere, releve du 11/10/2026).
--
-- n° 15, R. 214-104 : au denominateur du 40 %, les immeubles directs, y
-- compris en credit-bail (comptes 21 a 24 et 271 a 274), ceux des
-- filiales lues par transparence au prorata, les participations de
-- R. 214-85 et les biens des organismes du 5° au prorata ; au numerateur,
-- les emprunts et les dettes de credit-bail. Aucun compte du plan de
-- l'article 411-3 ne porte la dette de credit-bail : credit_bail_dettes
-- vaut 0. Les organismes du 5° ne se lisent au prorata que s'ils sont
-- des entites de la base (detention vers une entite qui porte une forme
-- de vehicule).
--
-- n° 16 : le 5 % compte la categorie 8 et le 511, hors du 5118 (R. 214-100,
-- R. 214-94, 1°) ; les comptes 41, 42, 44 et 46 n'entrent au 9° que pour
-- leur solde debiteur, compte par compte. Le denominateur du 5 % reste
-- l'actif de la balance propre, categories 1 a 10.
WITH vehicule AS (
    SELECT r.entite, r.arrete, en.forme_vehicule
    FROM dbo.ref_arrete r
    JOIN dbo.ref_entite en ON en.code = r.entite
    WHERE en.forme_vehicule IS NOT NULL
),
solde AS (
    SELECT l.entite, l.arrete, e.compte_num,
           SUM(e.debit - e.credit) AS solde
    FROM dbo.v_ecriture_normalisee e
    JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
    GROUP BY l.entite, l.arrete, e.compte_num
),
categorise AS (
    SELECT sd.entite, sd.arrete, sd.compte_num, sd.solde, k.rang,
           CASE WHEN k.rang = 9 AND sd.compte_num NOT LIKE '511%' AND sd.solde < 0
                THEN 0 ELSE sd.solde END            AS montant
    FROM solde sd
    CROSS APPLY (
        -- La difference d'estimation suit l'actif qu'elle porte : le
        -- 271 a 274 suit le 21x a 24x, le 275 le 25x, le 276 le 266.
        SELECT COALESCE(c.rang,
                        CASE WHEN sd.compte_num LIKE '271%'
                               OR sd.compte_num LIKE '272%'
                               OR sd.compte_num LIKE '273%'
                               OR sd.compte_num LIKE '274%' THEN 1
                             WHEN sd.compte_num LIKE '275%' THEN 2
                             WHEN sd.compte_num LIKE '276%' THEN 10
                             ELSE NULL END) AS rang
        FROM (SELECT 1 AS un) u
        OUTER APPLY (
            SELECT TOP 1 x.rang FROM dbo.ref_categorie_actif_cmf x
            CROSS APPLY STRING_SPLIT(x.racines, ',') t
            WHERE sd.compte_num LIKE t.value + '%'
            ORDER BY LEN(t.value) DESC
        ) AS c
    ) AS k
),
actif AS (
    SELECT g.entite, g.arrete,
           SUM(CASE WHEN g.rang BETWEEN 1 AND 5 THEN g.montant ELSE 0 END)
                                                  AS immobilier_1_a_5,
           SUM(CASE WHEN g.rang IN (1, 2, 3, 5) THEN g.montant ELSE 0 END)
                                                  AS non_cote_1_3_5,
           SUM(CASE WHEN g.rang IN (8, 9) THEN g.montant ELSE 0 END)
                                                  AS liquidites_8_9,
           SUM(CASE WHEN g.rang IS NOT NULL THEN g.montant ELSE 0 END)
                                                  AS actif_total,
           SUM(CASE WHEN g.rang = 1 THEN g.montant ELSE 0 END)
                                                  AS rang_1,
           SUM(CASE WHEN g.rang = 4 THEN g.montant ELSE 0 END)
                                                  AS rang_4,
           SUM(CASE WHEN g.rang = 5 THEN g.montant ELSE 0 END)
                                                  AS rang_5,
           SUM(CASE WHEN g.rang IN (1, 4, 6, 7, 8, 9) THEN g.montant ELSE 0 END)
                                                  AS rangs_1_4_6_a_9,
           SUM(CASE WHEN g.rang = 8
                      OR (g.compte_num LIKE '511%' AND g.compte_num NOT LIKE '5118%')
                    THEN g.montant ELSE 0 END)    AS liquidites_r214_100
    FROM categorise g
    JOIN vehicule v ON v.entite = g.entite AND v.arrete = g.arrete
    GROUP BY g.entite, g.arrete
),
filiale_transparente AS (
    SELECT d.entite_mere, d.entite_fille, d.arrete, d.quote_part
    FROM dbo.detention d
    JOIN dbo.ref_entite f ON f.code = d.entite_fille
    WHERE f.forme_vehicule IS NULL
      AND NOT EXISTS (SELECT 1 FROM dbo.v_eligibilite_participation p
                      WHERE p.entite_mere = d.entite_mere
                        AND p.entite_fille = d.entite_fille
                        AND p.eligible = 0)
),
transparence AS (
    SELECT ft.entite_mere AS entite, ft.arrete,
           SUM(CASE WHEN g.rang IN (1, 4, 6, 7, 8, 9)
                    THEN g.montant * ft.quote_part ELSE 0 END) AS actifs_filiales_quote_part,
           SUM(CASE WHEN g.rang = 1
                    THEN g.montant * ft.quote_part ELSE 0 END) AS immeubles_filiales_r214_89
    FROM filiale_transparente ft
    JOIN categorise g ON g.entite = ft.entite_fille AND g.arrete = ft.arrete
    GROUP BY ft.entite_mere, ft.arrete
),
r214_85 AS (
    SELECT pv.entite, pv.arrete, SUM(pv.valeur_actuelle) AS montant
    FROM dbo.v_patrimoine_valorise pv
    JOIN dbo.v_eligibilite_participation p
      ON p.entite_mere = pv.entite AND p.entite_fille = pv.entite_liee
     AND p.eligible = 0
    WHERE pv.famille = 'TITRE'
    GROUP BY pv.entite, pv.arrete
),
dette AS (
    -- LES EMPRUNTS EXTERIEURS SEULS, arbitrage du candidat du
    -- 04/09/2026 : comptes 512 emprunts lies a des actifs immobiliers,
    -- 513 autres emprunts et 164 emprunts aupres des etablissements de
    -- credit. Le compte 4551, dette envers la mere, est EXCLU : le
    -- compter reviendrait a compter 2 fois la ressource que l'OPCI a
    -- levee puis pretee. Les dettes de toutes les filiales et des
    -- organismes du 5° de la base comptent au prorata (R. 214-104, 2°, b).
    SELECT v.entite, v.arrete,
           COALESCE(propre.montant, 0)             AS emprunts_propres,
           COALESCE(filiales.montant, 0)           AS emprunts_filiales_quote_part
    FROM vehicule v
    OUTER APPLY (
        SELECT SUM(e.credit - e.debit) AS montant
        FROM dbo.v_ecriture_normalisee e
        JOIN dbo.lot_ecritures l ON l.id = e.lot_id
        WHERE l.entite = v.entite AND l.arrete = v.arrete
          AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
          AND (e.compte_num LIKE '512%' OR e.compte_num LIKE '513%'
               OR e.compte_num LIKE '164%')
          -- L'EMPRUNT INTRAGROUPE SE RECONNAIT A SON COMPTE AUXILIAIRE,
          -- qui porte le code de l'entite preteuse. Mesure du
          -- 04/09/2026 : les 12 filiales portent 114 800 000,00 au seul
          -- compte 512, dont 74 620 000,00 avec le compte auxiliaire
          -- OMEGA-OPCI et 40 180 000,00 sans. Le plan de comptes seul ne
          -- distingue donc pas le bancaire de l'interne, la
          -- correspondance du script 92 ayant traduit le 4551 du PCG en
          -- 512 du plan de l'article 411-3.
          AND NOT EXISTS (SELECT 1 FROM dbo.ref_entite x
                          WHERE x.code = e.comp_aux_num)
    ) AS propre
    OUTER APPLY (
        SELECT SUM((e.credit - e.debit) * d.quote_part) AS montant
        FROM dbo.detention d
        JOIN dbo.lot_ecritures l ON l.entite = d.entite_fille
                                AND l.arrete = d.arrete
                                AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
        JOIN dbo.v_ecriture_normalisee e ON e.lot_id = l.id
        WHERE d.entite_mere = v.entite AND d.arrete = v.arrete
          AND (e.compte_num LIKE '512%' OR e.compte_num LIKE '513%'
               OR e.compte_num LIKE '164%')
          AND NOT EXISTS (SELECT 1 FROM dbo.ref_entite x
                          WHERE x.code = e.comp_aux_num)
    ) AS filiales
),
immeubles AS (
    -- LA VALEUR DES IMMEUBLES DETENUS, MULTIPLIEE PAR LE TAUX DE
    -- DETENTION, second arbitrage du candidat. Les immeubles en direct,
    -- plus ceux de chaque filiale lue par transparence a la quote-part
    -- (R. 214-104, 1°, a et b), plus ceux des organismes du 5° de la
    -- base au prorata (1°, d). Les TITRES de filiales n'y entrent pas :
    -- ils representent ces memes immeubles. Comptes 21 a 24, contrats de
    -- credit-bail compris, et 271 a 274.
    SELECT v.entite, v.arrete,
           COALESCE(direct.montant, 0)             AS immeubles_directs,
           COALESCE(indirect.montant, 0)           AS immeubles_quote_part,
           COALESCE(org5.montant, 0)               AS organismes_5_quote_part
    FROM vehicule v
    OUTER APPLY (
        SELECT SUM(e.debit - e.credit) AS montant
        FROM dbo.v_ecriture_normalisee e
        JOIN dbo.lot_ecritures l ON l.id = e.lot_id
        WHERE l.entite = v.entite AND l.arrete = v.arrete
          AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
          AND (e.compte_num LIKE '21%' OR e.compte_num LIKE '22%'
               OR e.compte_num LIKE '23%' OR e.compte_num LIKE '24%'
               OR e.compte_num LIKE '271%' OR e.compte_num LIKE '272%'
               OR e.compte_num LIKE '273%' OR e.compte_num LIKE '274%')
    ) AS direct
    OUTER APPLY (
        SELECT SUM((e.debit - e.credit) * ft.quote_part) AS montant
        FROM filiale_transparente ft
        JOIN dbo.lot_ecritures l ON l.entite = ft.entite_fille
                                AND l.arrete = ft.arrete
                                AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
        JOIN dbo.v_ecriture_normalisee e ON e.lot_id = l.id
        WHERE ft.entite_mere = v.entite AND ft.arrete = v.arrete
          AND (e.compte_num LIKE '21%' OR e.compte_num LIKE '22%'
               OR e.compte_num LIKE '23%' OR e.compte_num LIKE '24%'
               OR e.compte_num LIKE '271%' OR e.compte_num LIKE '272%'
               OR e.compte_num LIKE '273%' OR e.compte_num LIKE '274%')
    ) AS indirect
    OUTER APPLY (
        SELECT SUM((e.debit - e.credit) * d.quote_part) AS montant
        FROM dbo.detention d
        JOIN dbo.ref_entite f ON f.code = d.entite_fille
                             AND f.forme_vehicule IS NOT NULL
        JOIN dbo.lot_ecritures l ON l.entite = d.entite_fille
                                AND l.arrete = d.arrete
                                AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
        JOIN dbo.v_ecriture_normalisee e ON e.lot_id = l.id
        WHERE d.entite_mere = v.entite AND d.arrete = v.arrete
          AND (e.compte_num LIKE '21%' OR e.compte_num LIKE '22%'
               OR e.compte_num LIKE '23%' OR e.compte_num LIKE '24%'
               OR e.compte_num LIKE '271%' OR e.compte_num LIKE '272%'
               OR e.compte_num LIKE '273%' OR e.compte_num LIKE '274%')
    ) AS org5
),
calcul AS (
    SELECT a.entite, a.arrete, v.forme_vehicule,
           a.immobilier_1_a_5, a.non_cote_1_3_5, a.liquidites_8_9, a.actif_total,
           a.liquidites_r214_100,
           d.emprunts_propres, d.emprunts_filiales_quote_part,
           im.immeubles_directs, im.immeubles_quote_part, im.organismes_5_quote_part,
           COALESCE(p.montant, 0)                                AS participations_r214_85,
           CAST(0 AS DECIMAL (19,2))                             AS credit_bail_dettes,
           a.rangs_1_4_6_a_9 + a.rang_5 + COALESCE(p.montant, 0)
               + COALESCE(t.actifs_filiales_quote_part, 0)       AS denominateur_r214_89,
           a.rang_1 + COALESCE(t.immeubles_filiales_r214_89, 0)
               + COALESCE(p.montant, 0) + a.rang_4 + a.rang_5    AS numerateur_60,
           a.rang_1 + COALESCE(t.immeubles_filiales_r214_89, 0)
               + COALESCE(p.montant, 0) + a.rang_5               AS numerateur_51
    FROM actif a
    JOIN vehicule v ON v.entite = a.entite AND v.arrete = a.arrete
    LEFT JOIN transparence t ON t.entite = a.entite AND t.arrete = a.arrete
    LEFT JOIN r214_85 p ON p.entite = a.entite AND p.arrete = a.arrete
    LEFT JOIN dette d ON d.entite = a.entite AND d.arrete = a.arrete
    LEFT JOIN immeubles im ON im.entite = a.entite AND im.arrete = a.arrete
)
SELECT rr.code,
       ISNULL(CAST(CASE WHEN sv.source IS NOT NULL
                        THEN REPLACE(rr.libelle, FORMAT(rr.seuil * 100, N'0.##', 'fr-FR') + N' %',
                                     FORMAT(CAST(sv.seuil AS DECIMAL (9,4)) * 100, N'0.##', 'fr-FR') + N' %')
                   END AS NVARCHAR (200)), rr.libelle)         AS libelle,
       rr.sens,
       ISNULL(CAST(sv.seuil AS DECIMAL (9,4)), rr.seuil)       AS seuil,
       ISNULL(CAST(CASE WHEN sv.source IS NOT NULL
                        THEN N'statuts du véhicule (CMF, art. R. 214-196 et R. 214-200)'
                   END AS NVARCHAR (60)), rr.article)          AS article,
       c.entite, c.arrete,
       CAST(n.numerateur AS DECIMAL (19,2))     AS numerateur,
       CAST(n.denominateur AS DECIMAL (19,2))   AS denominateur,
       CAST(CASE WHEN n.denominateur = 0 THEN NULL
                 ELSE n.numerateur / n.denominateur
            END AS DECIMAL (9,6))                AS ratio,
       c.emprunts_propres, c.emprunts_filiales_quote_part,
       c.immeubles_directs, c.immeubles_quote_part,
       c.actif_total, c.immobilier_1_a_5, c.non_cote_1_3_5, c.liquidites_8_9,
       ISNULL(CAST(CASE WHEN sv.source IS NOT NULL THEN ISNULL(sv.motif, N'')
                   END AS NVARCHAR (2000)), rr.citation)       AS citation,
       CAST(COALESCE(sv.lu_le, rr.lu_le) AS DATE)              AS lu_le,
       CAST(CASE WHEN sv.source IS NULL THEN rr.note
                 ELSE N'Calcul selon ' + rr.article + N' : ' + rr.note
            END AS NVARCHAR (800))                             AS note,
       -- 06/09/2026, O7 : la source du seuil, texte, prospectus ou cabinet,
       -- dit au reviseur s'il peut invoquer une derogation. Maquette E5-1.
       ISNULL(CAST(sv.source AS VARCHAR (20)), rr.source_du_seuil) AS source_du_seuil,
       CAST(rr.calcul_a_valider AS BIT) AS calcul_a_valider,
       CAST(c.denominateur_r214_89 AS DECIMAL (19,2))    AS denominateur_r214_89,
       CAST(c.participations_r214_85 AS DECIMAL (19,2))  AS participations_r214_85,
       CAST(c.organismes_5_quote_part AS DECIMAL (19,2)) AS organismes_5_quote_part,
       c.credit_bail_dettes,
       CAST(c.liquidites_r214_100 AS DECIMAL (19,2))     AS liquidites_r214_100
FROM dbo.ref_ratio rr
CROSS JOIN calcul c
CROSS APPLY (
    SELECT CASE rr.code
             WHEN 'ACTIFS_IMMO_60' THEN c.numerateur_60
             WHEN 'NON_COTE_51'    THEN c.numerateur_51
             WHEN 'LIQUIDITES_5'   THEN c.liquidites_r214_100
             WHEN 'ENDETTEMENT_40' THEN c.emprunts_propres
                                      + c.emprunts_filiales_quote_part
                                      + c.credit_bail_dettes
           END AS numerateur,
           CASE rr.code
             WHEN 'ACTIFS_IMMO_60' THEN c.denominateur_r214_89
             WHEN 'NON_COTE_51'    THEN c.denominateur_r214_89
             WHEN 'LIQUIDITES_5'   THEN c.actif_total
             WHEN 'ENDETTEMENT_40' THEN c.immeubles_directs
                                      + c.immeubles_quote_part
                                      + c.participations_r214_85
                                      + c.organismes_5_quote_part
           END AS denominateur
) AS n
OUTER APPLY (
    -- Decision D9 du candidat du 17/10/2026 : le seuil fixe par les statuts d'un OPCI professionnel (CMF,
    -- art. R. 214-196 et R. 214-200) remplace celui du texte pour ce vehicule seul ; la cle (entite, code) de
    -- ref_ratio_vehicule en rend 1 ligne au plus.
    SELECT v.seuil, v.source, v.lu_le, v.motif
    FROM dbo.ref_ratio_vehicule v
    JOIN dbo.ref_entite ve ON ve.code = v.entite AND ve.est_professionnel = 1
    WHERE v.entite = c.entite AND v.code = rr.code AND v.source = 'STATUTS'
      AND (v.en_vigueur_depuis IS NULL OR v.en_vigueur_depuis <= CAST(c.arrete AS DATE))
) AS sv
WHERE rr.forme_vehicule IS NULL
   OR rr.forme_vehicule = c.forme_vehicule;

GO

