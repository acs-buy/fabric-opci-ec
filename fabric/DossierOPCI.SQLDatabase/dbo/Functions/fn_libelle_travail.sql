-- --- le libelle d'un travail, pour les textes affiches (50265, 50218) --------------------------------
-- le nom, en francais, de la table qui reference l'arrete ou l'entite ; une table ajoutee plus tard sans libelle rend son
-- nom, tirets bas remplaces par des espaces.
CREATE FUNCTION dbo.fn_libelle_travail (@table SYSNAME)
RETURNS NVARCHAR (128)
AS
BEGIN
    RETURN CASE @table
        -- tables qui referencent ref_entite sans referencer ref_arrete
        WHEN N'acceptation_mission'     THEN N'acceptation de mission'
        WHEN N'actif'                   THEN N'actif'
        WHEN N'contexte_reviseur'       THEN N'contexte du réviseur'
        WHEN N'demande_document'        THEN N'demande de document'
        WHEN N'demande_espace_client'   THEN N'demande d''espace client'
        WHEN N'ecriture_axe'            THEN N'écriture par axe'
        WHEN N'eligibilite_participation' THEN N'filiale déclarée'
        WHEN N'emprunt_intragroupe'     THEN N'emprunt intragroupe'
        WHEN N'export_dossier'          THEN N'export du dossier'
        WHEN N'flux_intragroupe'        THEN N'flux intragroupe'
        WHEN N'obligation_distribution' THEN N'obligation de distribution'
        WHEN N'piece'                   THEN N'pièce'
        WHEN N'porteur'                 THEN N'porteur de parts'
        WHEN N'ref_arrete'              THEN N'arrêté'
        WHEN N'ref_compte_entite'       THEN N'compte de l''entité'
        WHEN N'ref_ratio_vehicule'      THEN N'ratio du véhicule'
        WHEN N'role_mission'            THEN N'rôle de mission'
        WHEN N'stg_fec'                 THEN N'FEC en cours de chargement'
        -- tables qui referencent ref_arrete
        WHEN N'arrete_mission'          THEN N'arrêté ouvert'
        WHEN N'attestation'             THEN N'attestation'
        WHEN N'conclusion_cycle'        THEN N'conclusion de cycle'
        WHEN N'conclusion_ratio'        THEN N'conclusion de ratio'
        WHEN N'conclusion_revue'        THEN N'conclusion de revue'
        WHEN N'cours_titre'             THEN N'cours de titre'
        WHEN N'demande_reevaluation'    THEN N'demande de réévaluation'
        WHEN N'derogation'              THEN N'dérogation'
        WHEN N'detention'               THEN N'détention saisie'
        WHEN N'dip'                     THEN N'document d''information périodique'
        WHEN N'document_produit'        THEN N'document produit'
        WHEN N'dossier_verrou'          THEN N'verrou du dossier'
        WHEN N'ecriture_brouillon'      THEN N'écriture en brouillon'
        WHEN N'evaluation_actif'        THEN N'évaluation d''actif'
        WHEN N'expertise'               THEN N'expertise'
        WHEN N'export_fec'              THEN N'export FEC'
        WHEN N'feuille_travail'         THEN N'feuille de travail'
        WHEN N'import_fec'              THEN N'import FEC'
        WHEN N'intention_ecriture'      THEN N'intention d''écriture'
        WHEN N'lot_ecritures'           THEN N'lot d''écritures'
        WHEN N'maintien_mission'        THEN N'maintien de mission'
        WHEN N'mouvement_actif'         THEN N'mouvement d''actif'
        WHEN N'od_reimport'             THEN N'OD de réimport'
        WHEN N'od_retrait'              THEN N'OD de retrait'
        WHEN N'parts_en_circulation'    THEN N'parts en circulation'
        WHEN N'piece_rattachement'      THEN N'pièce rattachée'
        WHEN N'programme_travail'       THEN N'programme de travail'
        WHEN N'publication_client'      THEN N'publication au client'
        WHEN N'publication_vl'          THEN N'publication de VL'
        WHEN N'rapport_annuel'          THEN N'rapport annuel'
        WHEN N'ref_croisee'             THEN N'référence croisée'
        WHEN N'revision_compte_courant' THEN N'révision de compte courant'
        WHEN N'saisie_annexe'           THEN N'saisie d''annexe'
        WHEN N'synthese_proposee'       THEN N'synthèse proposée'
        WHEN N'valeur_instrument'       THEN N'valeur d''instrument'
        WHEN N'visa'                    THEN N'visa'
        ELSE REPLACE(@table, N'_', N' ') END;
END;

GO

