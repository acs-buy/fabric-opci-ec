-- publication_client : 4 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[publication_client])
BEGIN
    INSERT INTO dbo.[publication_client] ([id], [entite], [arrete], [visa_id], [etat], [publiee_le], [publiee_par], [motif], [terminee_le]) VALUES
        (N'3',N'OMEGA-OPCI',N'2025-12-31',N'8',N'PUBLIEE',N'2026-09-06 09:56:02.092',N'installation',NULL,N'2026-09-06 09:56:34.000'),
        (N'4',N'OMEGA-OPCI',N'2022-12-31',N'123',N'PUBLIEE',N'2026-09-06 16:27:46.649',N'installation',NULL,N'2026-09-06 16:28:34.153'),
        (N'5',N'OMEGA-OPCI',N'2023-12-31',N'124',N'PUBLIEE',N'2026-09-06 16:27:46.649',N'installation',NULL,N'2026-09-06 16:28:34.153'),
        (N'6',N'OMEGA-OPCI',N'2024-12-31',N'125',N'PUBLIEE',N'2026-09-06 16:27:46.649',N'installation',NULL,N'2026-09-06 16:28:34.153');
    PRINT 'publication_client : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'publication_client : deja chargee, rien a faire.';
GO
