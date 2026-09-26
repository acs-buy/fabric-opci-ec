-- programme_journal : 1 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[programme_journal])
BEGIN
    INSERT INTO dbo.[programme_journal] ([id], [programme_id], [question_id], [geste], [detail], [par], [le]) VALUES
        (N'18',N'9',NULL,N'CHOIX',N'CLASSIQUE',N'installation',N'2026-09-26 11:03:30.542');
    PRINT 'programme_journal : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'programme_journal : deja chargee, rien a faire.';
GO
