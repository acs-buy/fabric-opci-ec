
-- --- 2 : la traduction, qui sait desormais repartir -----------------
-- CE QUE LA VUE REND, LIGNE A LIGNE. Une ligne par ecriture a traduire,
-- avec le compte cible choisi selon que le compte auxiliaire designe ou
-- non une entite du groupe. Une ecriture dont le compte n'a qu'un seul
-- candidat s'y trouve aussi : la repartition ne joue alors pas.
CREATE   VIEW dbo.v_ecriture_a_traduire AS
SELECT e.id AS ecriture_id, l.entite, l.arrete, e.compte_num AS compte_ecrit,
       e.comp_aux_num,
       CAST(CASE WHEN EXISTS (SELECT 1 FROM dbo.ref_entite x
                              WHERE x.code = e.comp_aux_num)
                 THEN 1 ELSE 0 END AS BIT)             AS est_interne,
       cible.compte_entite                             AS compte_cible,
       cible.libelle_entite                            AS libelle_cible,
       e.debit, e.credit
FROM dbo.ecriture e
JOIN dbo.lot_ecritures l ON l.id = e.lot_id
CROSS APPLY (
    SELECT TOP 1 rce.compte_entite, rce.libelle_entite
    FROM dbo.ref_compte_entite rce
    WHERE rce.entite = l.entite
      AND rce.compte_modele = e.compte_num
      AND rce.compte_entite <> e.compte_num
      -- LE COMPTE QUI RECOIT L'INTERNE QUAND L'ECRITURE EST INTERNE, et
      -- l'autre sinon. Quand un seul candidat existe, l'ordre ne joue
      -- pas et le TOP 1 le rend.
      AND (rce.porte_intragroupe = CASE WHEN EXISTS (
               SELECT 1 FROM dbo.ref_entite x WHERE x.code = e.comp_aux_num)
               THEN 1 ELSE 0 END
           OR NOT EXISTS (SELECT 1 FROM dbo.ref_compte_entite z
                          WHERE z.entite = l.entite
                            AND z.compte_modele = e.compte_num
                            AND z.compte_entite <> e.compte_num
                            AND z.porte_intragroupe = CASE WHEN EXISTS (
                                SELECT 1 FROM dbo.ref_entite y
                                WHERE y.code = e.comp_aux_num)
                                THEN 1 ELSE 0 END))
    ORDER BY rce.compte_entite
) AS cible
WHERE EXISTS (SELECT 1 FROM dbo.detention d WHERE d.entite_fille = l.entite);

GO

