
CREATE   PROCEDURE dbo.pr_ann_charger @c INT, @entite VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DELETE dbo.annexe_w_arr WHERE calcul_id = @c;
    DELETE dbo.annexe_w_sol WHERE calcul_id = @c;
    DELETE dbo.annexe_w_axe WHERE calcul_id = @c;
    DELETE dbo.annexe_w_etat WHERE calcul_id = @c;
    DELETE dbo.annexe_w_num WHERE calcul_id = @c;
    DELETE dbo.annexe_w_nom WHERE calcul_id = @c;
    INSERT INTO dbo.annexe_w_arr (calcul_id, arrete, exercice, type_arrete, date_arrete, annee, porte_balance, arrete_n_1,
                                  premier_exercice, mission)
    SELECT @c, r.arrete, r.exercice, r.type_arrete, r.date_arrete,
           CAST(LEFT(ISNULL(NULLIF(r.exercice, ''), CONVERT(VARCHAR (10), r.date_arrete, 23)), 4) AS INT),
           ISNULL(a.porte_balance, 0), a.arrete_n_1, ISNULL(a.premier_exercice, 0), CASE WHEN a.arrete IS NULL THEN 0 ELSE 1 END
    FROM dbo.ref_arrete r
    LEFT JOIN dbo.v_arrete_etat a ON a.entite = r.entite AND a.arrete = r.arrete
    WHERE r.entite = @entite;
    INSERT INTO dbo.annexe_w_sol (calcul_id, arrete, compte_num, comp_aux_num, aff, solde, n)
    SELECT @c, lo.arrete, ISNULL(e.compte_num, ''), e.comp_aux_num, CASE WHEN lo.feuille_cote LIKE 'AFF-%' THEN 1 ELSE 0 END,
           CAST(SUM(e.debit - e.credit) AS DECIMAL (19, 2)), COUNT(*)
    FROM dbo.v_ecriture_normalisee e JOIN dbo.lot_ecritures lo ON lo.id = e.lot_id
    WHERE lo.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE') AND lo.entite = @entite
    GROUP BY lo.arrete, e.compte_num, e.comp_aux_num, CASE WHEN lo.feuille_cote LIKE 'AFF-%' THEN 1 ELSE 0 END;
    INSERT INTO dbo.annexe_w_axe (calcul_id, arrete, compte_num, code_actif, solde, n, aff)
    SELECT @c, lo.arrete, ISNULL(e.compte_num, ''), x.code_actif, CAST(SUM(e.debit - e.credit) AS DECIMAL (19, 2)), COUNT(*),
           CASE WHEN lo.feuille_cote LIKE 'AFF-%' THEN 1 ELSE 0 END
    FROM dbo.v_ecriture_normalisee e JOIN dbo.lot_ecritures lo ON lo.id = e.lot_id
    LEFT JOIN dbo.ecriture_axe x ON x.ecriture_id = e.ecriture_id
    WHERE lo.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE') AND lo.entite = @entite AND (e.compte_num LIKE '104%' OR e.compte_num LIKE '27%')
    GROUP BY lo.arrete, e.compte_num, x.code_actif, CASE WHEN lo.feuille_cote LIKE 'AFF-%' THEN 1 ELSE 0 END;
    INSERT INTO dbo.annexe_w_etat (calcul_id, arrete, code, exercice_n, exercice_n1)
    SELECT @c, arrete, code, exercice_n, exercice_n_1 FROM dbo.v_ligne_etat_montant WHERE entite = @entite;
    -- les noms des lignes de l'annexe dans les motifs et les sources (revision 12.1)
    EXEC dbo.pr_ann_noms_annexe @c = @c;
    -- les vues lues une fois : sommes distribuables, actif net reevalue, valeur liquidative et ses parts
    INSERT INTO dbo.annexe_w_num (calcul_id, cle, arrete, valeur)
    SELECT @c, 'SD', arrete, total_distribuable FROM dbo.v_sommes_distribuables WHERE entite = @entite
    UNION ALL SELECT @c, 'ANR', arrete, actif_net_reevalue FROM dbo.v_anr_entite WHERE entite = @entite
    UNION ALL SELECT @c, 'VL', arrete, valeur_liquidative FROM dbo.v_valeur_liquidative WHERE entite = @entite
    UNION ALL SELECT @c, 'VL_PARTS', arrete, nombre_parts FROM dbo.v_valeur_liquidative WHERE entite = @entite;
END;

GO

