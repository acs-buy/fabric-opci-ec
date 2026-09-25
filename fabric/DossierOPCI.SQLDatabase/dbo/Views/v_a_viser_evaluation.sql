
CREATE   VIEW dbo.v_a_viser_evaluation AS
SELECT e.entite, e.arrete, 'VALO' AS cycle, 'EVALUATION' AS nature,
       CAST(e.id AS VARCHAR (30))                     AS objet_ref,
       e.id                                           AS objet_id,
       CAST(N'Valeur retenue sur ' + e.code_actif + N', source '
            + e.source + COALESCE(N' : ' + LEFT(e.motif_ecart, 150), N'')
            AS NVARCHAR (300))                        AS libelle,
       e.propose_par, e.propose_le,
       CAST(NULL AS INT)                              AS lignes,
       e.valeur_retenue                               AS montant,
       e.etat,
       -- 07/09/2026 : le motif de refus ecrit par la procedure du bouton (138), lu a l'ecran.
       e.message_ecran
FROM dbo.evaluation_actif e
WHERE e.etat = 'PROPOSE';

GO

