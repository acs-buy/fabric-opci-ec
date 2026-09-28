
-- Le PDF vide d'une piece de demonstration, octet pour octet celui du depot du 28/09/2026.
CREATE   FUNCTION dbo.fn_pdf_piece_de_demonstration (@titre VARCHAR (400), @sujet VARCHAR (400))
RETURNS VARBINARY (MAX)
AS
BEGIN
    DECLARE @n CHAR (1) = CHAR(10);
    SET @titre = REPLACE(REPLACE(REPLACE(@titre, '\', '\'), '(', '\('), ')', '\)');
    SET @sujet = REPLACE(REPLACE(REPLACE(@sujet, '\', '\'), '(', '\('), ')', '\)');
    DECLARE @o1 VARCHAR (MAX) = '1 0 obj' + @n + '<< /Type /Catalog /Pages 2 0 R >>' + @n + 'endobj' + @n;
    DECLARE @o2 VARCHAR (MAX) = '2 0 obj' + @n + '<< /Type /Pages /Kids [3 0 R] /Count 1 >>' + @n + 'endobj' + @n;
    DECLARE @o3 VARCHAR (MAX) = '3 0 obj' + @n + '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << >> >>' + @n + 'endobj' + @n;
    DECLARE @o4 VARCHAR (MAX) = '4 0 obj' + @n + '<< /Title (' + @titre + ') /Subject (' + @sujet + ') /Producer (Jeu de demonstration) >>' + @n + 'endobj' + @n;
    DECLARE @tete VARCHAR (20) = '%PDF-1.4' + @n;
    DECLARE @d1 INT = DATALENGTH(@tete);
    DECLARE @d2 INT = @d1 + DATALENGTH(@o1), @d3 INT, @d4 INT, @x INT;
    SET @d3 = @d2 + DATALENGTH(@o2); SET @d4 = @d3 + DATALENGTH(@o3); SET @x = @d4 + DATALENGTH(@o4);
    DECLARE @z VARCHAR (10) = '0000000000';
    DECLARE @s VARCHAR (MAX) = @tete + @o1 + @o2 + @o3 + @o4
        + 'xref' + @n + '0 5' + @n + '0000000000 65535 f ' + @n
        + RIGHT(@z + CAST(@d1 AS VARCHAR), 10) + ' 00000 n ' + @n
        + RIGHT(@z + CAST(@d2 AS VARCHAR), 10) + ' 00000 n ' + @n
        + RIGHT(@z + CAST(@d3 AS VARCHAR), 10) + ' 00000 n ' + @n
        + RIGHT(@z + CAST(@d4 AS VARCHAR), 10) + ' 00000 n ' + @n
        + 'trailer' + @n + '<< /Size 5 /Root 1 0 R /Info 4 0 R >>' + @n + 'startxref' + @n + CAST(@x AS VARCHAR) + @n + '%%EOF' + @n;
    RETURN CAST(@s AS VARBINARY (MAX));
END;

GO

