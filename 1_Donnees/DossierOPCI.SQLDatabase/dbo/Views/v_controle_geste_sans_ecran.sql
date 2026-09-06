
-- C91 : un geste de bouton sans procedure d'ecran. Chaque procedure
-- metier appelee par un bouton doit avoir son enveloppe : celle qui n'en
-- a pas rend « automation failed » a l'ecran.
CREATE   VIEW dbo.v_controle_geste_sans_ecran AS
SELECT p.name AS procedure_metier,
       N'cette procedure metier est appelee par un bouton et n''a pas de procedure d''ecran : son refus ne parviendra pas au reviseur'
                                           AS lecture
FROM sys.procedures p
WHERE p.name IN ('pr_viser_lot', 'pr_annuler_lot', 'pr_viser_conclusion', 'pr_conclure_feuille', 'pr_viser_derogation', 'pr_viser_evaluation', 'pr_viser_synthese', 'pr_proposer_synthese', 'pr_demander_document', 'pr_demander_reevaluation', 'pr_publier_vl', 'pr_cloturer_etape_5', 'pr_arreter_forme_attestation', 'pr_produire_attestation', 'pr_rouvrir_arrete', 'pr_approuver_acceptation', 'pr_reprendre_acceptation', 'pr_approuver_maintien', 'pr_ouvrir_maintien', 'pr_decider_distribution', 'pr_viser_obligation_distribution')
  AND NOT EXISTS (SELECT 1 FROM sys.procedures e
                  WHERE e.name = REPLACE(p.name, 'pr_', 'pr_ecran_'));

GO

