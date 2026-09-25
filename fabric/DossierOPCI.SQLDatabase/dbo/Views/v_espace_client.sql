
-- --- 2 : la credential vers la fonction, A EXECUTER UNE FOIS A LA MAIN ----------
-- IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
--     CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<mot de passe fort>';
-- CREATE DATABASE SCOPED CREDENTIAL [https://opci-espaces-fn-acs.azurewebsites.net/api/provisionner_espace]
--     WITH IDENTITY = 'HTTPEndpointHeaders', SECRET = '{"x-functions-key":"<cle de fonction>"}';

-- --- 3 : la vue de la feuille, une ligne par entite du perimetre -------------
CREATE   VIEW dbo.v_espace_client AS
SELECT e.code + '|' + ISNULL(CAST(d.id AS VARCHAR (10)), '0') AS cle,
       e.code AS entite, e.denomination, e.forme_vehicule,
       d.id AS demande_id, d.statut, d.demande_par, d.demande_le, d.repondu_le,
       d.groupe_id, d.site_url,
       CASE WHEN d.site_url IS NOT NULL
            THEN N'https://teams.microsoft.com/l/team/' END AS equipe_indice,
       d.message_ecran
FROM dbo.ref_entite e
OUTER APPLY (SELECT TOP (1) * FROM dbo.demande_espace_client x
             WHERE x.entite = e.code ORDER BY x.id DESC) AS d;

GO

