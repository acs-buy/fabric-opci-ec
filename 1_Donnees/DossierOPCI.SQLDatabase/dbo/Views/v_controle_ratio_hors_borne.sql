

-- --- 5 : les controles ----------------------------------------------
-- C55 : un ratio hors borne. Il n'est PAS attendu a zero : c'est une
-- mesure du dossier, non un defaut de la base. La regularisation ou la
-- derogation releve du cabinet.
CREATE   VIEW dbo.v_controle_ratio_hors_borne AS
SELECT entite, arrete, code, libelle, article, ratio, seuil, conclusion
FROM dbo.v_ratio_conclusion
WHERE conforme = 0;

GO

