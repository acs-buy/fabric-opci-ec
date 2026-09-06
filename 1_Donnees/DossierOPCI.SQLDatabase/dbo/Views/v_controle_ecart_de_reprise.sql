
-- C85 : une grandeur figee qui a bouge. Attendu zero pendant toute la
-- reprise des vues : une vue qui apprend a lire la correspondance ne
-- doit RIEN changer aux montants, puisque aucune ecriture n'est encore
-- traduite.
CREATE   VIEW dbo.v_controle_ecart_de_reprise AS
SELECT code, cle, valeur_figee, valeur_courante, ecart, lecture
FROM dbo.v_ecart_de_reprise;

GO

