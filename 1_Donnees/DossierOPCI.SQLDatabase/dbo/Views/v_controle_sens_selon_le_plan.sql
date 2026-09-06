
-- La vue qui comparait les 2 plans n'a plus d'objet une fois l'entite
-- traduite : elle disait ce qui se casserait le jour de la traduction.
-- Elle demeure pour les entites qui ne sont pas encore passees.
CREATE   VIEW dbo.v_controle_sens_selon_le_plan AS
SELECT s.entite, s.arrete, s.compte_num, s.solde, s.sens_constate,
       s.sens_attendu,
       N'cette entité n''est pas encore passée à son propre plan, et ce solde contredirait ce plan : la traduction suppose d''abord de reclasser ce compte'
                                                           AS lecture
FROM dbo.v_controle_sens_du_solde s
JOIN dbo.ref_entite r ON r.code = s.entite
WHERE r.plan_propre_en_service = 0
  AND s.solde <> 0
  AND s.compte_num LIKE '512%';

GO

