-- Generee depuis sys.foreign_keys ; ne pas modifier a la main.
CREATE VIEW dbo.v_entite_donnees AS
SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'acceptation_mission' AS NVARCHAR (128)) AS travail FROM [dbo].[acceptation_mission] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite_detentrice] AS VARCHAR (20)) AS entite, CAST(N'actif' AS NVARCHAR (128)) AS travail FROM [dbo].[actif] WHERE [entite_detentrice] IS NOT NULL
UNION ALL SELECT CAST([entite_liee] AS VARCHAR (20)) AS entite, CAST(N'actif' AS NVARCHAR (128)) AS travail FROM [dbo].[actif] WHERE [entite_liee] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'arrete_mission' AS NVARCHAR (128)) AS travail FROM [dbo].[arrete_mission] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'attestation' AS NVARCHAR (128)) AS travail FROM [dbo].[attestation] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'conclusion_ratio' AS NVARCHAR (128)) AS travail FROM [dbo].[conclusion_ratio] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([vehicule] AS VARCHAR (20)) AS entite, CAST(N'contexte_reviseur' AS NVARCHAR (128)) AS travail FROM [dbo].[contexte_reviseur] WHERE [vehicule] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'demande_document' AS NVARCHAR (128)) AS travail FROM [dbo].[demande_document] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'derogation' AS NVARCHAR (128)) AS travail FROM [dbo].[derogation] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite_fille] AS VARCHAR (20)) AS entite, CAST(N'detention' AS NVARCHAR (128)) AS travail FROM [dbo].[detention] WHERE [entite_fille] IS NOT NULL
UNION ALL SELECT CAST([entite_mere] AS VARCHAR (20)) AS entite, CAST(N'detention' AS NVARCHAR (128)) AS travail FROM [dbo].[detention] WHERE [entite_mere] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'dip' AS NVARCHAR (128)) AS travail FROM [dbo].[dip] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'ecriture_axe' AS NVARCHAR (128)) AS travail FROM [dbo].[ecriture_axe] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'ecriture_brouillon' AS NVARCHAR (128)) AS travail FROM [dbo].[ecriture_brouillon] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite_mere] AS VARCHAR (20)) AS entite, CAST(N'eligibilite_participation' AS NVARCHAR (128)) AS travail FROM [dbo].[eligibilite_participation] WHERE [entite_mere] IS NOT NULL
UNION ALL SELECT CAST([entite_emprunt] AS VARCHAR (20)) AS entite, CAST(N'emprunt_intragroupe' AS NVARCHAR (128)) AS travail FROM [dbo].[emprunt_intragroupe] WHERE [entite_emprunt] IS NOT NULL
UNION ALL SELECT CAST([entite_preteuse] AS VARCHAR (20)) AS entite, CAST(N'emprunt_intragroupe' AS NVARCHAR (128)) AS travail FROM [dbo].[emprunt_intragroupe] WHERE [entite_preteuse] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'export_dossier' AS NVARCHAR (128)) AS travail FROM [dbo].[export_dossier] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'export_fec' AS NVARCHAR (128)) AS travail FROM [dbo].[export_fec] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'feuille_travail' AS NVARCHAR (128)) AS travail FROM [dbo].[feuille_travail] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite_creditrice] AS VARCHAR (20)) AS entite, CAST(N'flux_intragroupe' AS NVARCHAR (128)) AS travail FROM [dbo].[flux_intragroupe] WHERE [entite_creditrice] IS NOT NULL
UNION ALL SELECT CAST([entite_debitrice] AS VARCHAR (20)) AS entite, CAST(N'flux_intragroupe' AS NVARCHAR (128)) AS travail FROM [dbo].[flux_intragroupe] WHERE [entite_debitrice] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'import_fec' AS NVARCHAR (128)) AS travail FROM [dbo].[import_fec] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'intention_ecriture' AS NVARCHAR (128)) AS travail FROM [dbo].[intention_ecriture] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'lot_ecritures' AS NVARCHAR (128)) AS travail FROM [dbo].[lot_ecritures] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'maintien_mission' AS NVARCHAR (128)) AS travail FROM [dbo].[maintien_mission] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'obligation_distribution' AS NVARCHAR (128)) AS travail FROM [dbo].[obligation_distribution] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'parts_en_circulation' AS NVARCHAR (128)) AS travail FROM [dbo].[parts_en_circulation] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'piece' AS NVARCHAR (128)) AS travail FROM [dbo].[piece] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'piece_rattachement' AS NVARCHAR (128)) AS travail FROM [dbo].[piece_rattachement] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite_couverte] AS VARCHAR (20)) AS entite, CAST(N'piece_rattachement' AS NVARCHAR (128)) AS travail FROM [dbo].[piece_rattachement] WHERE [entite_couverte] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'porteur' AS NVARCHAR (128)) AS travail FROM [dbo].[porteur] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'publication_vl' AS NVARCHAR (128)) AS travail FROM [dbo].[publication_vl] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'rapport_annuel' AS NVARCHAR (128)) AS travail FROM [dbo].[rapport_annuel] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'ref_compte_entite' AS NVARCHAR (128)) AS travail FROM [dbo].[ref_compte_entite] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite_liee] AS VARCHAR (20)) AS entite, CAST(N'ref_compte_entite' AS NVARCHAR (128)) AS travail FROM [dbo].[ref_compte_entite] WHERE [entite_liee] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'ref_croisee' AS NVARCHAR (128)) AS travail FROM [dbo].[ref_croisee] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'ref_ratio_vehicule' AS NVARCHAR (128)) AS travail FROM [dbo].[ref_ratio_vehicule] WHERE [entite] IS NOT NULL
UNION ALL SELECT CAST([entite_fille] AS VARCHAR (20)) AS entite, CAST(N'revision_compte_courant' AS NVARCHAR (128)) AS travail FROM [dbo].[revision_compte_courant] WHERE [entite_fille] IS NOT NULL
UNION ALL SELECT CAST([entite] AS VARCHAR (20)) AS entite, CAST(N'stg_fec' AS NVARCHAR (128)) AS travail FROM [dbo].[stg_fec] WHERE [entite] IS NOT NULL;

GO

