-- --- 2 : la garde, dont le message derive du referentiel ------------
CREATE   PROCEDURE dbo.pr_garder_referentiel
    @table_nom VARCHAR (120)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @table_nom)
        RETURN;

    -- Objet n° 16 de l'ecran 5 (script 317, 19/10/2026). 2 sortes de tables ont leur propre garde, que cette
    -- procedure n'ecrit pas : saisie_annexe, gardee par tr_saisie_annexe_garde (fn_peut_saisir_annexe, contexte
    -- saisie_annexe_par), et une table dont ref_referentiel.action_propre est posee, ref_ratio_vehicule, dont la
    -- garde rejoue aussi les refus de la seule action qui l'ecrit (objet n° 21). action_propre se lit par
    -- sp_executesql : cette definition se rejoue dans les scripts 105 et 123, avant que le script 317 cree la
    -- colonne.
    IF @table_nom = 'saisie_annexe'
        RETURN;
    DECLARE @action_propre NVARCHAR (60);
    IF COL_LENGTH('dbo.ref_referentiel', 'action_propre') IS NOT NULL
        EXEC sp_executesql
            N'SELECT TOP 1 @a = NULLIF(LTRIM(RTRIM(action_propre)), N'''') FROM dbo.ref_referentiel WHERE table_nom = @t;',
            N'@a NVARCHAR (60) OUTPUT, @t VARCHAR (120)',
            @a = @action_propre OUTPUT, @t = @table_nom;
    IF @action_propre IS NOT NULL
        RETURN;

    DECLARE @qui_tient VARCHAR (20) =
        (SELECT TOP 1 qui_tient FROM dbo.ref_referentiel
         WHERE table_nom = @table_nom);

    DECLARE @role NVARCHAR (300) =
        CASE @qui_tient
             WHEN 'REVISEUR' THEN N'associé ou réviseur'
             WHEN 'BASE'     THEN N'associé. Cette table porte des valeurs livrées avec la base, recopiées depuis un texte : les modifier les fait diverger de leur source'
             ELSE N'associé' END;

    DECLARE @sql NVARCHAR (MAX) = N'CREATE OR ALTER TRIGGER dbo.'
        + QUOTENAME('tr_' + @table_nom + '_garde') + N'
ON dbo.' + QUOTENAME(@table_nom) + N'
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Objet n° 16 de l''ecran 5 (script 317) : l''identite jugee est celle que la procedure d''ecran pose dans le
    -- contexte par, a defaut le compte connecte. Le CAST est exige : un sql_variant passe nu a
    -- fn_peut_ecrire_referentiel rend le Msg 257.
    IF dbo.fn_peut_ecrire_referentiel(''' + @table_nom + N''',
                                      CAST(COALESCE(SESSION_CONTEXT(N''par''), SUSER_SNAME()) AS NVARCHAR (400))) = 1 RETURN;
    -- Objet n° 17 : le refus s''inscrit dans journal_refus avant d''etre leve. Le ROLLBACK precede
    -- l''inscription, que le THROW annulerait sinon avec l''ecriture refusee (pas de transaction autonome) ;
    -- sous une Data function, la fonction annule aussi l''inscription, puis journalise le refus apres son
    -- propre rollback (script 220). refuse_pour est un nvarchar(200) : l''identite y est coupee a 200
    -- caracteres, une ecriture plus longue y serait refusee et remplacerait le 50074.
    DECLARE @m NVARCHAR (2000) = N''Écriture refusée : la modification de ce référentiel du cabinet demande le rôle ' + @role + N'. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''''associé de porter la modification, ou de vous attribuer le rôle.'';
    ROLLBACK TRANSACTION;
    INSERT INTO dbo.journal_refus (procedure_nom, message, refuse_pour, refuse_le)
    VALUES (''' + LEFT('tr_' + @table_nom + '_garde', 60) + N''', @m, LEFT(CAST(COALESCE(SESSION_CONTEXT(N''par''), SUSER_SNAME()) AS NVARCHAR (400)), 200), SYSUTCDATETIME());
    SET @m = REPLACE(@m, N''%'', N''%%'');
    THROW 50074, @m, 1;
END;';
    EXEC sp_executesql @sql;

    -- Objet n° 16 : un ALTER TRIGGER remet l'ordre du declencheur a None (Learn, « sys.sp_settriggerorder », lu le
    -- 10/10/2026) ; sur ref_question, la garde repasse en tete des 3 declencheurs AFTER pour INSERT et UPDATE, avant
    -- tr_question_statut et tr_ref_question_horodatage.
    IF @table_nom = 'ref_question'
    BEGIN
        EXEC sp_settriggerorder @triggername = N'dbo.tr_ref_question_garde', @order = N'First', @stmttype = N'INSERT';
        EXEC sp_settriggerorder @triggername = N'dbo.tr_ref_question_garde', @order = N'First', @stmttype = N'UPDATE';
    END;
END;

GO

