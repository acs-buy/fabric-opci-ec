
-- --- controle : une vue d'ecran dont la cle n'est pas unique est une anomalie -
CREATE   VIEW dbo.v_controle_cle_ecran AS
WITH c AS (
SELECT 'v_ecran_a_generer_synthese' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_a_generer_synthese
UNION ALL SELECT 'v_ecran_a_viser' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_a_viser
UNION ALL SELECT 'v_ecran_a_viser_conclusion' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_a_viser_conclusion
UNION ALL SELECT 'v_ecran_a_viser_derogation' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_a_viser_derogation
UNION ALL SELECT 'v_ecran_a_viser_evaluation' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_a_viser_evaluation
UNION ALL SELECT 'v_ecran_a_viser_publication' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_a_viser_publication
UNION ALL SELECT 'v_ecran_actifs_expertise_requise' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_actifs_expertise_requise
UNION ALL SELECT 'v_ecran_anr_entite' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_anr_entite
UNION ALL SELECT 'v_ecran_anr_filiale' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_anr_filiale
UNION ALL SELECT 'v_ecran_anr_filiale_detail' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_anr_filiale_detail
UNION ALL SELECT 'v_ecran_balance' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_balance
UNION ALL SELECT 'v_ecran_bilan_actif' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_bilan_actif
UNION ALL SELECT 'v_ecran_bilan_passif' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_bilan_passif
UNION ALL SELECT 'v_ecran_cadrage_pret_intragroupe' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_cadrage_pret_intragroupe
UNION ALL SELECT 'v_ecran_carnet_import' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_carnet_import
UNION ALL SELECT 'v_ecran_compte_resultat' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_compte_resultat
UNION ALL SELECT 'v_ecran_comptes_non_rattaches' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_comptes_non_rattaches
UNION ALL SELECT 'v_ecran_differences_comptes_courants' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_differences_comptes_courants
UNION ALL SELECT 'v_ecran_differences_immeubles' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_differences_immeubles
UNION ALL SELECT 'v_ecran_differences_instruments' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_differences_instruments
UNION ALL SELECT 'v_ecran_differences_synthese' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_differences_synthese
UNION ALL SELECT 'v_ecran_differences_titres' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_differences_titres
UNION ALL SELECT 'v_ecran_documents_attendus' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_documents_attendus
UNION ALL SELECT 'v_ecran_ecritures_du_compte' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_ecritures_du_compte
UNION ALL SELECT 'v_ecran_etat_dossier' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_etat_dossier
UNION ALL SELECT 'v_ecran_etat_rapport_annuel' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_etat_rapport_annuel
UNION ALL SELECT 'v_ecran_etat_tableau_annexe' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_etat_tableau_annexe
UNION ALL SELECT 'v_ecran_fec_a_exporter' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_fec_a_exporter
UNION ALL SELECT 'v_ecran_flux_intragroupe' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_flux_intragroupe
UNION ALL SELECT 'v_ecran_inventaire_referentiel' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_inventaire_referentiel
UNION ALL SELECT 'v_ecran_journal_visa' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_journal_visa
UNION ALL SELECT 'v_ecran_ligne_annexe_montant' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_ligne_annexe_montant
UNION ALL SELECT 'v_ecran_livrables_dus' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_livrables_dus
UNION ALL SELECT 'v_ecran_lots_du_cycle' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_lots_du_cycle
UNION ALL SELECT 'v_ecran_mes_refus' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_mes_refus
UNION ALL SELECT 'v_ecran_obligation_minimale' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_obligation_minimale
UNION ALL SELECT 'v_ecran_parts_porteur_courant' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_parts_porteur_courant
UNION ALL SELECT 'v_ecran_perimetre_arrete' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_perimetre_arrete
UNION ALL SELECT 'v_ecran_piece_du_coffre' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_piece_du_coffre
UNION ALL SELECT 'v_ecran_plafond_distribuable' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_plafond_distribuable
UNION ALL SELECT 'v_ecran_question_referentiel' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_question_referentiel
UNION ALL SELECT 'v_ecran_questions_du_cycle' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_questions_du_cycle
UNION ALL SELECT 'v_ecran_ratio_arrete' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_ratio_arrete
UNION ALL SELECT 'v_ecran_ratio_conclusion' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_ratio_conclusion
UNION ALL SELECT 'v_ecran_rationalisation_filiale' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_rationalisation_filiale
UNION ALL SELECT 'v_ecran_rationalisation_opci' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_rationalisation_opci
UNION ALL SELECT 'v_ecran_rejets_import' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_rejets_import
UNION ALL SELECT 'v_ecran_simulation_distribution' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_simulation_distribution
UNION ALL SELECT 'v_ecran_sommes_distribuables' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_sommes_distribuables
UNION ALL SELECT 'v_ecran_supervision_cycle' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_supervision_cycle
UNION ALL SELECT 'v_ecran_titres_valeur_actuelle' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_titres_valeur_actuelle
UNION ALL SELECT 'v_ecran_valeur_liquidative' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_valeur_liquidative
UNION ALL SELECT 'v_ecran_obligation_par_categorie' AS vue, COUNT(*) AS lignes, COUNT(DISTINCT cle_ecran) AS cles FROM dbo.v_ecran_obligation_par_categorie
)
SELECT vue, lignes, cles, lignes - cles AS doublons,
       N'la cle d''ecran n''identifie pas chaque ligne : la feuille ne doit pas etre branchee sur cette vue' AS lecture
FROM c WHERE lignes <> cles;

GO

