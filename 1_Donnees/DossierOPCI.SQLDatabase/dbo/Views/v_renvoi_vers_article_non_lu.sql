

-- --- 3 : les renvois d'un article lu vers un article non lu ---------
-- C73 : un article lu qui RENVOIE a un article non lu. Le renvoi est un
-- trou connu : la regle que l'article lu enonce depend d'un texte que
-- personne n'a ouvert. La vue les nomme, pour que le trou soit visible
-- plutot que suppose comble.
CREATE   VIEW dbo.v_renvoi_vers_article_non_lu AS
SELECT lu.norme, lu.reference AS article_lu, lu.intitule,
       cite.reference         AS article_cite,
       cite.intitule          AS intitule_cite,
       N'l''article lu renvoie à un article que personne n''a ouvert : la règle qu''il énonce en dépend'
                              AS lecture
FROM dbo.ref_reference lu
JOIN dbo.ref_reference cite
  ON cite.norme = lu.norme
 AND cite.lu_sur_piece = 0
 AND lu.citation LIKE N'%'
                      + REPLACE(REPLACE(cite.reference,
                                        'L214-', 'L. 214-'),
                                'R214-', 'R. 214-') + N'%'
WHERE lu.lu_sur_piece = 1 AND lu.norme = 'CMF';

GO

