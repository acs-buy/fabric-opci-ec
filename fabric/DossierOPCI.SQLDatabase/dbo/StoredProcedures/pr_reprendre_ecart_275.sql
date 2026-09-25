
-- --- 5 : la reprise du compte 275, a blanc par defaut ---------------
-- LE MONTANT SE PROUVE PAR 2 CHEMINS. La vue le calcule en rapprochant
-- la valeur actuelle des titres, actif net REEVALUE de chaque filiale a
-- la quote-part, de ce que la mere porte aux comptes 254 et 275. Sur
-- l'arrete du 31/12/2024, ce rapprochement rend 0,00 : le calcul est
-- donc cale sur un exercice ou rien n'a bouge. Sur celui du 31/12/2025,
-- il rend 194 736,70, soit exactement le dividende que le script 126 a
-- comptabilise chez OMEGA-SCI-12.
CREATE   PROCEDURE dbo.pr_reprendre_ecart_275
    @entite   VARCHAR (20),
    @arrete   VARCHAR (20),
    @a_blanc  BIT            = 1,
    @par      NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @qui NVARCHAR (400) = ISNULL(@par, SUSER_SNAME());
    DECLARE @montant DECIMAL (19,2), @cible DECIMAL (19,2);
    SELECT @montant = a_passer, @cible = ecart_275_cible
    FROM dbo.v_reprise_275_a_passer
    WHERE entite = @entite AND arrete = @arrete;

    IF @montant IS NULL
        THROW 50079, N'Reprise refusée : aucun rapprochement du compte 275 pour cette entité et cet arrêté.', 1;

    IF ABS(@montant) < 0.005
    BEGIN
        SELECT N'aucune reprise : le compte 275 égale déjà sa cible' AS lecture,
               @cible AS cible;
        RETURN;
    END;

    IF @a_blanc = 1
    BEGIN
        SELECT N'A BLANC, RIEN N''EST ECRIT' AS mode, @montant AS a_passer,
               @cible AS cible_du_275,
               CASE WHEN @montant > 0 THEN N'débit 275 par crédit 105'
                    ELSE N'crédit 275 par débit 105' END AS sens;
        RETURN;
    END;

    DECLARE @cote VARCHAR (30) = 'VAL275-' + @arrete;
    IF NOT EXISTS (SELECT 1 FROM dbo.feuille_travail WHERE cote = @cote)
        INSERT INTO dbo.feuille_travail
            (cote, cycle, arrete, entite, modele_code, origine, nom_fichier,
             chemin_coffre, empreinte_sha256, conclusion, preparateur, prepare_le)
        VALUES (@cote, 'PART', @arrete, @entite, NULL, 'MOTEUR',
                N'reprise_275_' + @arrete + N'.csv',
                N'/Coffre/' + @entite + N'/' + @arrete + N'/feuilles/reprise_275.csv',
                CONVERT(CHAR (64), HASHBYTES('SHA2_256',
                    N'275|' + @entite + N'|' + @arrete + N'|'
                    + CONVERT(NVARCHAR (40), @cible)), 2),
                N'Reprise du compte 275 : la valeur actuelle des titres, actif net réévalué de chaque filiale à la quote-part, moins ce que porte le compte 254.',
                @qui, SYSUTCDATETIME());

    DECLARE @lot INT;
    INSERT INTO dbo.lot_ecritures
        (arrete, famille, portee, entite, statut, feuille_cote,
         version_regles, motif, cree_par, statut_par, statut_le)
    VALUES (@arrete, 'DERIVABLE', 'ENTITE', @entite, 'PROPOSE', @cote,
            'val275-v1',
            N'Reprise du compte 275 après la baisse de l''actif net d''une filiale. Les filiales étant tenues en valeur historique, la mère seule porte la différence d''estimation.',
            @qui, @qui, SYSUTCDATETIME());
    SET @lot = CAST(SCOPE_IDENTITY() AS INT);

    INSERT INTO dbo.ecriture
        (lot_id, journal_code, journal_lib, ecriture_num, ecriture_date,
         compte_num, compte_lib, ecriture_lib, debit, credit, famille)
    SELECT @lot, 'ODV', N'OD de valorisation', x.num,
           (SELECT TOP 1 date_arrete FROM dbo.ref_arrete
            WHERE arrete = @arrete AND entite = @entite),
           x.compte, x.lib,
           N'Reprise du compte 275 sur la valeur actuelle des titres',
           x.debit, x.credit, 'DERIVABLE'
    FROM (VALUES
        ('275-REPRISE-1', '275', N'Différence d''estimation sur parts',
         CASE WHEN @montant > 0 THEN ABS(@montant) ELSE 0 END,
         CASE WHEN @montant > 0 THEN 0 ELSE ABS(@montant) END),
        ('275-REPRISE-2', '105', N'Variation des différences d''estimation',
         CASE WHEN @montant > 0 THEN 0 ELSE ABS(@montant) END,
         CASE WHEN @montant > 0 THEN ABS(@montant) ELSE 0 END)
    ) AS x (num, compte, lib, debit, credit);

    -- L'AXE DU COMPTE 275, exige par le controle C7. Un compte qui porte
    -- un actif dit LEQUEL : la reprise concerne les titres de la filiale
    -- dont l'actif net a bouge, non le poste dans son ensemble. Le
    -- controle v_controle_axe_manquant a nomme l'oubli des la premiere
    -- execution, le 05/09/2026.
    INSERT INTO dbo.ecriture_axe (ecriture_id, entite, code_actif)
    SELECT e.id, @entite, t.code
    FROM dbo.ecriture e
    CROSS APPLY (
        -- La filiale dont la valeur des titres a bouge : celle dont
        -- l'ecart entre l'actif net reevalue et sa quote-part
        -- comptabilisee explique la reprise. A defaut d'une ventilation
        -- par filiale du compte 275, l'axe porte la filiale dont
        -- l'actif net a varie depuis l'arrete precedent.
        SELECT TOP 1 a.code
        FROM dbo.actif a
        JOIN dbo.detention d ON d.entite_fille = a.entite_liee
                            AND d.entite_mere = @entite
                            AND d.arrete = @arrete
        WHERE a.nature = 'TITRES_ENTITE_IMMOBILIERE'
          AND a.entite_detentrice = @entite
          AND EXISTS (SELECT 1 FROM dbo.lot_ecritures l2
                      WHERE l2.entite = a.entite_liee
                        AND l2.arrete = @arrete
                        AND l2.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
                        AND l2.motif LIKE N'%miroir%')
        ORDER BY a.code
    ) AS t
    WHERE e.lot_id = @lot AND e.compte_num = '275'
      AND NOT EXISTS (SELECT 1 FROM dbo.ecriture_axe x2
                      WHERE x2.ecriture_id = e.id);

    SELECT @lot AS lot_pose, @montant AS montant, @cible AS cible_du_275,
           N'le lot est au statut PROPOSE : l''actif net ne bouge qu''à son visa'
                                                        AS lecture;
END;

GO

