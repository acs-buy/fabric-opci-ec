-- 189 -- La reouverture d'un arrete n'a jamais pu s'executer, et voici pourquoi
-- 13/09/2026. Defaut trouve a l'usage, en rouvrant l'arrete du 31/12/2025 sur instruction du
-- candidat. Aucune reouverture n'avait jamais ete tentee depuis la creation de la procedure.
--
-- LE DEFAUT. dbo.pr_rouvrir_arrete inscrit le visa de renvoi en passant le MEME @par dans
-- propose_par et dans decide_par. La table dbo.visa porte la contrainte ck_visa_roles_separes,
-- ([propose_par] <> [decide_par]), qui interdit qu'une personne propose et decide le meme visa.
-- L'INSERT est donc refuse a coup sur, Msg 547. Ni propose_par ni decide_par n'acceptent NULL,
-- ce qui ferme le contournement le plus simple.
-- CETTE CONTRAINTE N'EST PAS UNE GENE, C'EST LA REGLE : celui qui propose un travail ne le vise
-- pas lui-meme. Ce qui est faux est la procedure, pas la contrainte.
--
-- LA CORRECTION RETENUE, ET LES 2 QUI ONT ETE ECARTEES.
--   RETENUE : un parametre de plus, @demande_par. Une reouverture se DEMANDE par celui qui
--     constate le lot tardif, et se DECIDE par le chef de mission. Les 2 roles existent dans la
--     vie du dossier ; il manquait seulement de les distinguer dans la procedure.
--   ECARTEE : exempter la nature CLOTURE de la contrainte. Elle reviendrait a lever la separation
--     des roles a l'endroit precis ou elle compte le plus, la cloture d'un arrete.
--   ECARTEE : reprendre le proposant du visa de cloture d'origine. L'ecriture passerait la
--     contrainte, mais elle attribuerait a l'associe signataire une demande qu'il n'a pas faite.
--
-- RELU AVANT REECRITURE : la procedure d'origine remet aussi a NULL les 4 colonnes
-- d'arret et de production de dbo.attestation, la forme etant a arreter de nouveau.
-- Ce bloc est repris tel quel ; sans cette relecture il aurait ete perdu.
--
-- LE PARAMETRE EST FACULTATIF ET VAUT SUSER_SNAME() PAR DEFAUT : un appel existant ne casse pas,
-- il echoue seulement si le demandeur et le decideur se trouvent etre la meme personne, ce qui est
-- exactement ce que la regle veut empecher. Le message le dit alors en clair, au lieu de laisser
-- remonter une violation de contrainte que personne ne peut lire.

CREATE   PROCEDURE dbo.pr_rouvrir_arrete
    @entite       VARCHAR (20),
    @arrete       VARCHAR (20),
    @motif        NVARCHAR (600),
    @par          NVARCHAR (400),
    @demande_par  NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @demandeur NVARCHAR (400) = ISNULL(@demande_par, SUSER_SNAME());

    IF @motif IS NULL OR LEN(LTRIM(@motif)) = 0
        THROW 50097,
            N'Réouverture refusée : elle exige un motif, qui dit quel lot tardif justifie de rouvrir un arrêté clôturé.',
            1;

    IF NOT EXISTS (SELECT 1 FROM dbo.visa v
                   WHERE v.nature = 'CLOTURE' AND v.entite = @entite
                     AND v.arrete = @arrete AND v.decision = 'VISE')
        THROW 50095,
            N'Réouverture refusée : l''étape 5 de cet arrêté n''est pas clôturée, il n''y a rien à rouvrir.',
            1;

    IF dbo.fn_peut_viser_nature(@entite, @par, 'CLOTURE',
                                CAST(SYSUTCDATETIME() AS DATE)) = 0
        THROW 50096,
            N'Réouverture refusée : elle relève du chef de mission, qui a clôturé l''arrêté.',
            1;

    -- 13/09/2026 : le refus que la contrainte rendait illisible, dit en clair.
    IF @demandeur = @par
        THROW 50099,
            N'Réouverture refusée : celui qui la demande ne peut pas la décider. Indiquer qui a constaté le lot tardif, le chef de mission décidant ensuite.',
            1;

    BEGIN TRANSACTION;
    -- Le visa de cloture est renvoye, non supprime : la trace demeure.
    INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle,
                          decision, motif, propose_par, decide_par, decide_le)
    VALUES ('CLOTURE', @entite + '|' + @arrete, @entite, @arrete, NULL,
            'RENVOYE', N'Réouverture : ' + @motif, @demandeur, @par,
            SYSUTCDATETIME());

    -- LES LIVRABLES PRODUITS DEVIENNENT PERIMES. C'est le SEUL evenement
    -- qui pose « perime » sur un document, ce que le point O19 exige.
    UPDATE dbo.document_produit
    SET perime_le = SYSUTCDATETIME(),
        perime_motif = N'Arrêté rouvert le '
                     + FORMAT(SYSUTCDATETIME(), 'dd/MM/yyyy', 'fr-FR')
                     + N' : ' + @motif
                     + N' Le document a été produit sur des comptes '
                     + N'antérieurs à la réouverture.'
    WHERE entite = @entite AND arrete = @arrete AND perime_le IS NULL;

    -- LA FORME DE L'ATTESTATION EST A ARRETER DE NOUVEAU.
    UPDATE dbo.attestation
    SET arretee_par = NULL, arretee_le = NULL,
        produit_par = NULL, produit_le = NULL
    WHERE entite = @entite AND arrete = @arrete;
    COMMIT TRANSACTION;
END;

GO

