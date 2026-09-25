-- mouvement_porteur : 20 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[mouvement_porteur])
BEGIN
    INSERT INTO dbo.[mouvement_porteur] ([porteur_id], [date_valeur], [nature], [nombre_parts], [montant], [saisi_par], [saisi_le]) VALUES
        (N'4',N'2025-12-31',N'SOUSCRIPTION',N'6000.0000',N'600000.00',N'installation',N'2026-09-06 01:04:49.340'),
        (N'5',N'2025-12-31',N'SOUSCRIPTION',N'4000.0000',N'400000.00',N'installation',N'2026-09-06 01:04:49.340'),
        (N'1',N'2022-12-31',N'SOUSCRIPTION',N'709826.0000',N'70982600.00',N'installation',N'2026-09-06 01:05:46.216'),
        (N'2',N'2022-12-31',N'SOUSCRIPTION',N'419018.0000',N'41901800.00',N'installation',N'2026-09-06 01:05:46.216'),
        (N'3',N'2022-12-31',N'SOUSCRIPTION',N'183892.0000',N'18389200.00',N'installation',N'2026-09-06 01:05:46.216'),
        (N'6',N'2022-12-31',N'SOUSCRIPTION',N'95254.0000',N'9525400.00',N'installation',N'2026-09-06 01:05:46.216'),
        (N'1',N'2025-12-31',N'RACHAT',N'12947.0000',N'1414071.34',N'installation',N'2026-09-06 01:05:46.288'),
        (N'6',N'2025-12-31',N'SOUSCRIPTION',N'12947.0000',N'1414071.34',N'installation',N'2026-09-06 01:05:46.288'),
        (N'1',N'2025-12-31',N'DISTRIBUTION',N'0.0000',N'1774565.00',N'installation',N'2026-09-06 01:05:46.318'),
        (N'2',N'2025-12-31',N'DISTRIBUTION',N'0.0000',N'1047545.00',N'installation',N'2026-09-06 01:05:46.318'),
        (N'3',N'2025-12-31',N'DISTRIBUTION',N'0.0000',N'459730.00',N'installation',N'2026-09-06 01:05:46.318'),
        (N'6',N'2025-12-31',N'DISTRIBUTION',N'0.0000',N'238135.00',N'installation',N'2026-09-06 01:05:46.318'),
        (N'1',N'2022-12-31',N'DISTRIBUTION',N'0.0000',N'3480214.89',N'installation',N'2026-09-06 11:34:39.053'),
        (N'1',N'2023-12-31',N'DISTRIBUTION',N'0.0000',N'3602664.24',N'installation',N'2026-09-06 11:34:39.053'),
        (N'2',N'2022-12-31',N'DISTRIBUTION',N'0.0000',N'2054408.66',N'installation',N'2026-09-06 11:34:39.053'),
        (N'2',N'2023-12-31',N'DISTRIBUTION',N'0.0000',N'2126691.84',N'installation',N'2026-09-06 11:34:39.053'),
        (N'3',N'2022-12-31',N'DISTRIBUTION',N'0.0000',N'901606.42',N'installation',N'2026-09-06 11:34:39.053'),
        (N'3',N'2023-12-31',N'DISTRIBUTION',N'0.0000',N'933328.92',N'installation',N'2026-09-06 11:34:39.053'),
        (N'6',N'2022-12-31',N'DISTRIBUTION',N'0.0000',N'467022.04',N'installation',N'2026-09-06 11:34:39.053'),
        (N'6',N'2023-12-31',N'DISTRIBUTION',N'0.0000',N'483453.94',N'installation',N'2026-09-06 11:34:39.053');
    PRINT 'mouvement_porteur : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'mouvement_porteur : deja chargee, rien a faire.';
GO
