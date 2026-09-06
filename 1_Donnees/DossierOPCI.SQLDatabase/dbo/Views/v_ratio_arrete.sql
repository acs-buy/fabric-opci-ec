
-- --- depuis 63_SQL/110_ratios_reglementaires.sql : v_ratio_arrete ----------------
-- --- 3 : le calcul des ratios par arrete ----------------------------
-- Chaque ratio porte son numerateur, son denominateur, sa conclusion et
-- la composition qui les explique. Les valeurs sont ACTUELLES, non
-- comptables : l'article L. 214-37 parle de la valeur des actifs, et
-- l'article 113-2 du reglement ANC 2021-09 impose la valeur actuelle.
CREATE   VIEW dbo.v_ratio_arrete AS
-- L'ACTIF SE LIT DE LA BALANCE, non de dbo.v_patrimoine_valorise :
-- celle-ci ne porte que les 4 familles d'actifs valorises, sans les
-- liquidites du compte 511 ni les depots, et le denominateur du ratio
-- serait donc incomplet. La balance porte en outre les differences
-- d'estimation aux comptes 27x : la somme du compte d'actif et de sa
-- difference EST la valeur actuelle, ce que l'article 113-2 du
-- reglement ANC 2021-09 prescrit.
WITH solde AS (
    SELECT l.entite, l.arrete, e.compte_num,
           SUM(e.debit - e.credit) AS solde
    FROM dbo.v_ecriture_normalisee e
    JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
    GROUP BY l.entite, l.arrete, e.compte_num
),
categorise AS (
    SELECT sd.entite, sd.arrete, sd.compte_num, sd.solde,
           -- La difference d'estimation suit l'actif qu'elle porte : le
           -- 271 suit le 21x, le 275 le 25x, le 276 le 266.
           COALESCE(c.rang,
                    CASE WHEN sd.compte_num LIKE '271%'
                           OR sd.compte_num LIKE '272%'
                           OR sd.compte_num LIKE '273%'
                           OR sd.compte_num LIKE '274%' THEN 1
                         WHEN sd.compte_num LIKE '275%' THEN 2
                         WHEN sd.compte_num LIKE '276%' THEN 10
                         ELSE NULL END)            AS rang
    FROM solde sd
    OUTER APPLY (
        SELECT TOP 1 x.rang FROM dbo.ref_categorie_actif_cmf x
        WHERE EXISTS (SELECT 1 FROM STRING_SPLIT(x.racines, ',') t
                      WHERE sd.compte_num LIKE t.value + '%')
        ORDER BY LEN(x.racines) DESC
    ) AS c
),
actif AS (
    SELECT g.entite, g.arrete,
           SUM(CASE WHEN g.rang BETWEEN 1 AND 5 THEN g.solde ELSE 0 END)
                                                  AS immobilier_1_a_5,
           SUM(CASE WHEN g.rang IN (1, 2, 3, 5) THEN g.solde ELSE 0 END)
                                                  AS non_cote_1_3_5,
           SUM(CASE WHEN g.rang IN (8, 9) THEN g.solde ELSE 0 END)
                                                  AS liquidites_8_9,
           SUM(CASE WHEN g.rang IS NOT NULL THEN g.solde ELSE 0 END)
                                                  AS actif_total
    FROM categorise g
    GROUP BY g.entite, g.arrete
),
dette AS (
    -- LES EMPRUNTS EXTERIEURS SEULS, arbitrage du candidat du
    -- 04/09/2026 : comptes 512 emprunts lies a des actifs immobiliers,
    -- 513 autres emprunts et 164 emprunts aupres des etablissements de
    -- credit. Le compte 4551, dette envers la mere, est EXCLU : le
    -- compter reviendrait a compter 2 fois la ressource que l'OPCI a
    -- levee puis pretee.
    SELECT r.entite, r.arrete,
           COALESCE(propre.montant, 0)             AS emprunts_propres,
           COALESCE(filiales.montant, 0)           AS emprunts_filiales_quote_part
    FROM dbo.ref_arrete r
    OUTER APPLY (
        SELECT SUM(e.credit - e.debit) AS montant
        FROM dbo.v_ecriture_normalisee e
        JOIN dbo.lot_ecritures l ON l.id = e.lot_id
        WHERE l.entite = r.entite AND l.arrete = r.arrete
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
        WHERE d.entite_mere = r.entite AND d.arrete = r.arrete
          AND (e.compte_num LIKE '512%' OR e.compte_num LIKE '513%'
               OR e.compte_num LIKE '164%')
          AND NOT EXISTS (SELECT 1 FROM dbo.ref_entite x
                          WHERE x.code = e.comp_aux_num)
    ) AS filiales
),
immeubles AS (
    -- LA VALEUR DES IMMEUBLES DETENUS, MULTIPLIEE PAR LE TAUX DE
    -- DETENTION, second arbitrage du candidat. Les immeubles en direct,
    -- plus ceux de chaque filiale a la quote-part. Les TITRES de
    -- filiales n'y entrent pas : ils representent ces memes immeubles.
    -- La valeur est ACTUELLE : le solde du compte d'immeuble augmente de
    -- sa difference d'estimation, article 113-2 du reglement ANC 2021-09.
    SELECT r.entite, r.arrete,
           COALESCE(direct.montant, 0)             AS immeubles_directs,
           COALESCE(indirect.montant, 0)           AS immeubles_quote_part
    FROM dbo.ref_arrete r
    OUTER APPLY (
        SELECT SUM(e.debit - e.credit) AS montant
        FROM dbo.v_ecriture_normalisee e
        JOIN dbo.lot_ecritures l ON l.id = e.lot_id
        WHERE l.entite = r.entite AND l.arrete = r.arrete
          AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
          AND (e.compte_num LIKE '21%' OR e.compte_num LIKE '22%'
               OR e.compte_num LIKE '23%' OR e.compte_num LIKE '24%'
               OR e.compte_num LIKE '271%' OR e.compte_num LIKE '272%'
               OR e.compte_num LIKE '273%' OR e.compte_num LIKE '274%')
    ) AS direct
    OUTER APPLY (
        SELECT SUM((e.debit - e.credit) * d.quote_part) AS montant
        FROM dbo.detention d
        JOIN dbo.lot_ecritures l ON l.entite = d.entite_fille
                                AND l.arrete = d.arrete
                                AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
        JOIN dbo.v_ecriture_normalisee e ON e.lot_id = l.id
        WHERE d.entite_mere = r.entite AND d.arrete = r.arrete
          AND (e.compte_num LIKE '21%' OR e.compte_num LIKE '22%'
               OR e.compte_num LIKE '23%' OR e.compte_num LIKE '24%'
               OR e.compte_num LIKE '271%' OR e.compte_num LIKE '272%'
               OR e.compte_num LIKE '273%' OR e.compte_num LIKE '274%')
    ) AS indirect
)
SELECT rr.code, rr.libelle, rr.sens, rr.seuil, rr.article,
       a.entite, a.arrete,
       CAST(CASE rr.code
              WHEN 'ACTIFS_IMMO_60' THEN a.immobilier_1_a_5
              WHEN 'NON_COTE_51'    THEN a.non_cote_1_3_5
              WHEN 'LIQUIDITES_5'   THEN a.liquidites_8_9
              WHEN 'ENDETTEMENT_40' THEN d.emprunts_propres
                                       + d.emprunts_filiales_quote_part
            END AS DECIMAL (19,2))               AS numerateur,
       CAST(CASE rr.code
              WHEN 'ENDETTEMENT_40' THEN im.immeubles_directs
                                       + im.immeubles_quote_part
              ELSE a.actif_total
            END AS DECIMAL (19,2))               AS denominateur,
       CAST(CASE WHEN CASE rr.code
                        WHEN 'ENDETTEMENT_40' THEN im.immeubles_directs
                                                 + im.immeubles_quote_part
                        ELSE a.actif_total END = 0 THEN NULL
                 ELSE CASE rr.code
                        WHEN 'ACTIFS_IMMO_60' THEN a.immobilier_1_a_5
                        WHEN 'NON_COTE_51'    THEN a.non_cote_1_3_5
                        WHEN 'LIQUIDITES_5'   THEN a.liquidites_8_9
                        WHEN 'ENDETTEMENT_40' THEN d.emprunts_propres
                                                 + d.emprunts_filiales_quote_part
                      END
                    / CASE rr.code
                        WHEN 'ENDETTEMENT_40' THEN im.immeubles_directs
                                                 + im.immeubles_quote_part
                        ELSE a.actif_total END
            END AS DECIMAL (9,6))                AS ratio,
       d.emprunts_propres, d.emprunts_filiales_quote_part,
       im.immeubles_directs, im.immeubles_quote_part,
       a.actif_total, a.immobilier_1_a_5, a.non_cote_1_3_5, a.liquidites_8_9,
       rr.citation, rr.lu_le, rr.note,
       CAST(rr.calcul_a_valider AS BIT) AS calcul_a_valider
FROM dbo.ref_ratio rr
CROSS JOIN actif a
LEFT JOIN dette d ON d.entite = a.entite AND d.arrete = a.arrete
LEFT JOIN immeubles im ON im.entite = a.entite AND im.arrete = a.arrete
LEFT JOIN dbo.ref_entite en ON en.code = a.entite
WHERE rr.forme_vehicule IS NULL
   OR rr.forme_vehicule = en.forme_vehicule;

GO

