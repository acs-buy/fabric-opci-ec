
-- --- 7 : les rejets, avec leur motif. C'est la piece du critere B1.
CREATE   VIEW dbo.v_rejets_import AS
SELECT s.import_id, i.entite, i.nom_fichier, s.numero_ligne,
       s.compte_num, s.debit, s.credit, s.motif_rejet
FROM dbo.stg_fec s
JOIN dbo.import_fec i ON i.id = s.import_id
WHERE s.recevable = 0;

GO

