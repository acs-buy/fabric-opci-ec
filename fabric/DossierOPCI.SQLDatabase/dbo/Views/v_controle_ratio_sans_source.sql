
-- C56 : un ratio dont le seuil vient d'un texte sans article ni date de
-- lecture. La contrainte l'interdit ; la vue le mesure. ATTENDU zero.
CREATE   VIEW dbo.v_controle_ratio_sans_source AS
SELECT code, libelle, source_du_seuil, article, lu_le
FROM dbo.ref_ratio
WHERE source_du_seuil = 'TEXTE' AND (lu_le IS NULL OR article IS NULL);

GO

