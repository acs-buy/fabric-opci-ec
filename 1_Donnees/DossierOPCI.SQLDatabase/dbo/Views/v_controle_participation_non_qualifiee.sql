

-- --- 4 : les controles ----------------------------------------------
-- C70 : une participation detenue sans qualification d'eligibilite. Une
-- participation non qualifiee ne peut pas etre rangee dans le tableau de
-- l'article 336-2. ATTENDU zero.
CREATE   VIEW dbo.v_controle_participation_non_qualifiee AS
SELECT DISTINCT d.entite_mere, d.entite_fille
FROM dbo.detention d
WHERE NOT EXISTS (SELECT 1 FROM dbo.eligibilite_participation e
                  WHERE e.entite_mere = d.entite_mere
                    AND e.entite_fille = d.entite_fille);

GO

