-- ref_nature_actif : 17 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_nature_actif])
BEGIN
    INSERT INTO dbo.[ref_nature_actif] ([nature], [libelle], [methode], [article], [expertise_requise], [modifie_par], [modifie_le], [reference_id]) VALUES
        (N'ACTION_ASSIMILEE',N'Actions et valeurs assimilees',N'Valeur actuelle des titres financiers, article 212-4 du reglement ANC 2020-07, par renvoi de l''article 113-2 du 2021-09. C''est la valeur probable de negociation hors frais de cession, article 211-5.',N'2020-07 art. 212-4',N'0',NULL,NULL,N'11'),
        (N'AVANCE_COMPTE_COURANT',N'Avance en compte courant dans une filiale ou participation',N'Montant nominal, majore des interets courus, revise a la baisse en cas d''evolution defavorable de la filiale',N'213-1 et 213-4',N'0',NULL,NULL,N'69'),
        (N'AVANCE_PRENEUR_CREDIT_BAIL',N'Avance-preneur relative a des biens pris en credit-bail',N'Comptabilisee dans les autres actifs a caractere immobilier, comptes 26 ; classement presente en annexe',N'213-2',N'0',NULL,NULL,N'67'),
        (N'BIEN_RENTE_VIAGERE',N'Bien acquis moyennant paiement de rentes viageres',N'Valeur actuelle apres la date d''entree dans le patrimoine',N'211-7',N'1',NULL,NULL,N'57'),
        (N'DEPOT',N'Depots',N'Nominal augmente ou minore des interets courus acquis a la date de valorisation, article 215-1 du reglement ANC 2020-07.',N'2020-07 art. 215-1',N'0',NULL,NULL,N'14'),
        (N'DEPOT_CAUTIONNEMENT_SYNDIC',N'Depots et cautionnements verses au syndic',N'Montant nominal, compte 265',N'213-3',N'0',NULL,NULL,N'68'),
        (N'DROIT_CREDIT_BAIL',N'Droit ne d''un contrat de credit-bail immobilier',N'Regime de l''article 211-8',N'211-8',N'1',NULL,NULL,N'58'),
        (N'DROIT_REEL',N'Droit reel immobilier',N'Valeur actuelle, meme regle que l''immeuble',N'211-6',N'1',NULL,NULL,N'56'),
        (N'IMMEUBLE',N'Immeuble bati, biens mobiliers compris',N'Valeur actuelle, hors droits de mutation, par la valeur de marche ou, a defaut de marche, par tous moyens externes ou par modeles financiers',N'211-6',N'1',NULL,NULL,N'56'),
        (N'IMMEUBLE_EN_CONSTRUCTION',N'Immeuble en cours de construction',N'Valeur actuelle par la valeur de marche en l''etat au jour de l''evaluation ; a defaut de determination fiable, maintien au prix de revient',N'211-6',N'1',NULL,NULL,N'56'),
        (N'INSTRUMENT_TERME',N'Instruments financiers a terme',N'Valeur actuelle, article 216-5 du reglement ANC 2020-07. La difference d''estimation releve de son article 216-6, et sa variation va au compte 105 par derogation de l''article 113-1 du reglement ANC 2021-09.',N'2020-07 art. 216-5',N'0',NULL,NULL,N'15'),
        (N'OBLIGATION_ASSIMILEE',N'Obligations et valeurs assimilees',N'Valeur actuelle des titres financiers, article 212-4 du reglement ANC 2020-07. Le mode de comptabilisation des coupons releve de l''article 211-16 du meme reglement.',N'2020-07 art. 212-4',N'0',NULL,NULL,N'11'),
        (N'OPERATION_TEMPORAIRE',N'Operations temporaires sur titres',N'Valeur contractuelle maintenue, articles 217-9 et suivants du reglement ANC 2020-07. Une pension a taux fixe, non resiliable sans cout et d''echeance superieure a 3 mois, s''evalue a la valeur actuelle du contrat.',N'2020-07 art. 217-9',N'0',NULL,NULL,N'17'),
        (N'PART_OPC',N'Organismes de placement collectif a capital variable, OPCVM et FIA',N'Derniere valeur liquidative connue, article 214-3 du reglement ANC 2020-07. Le gerant la corrige sous sa responsabilite si elle ne reflete pas la valeur actuelle des droits detenus, la correction etant significative.',N'2020-07 art. 214-3',N'0',NULL,NULL,N'13'),
        (N'TERRAIN',N'Terrain',N'Valeur actuelle, meme regle que l''immeuble',N'211-6',N'1',NULL,NULL,N'56'),
        (N'TITRE_CREANCE',N'Titres de creances',N'Methode actuarielle en l''absence de transactions significatives, aux taux des emissions equivalentes affectes de la marge de risque de l''emetteur, article 212-5 du reglement ANC 2020-07. Les autres titres de creances suivent les modalites de la societe de gestion.',N'2020-07 art. 212-5',N'0',NULL,NULL,N'12'),
        (N'TITRES_ENTITE_IMMOBILIERE',N'Parts et actions d''entites a actif principalement immobilier',N'Valeur actuelle du titre. Aucun rapport d''evaluateur sur le titre : les immeubles de l''entite detenue sont eux-memes evalues',N'212-4',N'0',NULL,NULL,N'63');
    PRINT 'ref_nature_actif : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_nature_actif : deja chargee, rien a faire.';
GO
