
-- L'empreinte SHA-256 d'un contenu base64, en minuscules : celle que rend sha256sum sur les memes octets.
CREATE   FUNCTION dbo.fn_empreinte_base64 (@contenu_base64 NVARCHAR (MAX))
RETURNS CHAR (64)
AS
BEGIN
    DECLARE @octets VARBINARY (MAX) = CAST(N'' AS XML).value('xs:base64Binary(sql:variable("@contenu_base64"))', 'VARBINARY(MAX)');
    RETURN LOWER(CONVERT(CHAR (64), HASHBYTES('SHA2_256', @octets), 2));
END;

GO

