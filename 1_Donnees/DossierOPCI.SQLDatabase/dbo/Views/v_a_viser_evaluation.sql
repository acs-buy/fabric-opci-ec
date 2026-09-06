
-- --- E9 : la vue des evaluations a viser, renommee ---------------
CREATE   VIEW dbo.v_a_viser_evaluation AS
SELECT e.entite, e.arrete, 'VALO' AS cycle, 'EVALUATION' AS nature,
       CAST(e.id AS VARCHAR (30))                     AS objet_ref,
       CAST(N'Valeur retenue sur ' + e.code_actif + N', source '
            + e.source + COALESCE(N' : ' + LEFT(e.motif_ecart, 150), N'')
            AS NVARCHAR (300))                        AS libelle,
       e.propose_par, e.propose_le,
       CAST(NULL AS INT)                              AS lignes,
       e.valeur_retenue                               AS montant,
       e.etat
FROM dbo.evaluation_actif e
WHERE e.etat = 'PROPOSE';

GO

