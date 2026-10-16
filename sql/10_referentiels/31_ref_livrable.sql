-- ref_livrable : 6 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_livrable])
BEGIN
    INSERT INTO dbo.[ref_livrable] ([code], [libelle], [nature], [applicable], [article], [ordre], [modifie_par], [modifie_le], [formats], [produit_etape_6]) VALUES
        (N'ATTESTATION',N'Rapport de l''expert-comptable',N'DOCUMENT',N'ARRETE_CLOTURE',N'NP 2300, paragraphes 17 à 22 et A10, exemples E1 à E4',N'2',NULL,NULL,N'DOCX',N'1'),
        (N'COMPTES_ANNUELS',N'Comptes annuels : bilan, compte de résultat et annexe',N'DOCUMENT',N'ARRETE_CLOTURE',N'Reglement ANC 2021-09, art. 311-1',N'1',NULL,NULL,N'DOCX,XLSX',N'1'),
        (N'DIP',N'Document d''information périodique',N'DOCUMENT',N'ARRETE_VL',N'AMF, instruction DOC-2011-23',N'3',NULL,NULL,N'DOCX',N'1'),
        (N'DISTRIBUTION',N'Décision de distribution et mouvements par porteur',N'DECISION',N'ARRETE_CLOTURE',N'CMF, art. L. 214-69',N'5',NULL,NULL,NULL,N'0'),
        (N'INVENTAIRE',N'Inventaire du portefeuille',N'DOCUMENT',N'LES_DEUX',N'Reglement ANC 2021-09, art. 336-1 a 336-3',N'6',NULL,NULL,NULL,N'0'),
        (N'RAPPORT_ANNUEL',N'Rapport annuel',N'DOCUMENT',N'ARRETE_CLOTURE',N'CMF, art. L. 214-50 ; art. R. 214-125 pour le delai de 75 jours',N'4',NULL,NULL,NULL,N'0');
    PRINT 'ref_livrable : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_livrable : deja chargee, rien a faire.';
GO
