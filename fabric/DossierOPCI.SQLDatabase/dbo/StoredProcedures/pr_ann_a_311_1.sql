
-- 311-1 : la devise de comptabilite de l'entite (oracle, a_311_1, revision 12.2).
CREATE   PROCEDURE dbo.pr_ann_a_311_1 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @devise NVARCHAR (40) = (SELECT e.devise_comptabilite FROM dbo.ref_entite e JOIN dbo.calcul_annexe ca ON ca.entite = e.code WHERE ca.calcul_id = @c);
    IF NULLIF(LTRIM(RTRIM(@devise)), N'') IS NULL
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = '311-1', @ligne = N'DEVISE', @col = 1,
             @motif = N'devise de comptabilité définie dans le règlement de l’OPCI, non enregistrée au dossier de l’OPCI', @fmt = 'texte',
             @nature = 'source', @regle = 'NEUVE', @libelle = N'Devise de comptabilité', @ordre = 0;
    ELSE
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = '311-1', @ligne = N'DEVISE', @col = 1, @etat = 'LU', @fmt = 'texte', @texte = @devise,
             @nature = 'source', @source = N'devise de comptabilité enregistrée au dossier de l’OPCI', @regle = 'NEUVE',
             @libelle = N'Devise de comptabilité', @ordre = 0;
END;

GO

