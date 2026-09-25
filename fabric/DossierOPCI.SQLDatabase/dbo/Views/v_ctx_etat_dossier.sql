CREATE   VIEW dbo.v_ctx_etat_dossier AS
SELECT t.* FROM dbo.v_ecran_etat_dossier t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite);

GO

