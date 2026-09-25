-- role_nature_visa : 12 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[role_nature_visa])
BEGIN
    INSERT INTO dbo.[role_nature_visa] ([role_code], [nature], [motif], [modifie_par], [modifie_le]) VALUES
        (N'ASSOCIE',N'ACCEPTATION',N'L''acceptation d''une mission engage la structure : article 150 du code de deontologie, « les personnes mentionnees a l''article 141 apprecient la possibilite de l''effectuer », et NPMQ paragraphe 18, « la structure ... peut accepter ou maintenir ». Choix d''organisation du cabinet, inversable ici.',NULL,NULL),
        (N'ASSOCIE',N'MAINTIEN',N'Le maintien est le meme jugement que l''acceptation, porte periodiquement : article 150 alinea 2, « elles examinent periodiquement, pour leurs missions recurrentes, si des circonstances nouvelles ne remettent pas en cause la poursuite de celles-ci ».',NULL,NULL),
        (N'ASSOCIE',N'OBLIGATION',N'L''obligation de distribution sort vers le porteur comme la publication, et le meme role signe les 2. Choix d''organisation du cabinet, non regle normative : inversable ici.',NULL,NULL),
        (N'ASSOCIE',N'PUBLICATION',N'La valeur liquidative publiee sort vers le porteur et vers le regulateur : elle engage la signature.',NULL,NULL),
        (N'CHEF_MISSION',N'CLOTURE',N'La cloture de l''etape 5 ferme l''arrete et rend les livrables editables : elle releve de celui qui conduit la mission, NPMQ paragraphe 30. L''associe signe l''attestation, le chef de mission ferme le dossier.',NULL,NULL),
        (N'CHEF_MISSION',N'CONCLUSION',N'La conclusion d''une feuille de travail est un jugement technique : la revue de dossier releve du responsable de la mission, NPMQ paragraphe 30.',NULL,NULL),
        (N'CHEF_MISSION',N'CYCLE',N'La conclusion d''un cycle de revision est un jugement technique sur le dossier : la revue de dossier releve du responsable de la mission, NPMQ paragraphe 30, comme la conclusion d''une feuille. Choix d''organisation du cabinet, inversable ici.',NULL,NULL),
        (N'CHEF_MISSION',N'DEROGATION',N'Une derogation ecarte une regle interne du cabinet : elle se vise par celui qui conduit la mission.',NULL,NULL),
        (N'CHEF_MISSION',N'EVALUATION',N'La valeur retenue par le cabinet est un jugement technique sur un actif, et elle se vise avant la generation du lot qui la porte.',NULL,NULL),
        (N'CHEF_MISSION',N'LOT',N'Le lot d''ecritures releve de la conduite de la mission, NPMQ paragraphe 30.',NULL,NULL),
        (N'CHEF_MISSION',N'REVUE',N'La conclusion generale de la revue ferme le dossier de travail de l''arrete : elle releve de celui qui conduit la mission, NPMQ paragraphe 30 ; l''associe signe l''attestation, pas la revue. Choix d''organisation du cabinet, inversable ici.',NULL,NULL),
        (N'CHEF_MISSION',N'SYNTHESE',N'La synthese atteste que la rationalisation de l''actif net boucle et que la valeur liquidative est calculable : c''est un jugement technique sur le dossier, NPMQ paragraphe 30, comme le visa d''un lot ou d''une conclusion.',NULL,NULL);
    PRINT 'role_nature_visa : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'role_nature_visa : deja chargee, rien a faire.';
GO
