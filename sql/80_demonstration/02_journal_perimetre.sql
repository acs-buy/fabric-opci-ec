-- journal_perimetre : 30 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[journal_perimetre])
BEGIN
    INSERT INTO dbo.[journal_perimetre] ([entite_mere], [entite_fille], [action], [detail], [fait_par], [fait_le]) VALUES
        (N'OPCI-ESSAI',N'SCI-ESSAI-P',N'AJOUT',N'droits de vote 75,00 %',N'installation',N'2026-09-21 10:02:33'),
        (N'OPCI-ESSAI',N'SCI-ESSAI-P',N'AJOUT',N'droits de vote 75,00 %',N'installation',N'2026-09-21 10:08:50'),
        (N'OPCI-ESSAI',N'SCI-ESSAI-P',N'AJOUT',N'droits de vote 75,00 %',N'installation',N'2026-09-21 10:34:00'),
        (N'OPCI-ESSAI',N'SCI-ESSAI-P',N'AJOUT',N'droits de vote 60,00 %',N'installation',N'2026-09-21 11:48:54'),
        (N'OMEGA-OPCI',N'SCI-ESSAI-9',N'AJOUT',N'droits de vote 75,00 %',N'installation',N'2026-09-21 16:31:37'),
        (N'OPCI-ESSAI',N'SCI-ESSAI-9',N'AJOUT',N'droits de vote 75,00 %',N'installation',N'2026-09-21 16:36:47'),
        (N'OPCI-ESSAI',N'SCI-ESSAI-9',N'MODIFICATION',N'dénomination → SCI d essai 9 MODIFIEE ; ',N'installation',N'2026-09-21 16:37:57'),
        (N'OPCI-ESSAI',N'SCI-ESSAI-9',N'SUPPRESSION',N'retirée du périmètre ; SCI d essai 9 MODIFIEE',N'installation',N'2026-09-21 16:38:36'),
        (N'OMEGA-OPCI',N'SCI-ESSAI-9',N'SUPPRESSION',N'retirée du périmètre ; SCI d essai 9 MODIFIEE',N'installation',N'2026-09-21 16:52:53'),
        (N'OMEGA-OPCI',N'SCI-ESSAI-9',N'AJOUT',N'droits de vote 75,00 %',N'installation',N'2026-09-21 16:56:05'),
        (N'OMEGA-OPCI',N'SCI-ESSAI-9',N'MODIFICATION',N'dénomination → SCI d essai 9 MODIFIEE ; ',N'installation',N'2026-09-21 17:01:32'),
        (N'OMEGA-OPCI',N'SCI-ESSAI-9',N'SUPPRESSION',N'retirée du périmètre ; SCI d essai 9 MODIFIEE',N'installation',N'2026-09-21 17:02:11'),
        (N'OMEGA-OPCI',N'SCI-ESSAI-9',N'AJOUT',N'droits de vote 75,00 %',N'installation',N'2026-09-21 17:04:17'),
        (N'OMEGA-OPCI',N'SCI-ESSAI-9',N'MODIFICATION',N'dénomination → SCI d essai 9 MODIFIEE ; ',N'installation',N'2026-09-21 17:05:54'),
        (N'OMEGA-OPCI',N'SCI-ESSAI-9',N'SUPPRESSION',N'retirée du périmètre ; SCI d essai 9 MODIFIEE',N'installation',N'2026-09-21 17:06:33'),
        (N'OMEGA-OPCI',N'SCI-ESSAI-9',N'AJOUT',N'droits de vote 75,00 %',N'installation',N'2026-09-21 17:10:49'),
        (N'OMEGA-OPCI',N'SCI-ESSAI-9',N'MODIFICATION',N'dénomination → SCI d essai 9 MODIFIEE ; ',N'installation',N'2026-09-21 17:12:59'),
        (N'OMEGA-OPCI',N'SCI-ESSAI-9',N'SUPPRESSION',N'retirée du périmètre ; SCI d essai 9 MODIFIEE',N'installation',N'2026-09-21 17:13:38'),
        (N'OMEGA-OPCI',N'SCI-ESSAI-9',N'AJOUT',N'droits de vote 75,00 %',N'installation',N'2026-09-21 17:40:40'),
        (N'OMEGA-OPCI',N'SCI-ESSAI-9',N'MODIFICATION',N'dénomination → SCI d essai 9 MODIFIEE ; ',N'installation',N'2026-09-21 17:42:50'),
        (N'OMEGA-OPCI',N'SCI-ESSAI-9',N'SUPPRESSION',N'retirée du périmètre ; SCI d essai 9 MODIFIEE',N'installation',N'2026-09-21 17:43:30'),
        (N'OMEGA-OPCI',N'SCI-ESSAI-9',N'AJOUT',N'droits de vote 75,00 %',N'installation',N'2026-09-21 17:49:06'),
        (N'OMEGA-OPCI',N'SCI-ESSAI-9',N'MODIFICATION',N'dénomination → SCI d essai 9 MODIFIEE ; ',N'installation',N'2026-09-21 18:07:25'),
        (N'OMEGA-OPCI',N'SCI-ESSAI-9',N'SUPPRESSION',N'retirée du périmètre ; SCI d essai 9 MODIFIEE',N'installation',N'2026-09-21 18:08:05'),
        (N'OMEGA-OPCI',N'SCI-MSG-1',N'AJOUT',N'droits de vote 55,00 %',N'installation',N'2026-09-21 18:20:01'),
        (N'OMEGA-OPCI',N'SCI-MSG-2',N'AJOUT',N'droits de vote 55,00 %',N'installation',N'2026-09-21 18:23:11'),
        (N'OMEGA-OPCI',N'SCI-MSG-1',N'SUPPRESSION',N'retirée du périmètre ; Filiale du message',N'installation',N'2026-09-21 18:25:16'),
        (N'OMEGA-OPCI',N'SCI-MSG-2',N'SUPPRESSION',N'retirée du périmètre ; Filiale du message 2',N'installation',N'2026-09-21 18:25:16'),
        (N'OPCI-ESSAI',N'SCI-ESSAI-IMPORT',N'AJOUT',N'droits de vote 55,00 %',N'installation',N'2026-09-22 21:47:02'),
        (N'OPCI-ESSAI',N'SCI-ESSAI-IMPORT',N'SUPPRESSION',N'retirée du périmètre ; SCI d essai importee',N'installation',N'2026-09-22 21:48:22');
    PRINT 'journal_perimetre : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'journal_perimetre : deja chargee, rien a faire.';
GO
