-- ref_correspondance_plan : 13 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_correspondance_plan])
BEGIN
    INSERT INTO dbo.[ref_correspondance_plan] ([norme_source], [compte_source], [compte_modele], [motif], [reference_id], [modifie_par], [modifie_le]) VALUES
        (N'PCG',N'101',N'101',N'Capital : meme numero et meme sens dans les 2 plans.',N'130',NULL,NULL),
        (N'PCG',N'110',N'111',N'Report a nouveau : le PCG porte 110 « Report a nouveau (solde crediteur) », le plan de l''article 411-3 porte 111 « Report a nouveau ».',N'130',NULL,NULL),
        (N'PCG',N'120',N'120',N'Resultat de l''exercice : meme numero et meme sens dans les 2 plans.',N'130',NULL,NULL),
        (N'PCG',N'164',N'512',N'L''emprunt bancaire de la filiale finance son immeuble : il se lit comme un emprunt lie a un actif immobilier. Le PCG le classe en 16, classe 1, comptes de capitaux ; le plan de l''article 411-3 en classe 5. CHANGEMENT DE CLASSE VOULU.',N'137',NULL,NULL),
        (N'PCG',N'211',N'211',N'Terrains : meme numero et meme intitule dans les 2 plans.',N'138',NULL,NULL),
        (N'PCG',N'213',N'213',N'Constructions : meme numero et meme intitule dans les 2 plans, verifie page 135 du PCG et a l''article 411-3.',N'139',NULL,NULL),
        (N'PCG',N'4551',N'512',N'Le compte courant que l''OPCI associe met a disposition de sa filiale finance l''acquisition de son immeuble : il se lit, au plan de l''article 411-3, comme un emprunt lie a un actif immobilier. Le PCG le classe en classe 4, comptes de tiers, article 1214-45 ; le plan de l''article 411-3 classe les emprunts en classe 5. LE CHANGEMENT DE CLASSE EST VOULU.',N'136',NULL,NULL),
        (N'PCG',N'4558',N'518',N'Les interets courus sur le compte courant d''associe se lisent au compte 518 « Interets courus » du plan de l''article 411-3. Meme changement de classe, 4 vers 5.',N'136',NULL,NULL),
        (N'PCG',N'512',N'511',N'PIEGE DE COLLISION. Le PCG porte 512 « Banques » tandis que le plan de l''article 411-3 porte 512 « Emprunts lies a des actifs immobiliers » : LE MEME NUMERO DESIGNE UN ACTIF DANS UN PLAN ET UN PASSIF DANS L''AUTRE. La banque d''une filiale se lit au compte 511 « Comptes a vue » du plan de l''article 411-3.',N'130',NULL,NULL),
        (N'PCG',N'615',N'624',N'Les charges d''entretien du patrimoine locatif se lisent au compte 624 du plan de l''article 411-3.',N'130',NULL,NULL),
        (N'PCG',N'6611',N'623',N'Les interets de l''emprunt bancaire affecte a l''immeuble relevent de la meme regle, article 322-5.',N'95',NULL,NULL),
        (N'PCG',N'6615',N'623',N'Les interets du compte courant d''associe remunerent un financement affecte a un actif immobilier : l''article 322-5 du reglement ANC 2021-09 les range dans les charges de l''activite immobiliere, au compte 623.',N'95',NULL,NULL),
        (N'PCG',N'706',N'721',N'Les loyers percus par la filiale se lisent au compte 721 « Loyers » du plan de l''article 411-3.',N'130',NULL,NULL);
    PRINT 'ref_correspondance_plan : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_correspondance_plan : deja chargee, rien a faire.';
GO
