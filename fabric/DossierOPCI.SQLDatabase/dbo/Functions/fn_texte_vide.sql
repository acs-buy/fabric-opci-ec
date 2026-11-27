CREATE FUNCTION dbo.fn_texte_vide (@t NVARCHAR (MAX))
RETURNS BIT
AS
BEGIN
    -- 1 quand le texte saisi est vide : NULL, ou, une fois otes a ses 2 bouts les 29 caracteres blancs de
    -- str.isspace() (espace, tabulation, sauts de ligne LF et CR, espaces insecables U+00A0 et U+202F
    -- compris), un reste egal a la chaine vide sous la collation de la base, qui ignore certains caracteres, comme
    -- le jugement par LTRIM et RTRIM qu'elle remplace ; 0 sinon.
    DECLARE @blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    DECLARE @reste NVARCHAR (MAX) = TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @t COLLATE Latin1_General_100_BIN2);
    RETURN CASE WHEN @t IS NULL OR @reste COLLATE DATABASE_DEFAULT = N'' THEN 1 ELSE 0 END;
END

GO

