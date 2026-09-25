CREATE VIEW dbo.v_ecran_qui_suis_je AS
SELECT
    cle_ecran          = CAST('QUI' AS varchar(3)),
    identite_session   = CAST(SESSION_USER AS nvarchar(200)),
    identite_utilisateur = CAST(USER_NAME() AS nvarchar(200)),
    identite_originale = CAST(ORIGINAL_LOGIN() AS nvarchar(200)),
    lu_le              = CAST(SYSDATETIME() AS datetime2(0)),
    message_ecran      = CAST(N'Si ces 3 noms sont ceux du réviseur, le contexte de travail peut vivre en base.' AS nvarchar(200));

GO

