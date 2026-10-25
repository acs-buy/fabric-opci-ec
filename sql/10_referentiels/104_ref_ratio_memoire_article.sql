-- ref_ratio_memoire_article : 49 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_ratio_memoire_article])
BEGIN
    INSERT INTO dbo.[ref_ratio_memoire_article] ([code], [article], [colonne]) VALUES
        (N'ACTIFS_IMMO_60',N'L214-43',N'dates_respect'),
        (N'ACTIFS_IMMO_60',N'R214-194',N'fondement_professionnel'),
        (N'ACTIFS_IMMO_60',N'R214-196',N'fondement_professionnel'),
        (N'ACTIFS_IMMO_60',N'R214-200',N'fondement_professionnel'),
        (N'ACTIFS_IMMO_60',N'R214-89',N'article_calcul'),
        (N'ACTIFS_IMMO_60',N'R214-90',N'dates_respect'),
        (N'DIV_R214_111',N'R214-199',N'fondement_professionnel'),
        (N'DIV_R214_119',N'R214-199',N'fondement_professionnel'),
        (N'DIV_R214_120',N'R214-199',N'fondement_professionnel'),
        (N'DIV_R214_120',N'R214-200',N'fondement_professionnel'),
        (N'DIV_R214_120',N'R214-95',N'fondement_grand_public'),
        (N'DIV_R214_120',N'R214-95',N'fondement_professionnel'),
        (N'DIV_R214_85',N'L214-43',N'dates_respect'),
        (N'DIV_R214_85',N'R214-198',N'fondement_professionnel'),
        (N'DIV_R214_85',N'R214-87',N'article_calcul'),
        (N'DIV_R214_85',N'R214-88',N'dates_respect'),
        (N'DIV_R214_86',N'L214-43',N'dates_respect'),
        (N'DIV_R214_86',N'R214-198',N'fondement_professionnel'),
        (N'DIV_R214_86',N'R214-87',N'article_calcul'),
        (N'DIV_R214_86',N'R214-88',N'dates_respect'),
        (N'DIV_R214_95',N'R214-199',N'fondement_professionnel'),
        (N'DIV_R214_96_I',N'R214-199',N'fondement_professionnel'),
        (N'DIV_R214_96_II',N'R214-199',N'fondement_professionnel'),
        (N'DIV_R214_99',N'R214-199',N'fondement_professionnel'),
        (N'EMPRISE_R214_97',N'R214-199',N'fondement_professionnel'),
        (N'EMPRUNT_ESPECES_10',N'R214-106',N'article_calcul'),
        (N'EMPRUNT_ESPECES_10',N'R214-196',N'fondement_professionnel'),
        (N'EMPRUNT_ESPECES_10',N'R214-200',N'fondement_professionnel'),
        (N'ENDETTEMENT_40',N'L214-39',N'fondement_professionnel'),
        (N'ENDETTEMENT_40',N'L214-43',N'dates_respect'),
        (N'ENDETTEMENT_40',N'R214-104',N'article_calcul'),
        (N'ENDETTEMENT_40',N'R214-104',N'fondement_professionnel'),
        (N'ENDETTEMENT_40',N'R214-105',N'dates_respect'),
        (N'ENDETTEMENT_40',N'R214-105',N'dates_respect_professionnel'),
        (N'ENDETTEMENT_40',N'R214-196',N'fondement_professionnel'),
        (N'ENDETTEMENT_40',N'R214-199',N'dates_respect_professionnel'),
        (N'ENDETTEMENT_40',N'R214-200',N'fondement_professionnel'),
        (N'ENGAGEMENT_IFT',N'R214-112',N'article_calcul'),
        (N'ENGAGEMENT_IFT',N'R214-199',N'fondement_professionnel'),
        (N'ENGAGEMENT_IFT',N'R214-200',N'fondement_professionnel'),
        (N'LIQUIDITES_5',N'R214-100',N'article_calcul'),
        (N'LIQUIDITES_5',N'R214-101',N'dates_respect'),
        (N'LIQUIDITES_5',N'R214-197',N'fondement_professionnel'),
        (N'NON_COTE_51',N'L214-43',N'dates_respect'),
        (N'NON_COTE_51',N'R214-194',N'fondement_professionnel'),
        (N'NON_COTE_51',N'R214-196',N'fondement_professionnel'),
        (N'NON_COTE_51',N'R214-200',N'fondement_professionnel'),
        (N'NON_COTE_51',N'R214-89',N'article_calcul'),
        (N'NON_COTE_51',N'R214-90',N'dates_respect');
    PRINT 'ref_ratio_memoire_article : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_ratio_memoire_article : deja chargee, rien a faire.';
GO
