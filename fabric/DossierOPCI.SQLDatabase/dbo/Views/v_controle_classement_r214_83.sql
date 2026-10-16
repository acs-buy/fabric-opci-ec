
-- Signal non bloquant : une filiale classee non contrôlée alors que les droits de vote propres de l'OPCI y depassent
-- 50 %, ce qui etablit le cas a du 3° de l'article R. 214-83. Le classement reste admis : une filiale majoritaire dont
-- les immeubles ne satisfont pas le 2° peut relever de R. 214-85. Les droits de vote des autres OPCI du meme
-- gestionnaire (cas d) ne sont pas en base.
CREATE   VIEW dbo.v_controle_classement_r214_83 AS
SELECT ep.entite_mere, ep.entite_fille, ep.droits_de_vote, ep.controlee,
       N'Filiale classée non contrôlée alors que l''OPCI détient plus de 50 % des droits de vote, ce qui établit le cas a du 3° de l''article R. 214-83 du code monétaire et financier. Classement admis : vérifier que la participation relève de l''article R. 214-85.'
                                                AS lecture
FROM dbo.eligibilite_participation ep
WHERE ep.controlee = 0 AND ep.droits_de_vote > 0.5;

GO

