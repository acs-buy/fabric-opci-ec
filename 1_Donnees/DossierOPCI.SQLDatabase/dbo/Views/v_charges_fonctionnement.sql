
-- --- depuis 63_SQL/94_vues_intragroupe.sql : v_charges_fonctionnement ------------
-- --- 8 : la vue des charges de fonctionnement de l'OPCI ----------
-- Article 322-10 : « l'ensemble des depenses engagees pour le
-- fonctionnement de l'OPCI ». Elle les rend par nature, avec le compte et
-- l'article, pour que l'ecran les montre ligne a ligne.
CREATE   VIEW dbo.v_charges_fonctionnement AS
SELECT l.entite, l.arrete, e.compte_num, c.libelle AS compte_libelle,
       e.ecriture_lib                                      AS nature_charge,
       CAST(SUM(e.debit - e.credit) AS DECIMAL (19,2))      AS montant,
       r.citation_courte                                    AS fondement,
       CASE WHEN e.compte_num LIKE '61%' THEN 'FRAIS_DE_GESTION'
            WHEN e.compte_num LIKE '62%' THEN 'IMMOBILIER'
            WHEN e.compte_num LIKE '60%' THEN 'FINANCIER'
            ELSE 'AUTRES' END                               AS poste_resultat
FROM dbo.v_ecriture_normalisee e
JOIN dbo.lot_ecritures l ON l.id = e.lot_id
JOIN dbo.ref_compte c ON c.compte = e.compte_num
LEFT JOIN dbo.v_reference r ON r.id = c.reference_id
WHERE LEFT(e.compte_num, 1) = '6' AND l.famille = 'IMPORTEE'
GROUP BY l.entite, l.arrete, e.compte_num, c.libelle, e.ecriture_lib,
         r.citation_courte;

GO

