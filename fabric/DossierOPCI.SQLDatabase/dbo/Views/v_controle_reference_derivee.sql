-- C16 : la chaine portee par une table et l'intitule de la reference
-- pointee ne concordent plus. Elle detecte une derive apres coup.
CREATE   VIEW dbo.v_controle_reference_derivee AS
SELECT n.nature, n.article AS chaine_portee, r.norme, r.reference,
       CASE WHEN r.norme = 'ANC2020-07'
            THEN '2020-07 art. ' + r.reference ELSE r.reference END
           AS chaine_attendue
FROM dbo.ref_nature_actif n
JOIN dbo.ref_reference r ON r.id = n.reference_id
WHERE n.article <> CASE WHEN r.norme = 'ANC2020-07'
                        THEN '2020-07 art. ' + r.reference
                        ELSE r.reference END
  AND n.article NOT LIKE '%et%';

GO

