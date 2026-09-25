-- C23 : un motif de renvoi ecrit par-dessus le motif du proposant. La
-- colonne les separe desormais ; la vue verifie qu'aucune valeur renvoyee
-- n'a perdu le motif de son proposant. ATTENDU zero.
CREATE   VIEW dbo.v_controle_motif_ecrase AS
SELECT e.id, e.code_actif, e.etat, e.motif_ecart, e.motif_renvoi
FROM dbo.evaluation_actif e
JOIN dbo.visa v ON v.nature = 'EVALUATION'
               AND v.objet_ref = CAST(e.id AS VARCHAR (30))
               AND v.decision = 'RENVOYE'
WHERE e.motif_ecart = v.motif;

GO

