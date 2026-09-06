
-- --- 7 : controles ------------------------------------------------------
CREATE   VIEW dbo.v_controle_publication_en_echec AS
SELECT entite, arrete, visa_id, publiee_le, publiee_par, motif,
       N'la derniere publication de cet arrete a echoue : le rapport client porte l''etat precedent'
       AS lecture
FROM dbo.publication_client p
WHERE etat = 'EN_ECHEC'
  AND NOT EXISTS (SELECT 1 FROM dbo.publication_client q
                  WHERE q.entite = p.entite AND q.arrete = p.arrete AND q.id > p.id)
UNION ALL
SELECT entite, arrete, visa_id, publiee_le, publiee_par, motif,
       N'une publication est ouverte depuis plus d''une heure sans etre fermee : pipeline interrompu'
FROM dbo.publication_client
WHERE etat = 'EN_COURS' AND publiee_le < DATEADD(HOUR, -1, SYSUTCDATETIME());

GO

