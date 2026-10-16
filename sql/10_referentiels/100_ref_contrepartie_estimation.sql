-- ref_contrepartie_estimation : 7 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_contrepartie_estimation])
BEGIN
    INSERT INTO dbo.[ref_contrepartie_estimation] ([compte_estimation], [compte_contrepartie], [motif], [article], [modifie_par], [modifie_le], [reference_id]) VALUES
        (N'271',N'1052',N'Immeubles locatifs : le libelle de 1052 couvre les comptes d''immeubles construits ou acquis',N'411-3',NULL,NULL,N'130'),
        (N'272',N'1052',N'Immobilisations en cours : le libelle de 1052 couvre les immeubles en cours',N'411-3',NULL,NULL,N'130'),
        (N'273',N'1052',N'Autres droits reels : le libelle de 1052 les nomme',N'411-3',NULL,NULL,N'130'),
        (N'274',N'1052',N'Contrats de credit-bail : droits reels au sens du libelle de 1052',N'411-3',NULL,NULL,N'130'),
        (N'275',N'105',N'Titres a caractere immobilier : aucune subdivision de 105 ne les couvre, ni 1052 qui vise les immeubles et droits reels, ni 1053 qui vise les depots et instruments financiers. La contrepartie est le compte 105 lui-meme',N'411-3 et 411-1',NULL,NULL,N'130'),
        (N'276',N'105',N'Autres actifs immobiliers, dont les avances en compte courant : l''article 213-4 nomme explicitement le compte 105',N'213-4',NULL,NULL,N'69'),
        (N'37',N'1053',N'Depots et instruments financiers et assimiles, classe 3 : le libelle de 1053 les nomme',N'411-3',NULL,NULL,N'130');
    PRINT 'ref_contrepartie_estimation : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_contrepartie_estimation : deja chargee, rien a faire.';
GO
