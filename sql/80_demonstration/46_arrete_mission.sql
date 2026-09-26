-- arrete_mission : 5 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[arrete_mission])
BEGIN
    INSERT INTO dbo.[arrete_mission] ([id], [entite], [arrete], [type_arrete], [ouvert_par], [ouvert_le], [exercice], [date_arrete]) VALUES
        (N'1',N'OMEGA-OPCI',N'2025-12-31',N'ANNUEL',N'installation',N'2026-09-06 01:05:05.482',N'2025-12-31',N'2025-12-31'),
        (N'2',N'OMEGA-OPCI',N'2022-12-31',N'ANNUEL',N'installation',N'2026-09-06 16:18:48.389',N'2022-12-31',N'2022-12-31'),
        (N'3',N'OMEGA-OPCI',N'2023-12-31',N'ANNUEL',N'installation',N'2026-09-06 16:18:48.470',N'2023-12-31',N'2023-12-31'),
        (N'4',N'OMEGA-OPCI',N'2024-12-31',N'ANNUEL',N'installation',N'2026-09-06 16:18:48.475',N'2024-12-31',N'2024-12-31'),
        (N'6',N'OMEGA-OPCI',N'2026-06-30',N'SEMESTRIEL',N'installation',N'2026-09-09 12:06:56.784',N'2026-12-31',N'2026-06-30');
    PRINT 'arrete_mission : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'arrete_mission : deja chargee, rien a faire.';
GO
