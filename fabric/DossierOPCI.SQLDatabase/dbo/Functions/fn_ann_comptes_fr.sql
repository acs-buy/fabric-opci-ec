-- Le solde que lit une ligne de ref_ligne_annexe, en clair (oracle, comptes_fr) : « solde débiteur des comptes 421 et
-- 423 », suivi de « , hors 604 et 605 » quand la ligne exclut des comptes.
CREATE   FUNCTION dbo.fn_ann_comptes_fr (@racines NVARCHAR (400), @exclues NVARCHAR (400), @sens VARCHAR (10))
RETURNS NVARCHAR (1000)
AS
BEGIN
    DECLARE @nr INT = (SELECT COUNT(*) FROM STRING_SPLIT(ISNULL(@racines, N''), N',') WHERE LTRIM(RTRIM(value)) <> N'');
    DECLARE @ne INT = (SELECT COUNT(*) FROM STRING_SPLIT(ISNULL(@exclues, N''), N',') WHERE LTRIM(RTRIM(value)) <> N'');
    RETURN N'solde ' + CASE WHEN @sens = 'DEBIT' THEN N'débiteur' ELSE N'créditeur' END
         + CASE WHEN @nr = 1 THEN N' du compte ' ELSE N' des comptes ' END + dbo.fn_ann_liste_fr(@racines)
         + CASE WHEN @ne > 0 THEN N', hors ' + dbo.fn_ann_liste_fr(@exclues) ELSE N'' END;
END;

GO

