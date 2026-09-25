-- C22 : une nature visable qu'aucun role ne couvre. Elle serait
-- invisable, et le geste echouerait a l'ecran sans motif comprehensible.
-- ATTENDU zero.
CREATE   VIEW dbo.v_controle_nature_sans_role AS
SELECT v.nature FROM (VALUES ('LOT'), ('CONCLUSION'), ('DEROGATION'),
                             ('EVALUATION'), ('PUBLICATION'), ('OBLIGATION'))
                    AS v (nature)
WHERE NOT EXISTS (SELECT 1 FROM dbo.role_nature_visa n WHERE n.nature = v.nature);

GO

