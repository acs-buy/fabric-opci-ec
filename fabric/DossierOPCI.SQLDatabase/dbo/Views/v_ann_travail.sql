
-- Les cellules de travail d'un calcul, aux colonnes de la preuve (contrat, 1.2 ; oracle, COLONNES_PREUVE).
CREATE   VIEW dbo.v_ann_travail AS
SELECT w.calcul_id, ca.entite, w.arrete, w.article, w.ligne, w.colonne, w.libelle, w.ordre, w.groupe, w.signe,
       CAST(w.valeur AS DECIMAL (19, 6)) AS valeur_numerique,
       CASE WHEN w.etat IN ('LU', 'CALCULE', 'SAISI') AND w.fmt = 'texte' THEN w.texte_valeur END AS valeur_texte,
       w.fmt AS format, w.etat, w.texte AS texte_affiche, w.texte_imprime, w.obligation, w.nature,
       CAST(CASE WHEN w.etat = 'A_REMPLIR' THEN 1 ELSE 0 END AS BIT) AS comptee, w.regle,
       CASE WHEN w.vb_txt IS NOT NULL THEN w.vb_txt WHEN w.vb_num IS NOT NULL THEN dbo.fn_ann_format(w.fmt, w.vb_num) END AS valeur_base,
       w.saisie_ecartee, CAST(ISNULL(w.attend_exigee, 0) AS BIT) AS attend_exigee, w.attend, w.source, w.formule, w.motif
FROM dbo.annexe_w_cel w JOIN dbo.calcul_annexe ca ON ca.calcul_id = w.calcul_id;

GO

