-- Les procedures metier qu'un bouton appelle par leur procedure d'ecran pr_ecran_<nom> ; pr_rouvrir_arrete n'y
-- figure pas, son action passant par pr_ecran_accorder_reouverture.
CREATE VIEW dbo.v_controle_geste_sans_ecran AS
SELECT p.name AS procedure_metier,
       N'cette procedure metier est appelee par un bouton et n''a pas de procedure d''ecran : son refus ne parviendra pas au reviseur'
                                           AS lecture
FROM sys.procedures p
WHERE p.name IN ('pr_viser_lot', 'pr_annuler_lot', 'pr_viser_conclusion', 'pr_viser_derogation', 'pr_viser_evaluation', 'pr_viser_synthese', 'pr_proposer_synthese', 'pr_demander_document', 'pr_publier_vl', 'pr_arreter_forme_attestation', 'pr_approuver_acceptation', 'pr_reprendre_acceptation', 'pr_approuver_maintien', 'pr_decider_distribution', 'pr_viser_obligation_distribution')
  AND NOT EXISTS (SELECT 1 FROM sys.procedures e
                  WHERE e.name = REPLACE(p.name, 'pr_', 'pr_ecran_'));

GO

