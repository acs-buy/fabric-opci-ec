
-- --- 2 : ce que la correspondance rend, une fois complete -----------
-- C82 : une entite qui declare 2 comptes pour la meme nature, c'est a
-- dire 2 comptes de son plan rattaches au meme compte du modele. Ce
-- n'est pas une faute en soi, une entite pouvant subdiviser, mais c'est
-- le signe d'une traduction a faire quand l'un des 2 est le compte du
-- modele lui-meme.
CREATE   VIEW dbo.v_controle_double_chemin_de_compte AS
SELECT rce.entite, rce.compte_modele,
       COUNT(*)                                    AS comptes_de_l_entite,
       STRING_AGG(rce.compte_entite, ', ')         AS lesquels,
       N'plusieurs comptes du plan de l''entité se rattachent au même compte du modèle : si l''un d''eux EST le compte du modèle, les écritures qui l''emploient restent à traduire'
                                                   AS lecture
FROM dbo.ref_compte_entite rce
WHERE rce.compte_modele IS NOT NULL
GROUP BY rce.entite, rce.compte_modele
HAVING COUNT(*) > 1;

GO

