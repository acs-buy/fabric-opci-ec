-- ref_droit_reel : 7 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_droit_reel])
BEGIN
    INSERT INTO dbo.[ref_droit_reel] ([droit], [libelle], [citation], [note], [ordre], [modifie_par], [modifie_le]) VALUES
        (N'R82-1',N'Propriété, nue-propriété et usufruit',N'1° La propriete, la nue-propriete et l''usufruit.',NULL,N'1',NULL,NULL),
        (N'R82-2',N'Emphytéose',N'2° L''emphyteose.',NULL,N'2',NULL,NULL),
        (N'R82-3',N'Servitudes',N'3° Les servitudes.',NULL,N'3',NULL,NULL),
        (N'R82-4',N'Droits du preneur d''un bail à construction ou à réhabilitation',N'4° Les droits du preneur d''un bail a construction ou d''un bail a rehabilitation.',NULL,N'4',NULL,NULL),
        (N'R82-5',N'Droit réel sur une dépendance du domaine public',N'5° Tout droit reel confere par un titre ou par un bail emphyteotique a raison de l''occupation d''une dependance du domaine public de l''Etat, d''une collectivite territoriale, ou d''un etablissement public sur les ouvrages, constructions et installations de caractere immobilier realises sur cette dependance.',NULL,N'5',NULL,NULL),
        (N'R82-6',N'Autres droits de superficie',N'6° Les autres droits de superficie.',NULL,N'6',NULL,NULL),
        (N'R82-7',N'Droit étranger comparable à l''un des droits des 1° à 6°',N'7° Tout droit relevant d''un droit etranger et comparable a l''un des droits mentionnes aux 1° a 6°.',N'Ce cas exige une analyse du droit local : la comparabilite se justifie au dossier.',N'7',NULL,NULL);
    PRINT 'ref_droit_reel : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_droit_reel : deja chargee, rien a faire.';
GO
