
-- --- 3 : la comparaison ---------------------------------------------
CREATE   VIEW dbo.v_ecart_de_reprise AS
WITH courant AS (
    SELECT 'ANR_ENTITE' AS code, entite + '|' + arrete AS cle,
           actif_net_reevalue AS valeur FROM dbo.v_anr_entite
    UNION ALL
    SELECT 'RATIONALISATION', entite + '|' + arrete, ecart
    FROM dbo.v_controle_rationalisation
    UNION ALL
    SELECT 'ANNEXE_333_1', entite + '|' + arrete, ecart
    FROM dbo.v_controle_annexe_333_1
    UNION ALL
    SELECT 'BILAN', entite + '|' + arrete, ecart
    FROM dbo.v_controle_bilan_desequilibre
    UNION ALL
    SELECT 'RATIO', entite + '|' + arrete + '|' + code, ratio
    FROM dbo.v_ratio_arrete
    UNION ALL
    SELECT 'SOLDE_COMPTE', entite + '|' + arrete + '|' + compte_num,
           SUM(debit) - SUM(credit)
    FROM dbo.v_ecriture_normalisee
    WHERE statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
    GROUP BY entite, arrete, compte_num
)
SELECT ISNULL(r.code, c.code)                  AS code,
       ISNULL(r.cle, c.cle)                    AS cle,
       r.valeur                                AS valeur_figee,
       c.valeur                                AS valeur_courante,
       ISNULL(c.valeur, 0) - ISNULL(r.valeur, 0) AS ecart,
       CASE WHEN r.cle IS NULL THEN N'apparue depuis le figeage'
            WHEN c.cle IS NULL THEN N'disparue depuis le figeage'
            ELSE N'valeur modifiée depuis le figeage' END AS lecture
FROM dbo.mesure_reference r
FULL OUTER JOIN courant c ON c.code = r.code AND c.cle = r.cle
WHERE r.cle IS NULL OR c.cle IS NULL
   OR ABS(ISNULL(c.valeur, 0) - ISNULL(r.valeur, 0)) > 0.005;

GO

