-- La sous-regle de la regle D par ce qu'elle etablit (oracle, Table.phrase_d) ; @d : le compte de difference
-- d'estimation du groupe.
CREATE   FUNCTION dbo.fn_ann_phrase_d (@r VARCHAR (20), @d VARCHAR (10))
RETURNS NVARCHAR (400)
AS
BEGIN
    RETURN CASE @r WHEN 'D0' THEN N'coût nul, aucune différence d’estimation au ' + @d
                   WHEN 'D1' THEN N'compte ' + @d + N' nul'
                   WHEN 'D2' THEN N'seule ligne du groupe du ' + @d + N' à porter un coût, elle en reçoit tout le solde'
                   WHEN 'D3' THEN N'écritures du ' + @d + N' ventilées par actif (comptabilité analytique)'
                   WHEN 'D4' THEN N'écritures du ' + @d + N' non ventilées par actif, plusieurs lignes du groupe portant un coût'
                   ELSE N'arrêté sans balance' END;
END;

GO

