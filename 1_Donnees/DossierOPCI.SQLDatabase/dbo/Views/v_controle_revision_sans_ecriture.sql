
-- --- depuis 63_SQL/79_compte_estimation_par_poste.sql : v_controle_revision_sans_ecriture ---
-- C7 : une revision de compte courant saisie sans ecriture de difference
-- d'estimation correspondante. La saisie n'est pas la comptabilite : une
-- revision se traduit par une ecriture au compte 276 par le compte 105,
-- article 213-4. ATTENDU zero.
CREATE   VIEW dbo.v_controle_revision_sans_ecriture AS
SELECT rc.entite, rc.arrete, rc.entite_fille, rc.compte,
       rc.montant_nominal, rc.montant_revise,
       CAST(rc.montant_revise - rc.montant_nominal AS DECIMAL (19,2))
           AS ecart_a_comptabiliser
FROM dbo.revision_compte_courant rc
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.v_ecriture_normalisee e
    JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    WHERE l.entite = rc.entite AND l.arrete = rc.arrete
      AND e.compte_num = '276'
      AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE'));

GO

