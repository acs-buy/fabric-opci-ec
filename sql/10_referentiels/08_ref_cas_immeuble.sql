-- ref_cas_immeuble : 3 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_cas_immeuble])
BEGIN
    INSERT INTO dbo.[ref_cas_immeuble] ([cas], [libelle], [citation], [note], [ordre], [modifie_par], [modifie_le]) VALUES
        (N'R81-1',N'Immeuble loué ou offert à la location à la date de son acquisition',N'1° Les immeubles loues ou offerts a la location a la date de leur acquisition par l''organisme ou par toute personne morale ayant conclu une convention d''usufruit conformement au chapitre III du titre V du livre II du code de la construction et de l''habitation.',N'Le cas se constate a la DATE D''ACQUISITION : un immeuble acquis vide ne releve pas de ce cas, meme s''il est loue par la suite.',N'1',NULL,NULL),
        (N'R81-2',N'Immeuble construit, réhabilité ou rénové en vue de sa location',N'2° Les immeubles que l''organisme fait construire, rehabiliter ou renover en vue de leur location par lui-meme ou par toute personne morale ayant conclu une convention d''usufruit conformement au meme chapitre. Ces immeubles peuvent etre acquis par des contrats de vente a terme, de vente en l''etat futur d''achevement ou de vente d''immeubles a renover ou a rehabiliter.',N'La destination locative est la condition : une operation de construction destinee a la revente ne releve pas de ce cas.',N'2',NULL,NULL),
        (N'R81-3',N'Terrain nu situé en zone urbaine ou à urbaniser',N'3° Les terrains nus situes dans une zone urbaine ou a urbaniser delimitee par un document d''urbanisme.',N'Le document d''urbanisme est la piece justificative du cas : le zonage se justifie, il ne se presume pas.',N'3',NULL,NULL);
    PRINT 'ref_cas_immeuble : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_cas_immeuble : deja chargee, rien a faire.';
GO
