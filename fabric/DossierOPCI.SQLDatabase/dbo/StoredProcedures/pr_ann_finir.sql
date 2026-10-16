
-- Fin de la table d'un arrete (oracle, Table.ordonner puis Table.attentes) : le rang d'impression de chaque ligne dans
-- son article, puis, pour chaque cellule en attente, les cellules a remplir qu'elle attend de proche en proche, et
-- attend_exigee.
CREATE   PROCEDURE dbo.pr_ann_finir @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    ;WITH lignes AS (
        SELECT article, ligne, ordre_declare,
               ROW_NUMBER() OVER (PARTITION BY article, ligne ORDER BY rang) AS premier
        FROM dbo.annexe_w_cel WHERE calcul_id = @c AND arrete = @a),
    rangs AS (
        SELECT article, ligne,
               ROW_NUMBER() OVER (PARTITION BY article ORDER BY ISNULL(ordre_declare, 0),
                                  dbo.fn_ann_cle_naturelle(ligne) COLLATE Latin1_General_100_BIN2) AS r
        FROM lignes WHERE premier = 1)
    UPDATE w SET ordre = r.r
    FROM dbo.annexe_w_cel w JOIN rangs r ON r.article = w.article AND r.ligne = w.ligne
    WHERE w.calcul_id = @c AND w.arrete = @a;

    CREATE TABLE #att (r_art VARCHAR (10), r_lig NVARCHAR (120), r_col TINYINT, attend NVARCHAR (MAX), exigee INT);
    ;WITH chemin AS (
        SELECT w.article AS r_art, w.ligne AS r_lig, w.colonne AS r_col,
               o.op_article AS art, o.op_ligne AS lig, o.op_colonne AS col, 1 AS profondeur
        FROM dbo.annexe_w_cel w
        JOIN dbo.annexe_w_ops o ON o.calcul_id = w.calcul_id AND o.arrete = w.arrete AND o.article = w.article AND o.ligne = w.ligne AND o.colonne = w.colonne
        WHERE w.calcul_id = @c AND w.arrete = @a AND w.etat = 'EN_ATTENTE'
        UNION ALL
        SELECT ch.r_art, ch.r_lig, ch.r_col, o.op_article, o.op_ligne, o.op_colonne, ch.profondeur + 1
        FROM chemin ch
        JOIN dbo.annexe_w_cel y ON y.calcul_id = @c AND y.arrete = @a AND y.article = ch.art AND y.ligne = ch.lig AND y.colonne = ch.col AND y.etat = 'EN_ATTENTE'
        JOIN dbo.annexe_w_ops o ON o.calcul_id = @c AND o.arrete = @a AND o.article = y.article AND o.ligne = y.ligne AND o.colonne = y.colonne
        WHERE ch.profondeur < 40),
    attendues AS (
        SELECT DISTINCT ch.r_art, ch.r_lig, ch.r_col, y.article, y.ligne, y.colonne, y.obligation
        FROM chemin ch
        JOIN dbo.annexe_w_cel y ON y.calcul_id = @c AND y.arrete = @a AND y.article = ch.art AND y.ligne = ch.lig AND y.colonne = ch.col AND y.etat = 'A_REMPLIR')
    INSERT INTO #att (r_art, r_lig, r_col, attend, exigee)
    SELECT r_art, r_lig, r_col,
           STRING_AGG(CAST(article + N' ' + ligne + N' ' + CAST(colonne AS NVARCHAR (4)) AS NVARCHAR (MAX)), N'; ')
               WITHIN GROUP (ORDER BY article, dbo.fn_ann_cle_naturelle(ligne) COLLATE Latin1_General_100_BIN2, colonne),
           MAX(CASE WHEN obligation = 'IMPOSEE' THEN 1 ELSE 0 END)
    FROM attendues GROUP BY r_art, r_lig, r_col
    OPTION (MAXRECURSION 0);
    UPDATE w SET attend = CASE WHEN w.etat = 'EN_ATTENTE' THEN x.attend END,
                 attend_exigee = CASE WHEN w.etat = 'EN_ATTENTE' AND x.exigee = 1 THEN 1 ELSE 0 END
    FROM dbo.annexe_w_cel w
    LEFT JOIN #att x ON x.r_art = w.article AND x.r_lig = w.ligne AND x.r_col = w.colonne
    WHERE w.calcul_id = @c AND w.arrete = @a;
    DROP TABLE #att;
END;

GO

