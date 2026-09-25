-- ref_categorie_actif_cmf : 10 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_categorie_actif_cmf])
BEGIN
    INSERT INTO dbo.[ref_categorie_actif_cmf] ([rang], [libelle], [racines], [note], [modifie_par], [modifie_le]) VALUES
        (N'1',N'Des immeubles construits ou acquis en vue de la location, ainsi que des meubles meublants',N'211,213,214,221,228,23,243,245',N'Le rattachement aux racines suit le plan de l''article 411-3 du reglement ANC 2021-09.',NULL,NULL),
        (N'2',N'Des parts de sociétés de personnes qui ne sont pas admises aux négociations',N'252',NULL,NULL,NULL),
        (N'3',N'Des parts de sociétés de personnes autres que celles mentionnées au 2°',N'254',NULL,NULL,NULL),
        (N'4',N'Des actions négociées sur un marché',N'256',N'EXCLU du numerateur du ratio de 51 % et du denominateur du ratio d''endettement.',NULL,NULL),
        (N'5',N'Des parts ou actions d''organisme de placement collectif immobilier',N'258',NULL,NULL,NULL),
        (N'6',N'Des titres financiers mentionnés au II de l''article L. 211-1',N'30,31,32,33',NULL,NULL,NULL),
        (N'7',N'Des parts ou actions d''organismes de placement collectif en valeurs mobilières',N'34,35',NULL,NULL,NULL),
        (N'8',N'Des dépôts et des instruments financiers liquides',N'36,265',NULL,NULL,NULL),
        (N'9',N'Des liquidités définies par décret en Conseil d''Etat',N'511',N'Le decret n''est pas lu sur piece : le rattachement au compte 511 des comptes a vue est deduit du plan comptable, non du decret.',NULL,NULL),
        (N'10',N'Des avances en compte courant consenties en application de l''article L. 214-42',N'266',NULL,NULL,NULL);
    PRINT 'ref_categorie_actif_cmf : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_categorie_actif_cmf : deja chargee, rien a faire.';
GO
