
-- Les cellules imprimees autrement entre 2 versions d'un arrete (contrat, 2.3) : presence de la cellule, texte_imprime,
-- libelle, ordre, signe, groupe. Une ligne par cellule differente, avec ses 2 textes imprimes (NULL du cote ou elle
-- est absente), rangee dans l'ordre de l'article, de la cle naturelle de la ligne et de la colonne.
CREATE   FUNCTION dbo.fn_annexe_imprime_autrement (@entite VARCHAR (20), @arrete VARCHAR (20), @v1 INT, @v2 INT)
RETURNS TABLE
AS
RETURN
    SELECT ISNULL(n.article, a.article) AS article, ISNULL(n.ligne, a.ligne) AS ligne, ISNULL(n.colonne, a.colonne) AS colonne,
           a.texte_imprime AS ancien, n.texte_imprime AS nouveau,
           ROW_NUMBER() OVER (ORDER BY ISNULL(n.article, a.article),
                                       dbo.fn_ann_cle_naturelle(ISNULL(n.ligne, a.ligne)) COLLATE Latin1_General_100_BIN2,
                                       ISNULL(n.colonne, a.colonne)) AS rang
    FROM (SELECT * FROM dbo.cellule_annexe WHERE entite = @entite AND arrete = @arrete AND version = @v1) a
    FULL JOIN (SELECT * FROM dbo.cellule_annexe WHERE entite = @entite AND arrete = @arrete AND version = @v2) n
      ON n.article = a.article AND n.ligne = a.ligne AND n.colonne = a.colonne
    WHERE a.article IS NULL OR n.article IS NULL
       OR a.texte_imprime <> n.texte_imprime COLLATE Latin1_General_100_BIN2
       OR a.libelle <> n.libelle COLLATE Latin1_General_100_BIN2
       OR a.ordre <> n.ordre
       OR ISNULL(a.signe, '') <> ISNULL(n.signe, '') COLLATE Latin1_General_100_BIN2
       OR ISNULL(a.groupe, '') <> ISNULL(n.groupe, '') COLLATE Latin1_General_100_BIN2;

GO

