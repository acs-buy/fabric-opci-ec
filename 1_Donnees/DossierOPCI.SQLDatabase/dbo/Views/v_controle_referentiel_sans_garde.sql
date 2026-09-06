

-- --- 6 : les controles ----------------------------------------------
-- C48 : un referentiel sans garde d'ecriture. ATTENDU zero.
CREATE   VIEW dbo.v_controle_referentiel_sans_garde AS
SELECT r.table_nom, r.libelle, r.qui_tient
FROM dbo.ref_referentiel r
JOIN sys.tables t ON t.name = r.table_nom
WHERE NOT EXISTS (SELECT 1 FROM sys.triggers g
                  WHERE g.parent_id = t.object_id
                    AND g.name = 'tr_' + r.table_nom + '_garde');

GO

