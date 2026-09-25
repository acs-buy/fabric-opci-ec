
-- LA PROCEDURE FIGE, ELLE NE COMPARE PAS. Deux gestes distincts : figer
-- avant de toucher, comparer apres. Les melanger ferait disparaitre
-- l'ecart au moment meme ou il apparait.
CREATE   PROCEDURE dbo.pr_figer_mesures
    @motif NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.mesure_reference;

    INSERT INTO dbo.mesure_reference (code, libelle, cle, valeur, motif)
    SELECT 'ANR_ENTITE', N'Actif net réévalué par entité et par arrêté',
           entite + '|' + arrete, actif_net_reevalue, @motif
    FROM dbo.v_anr_entite;

    INSERT INTO dbo.mesure_reference (code, libelle, cle, valeur, motif)
    SELECT 'RATIONALISATION', N'Écart de la rationalisation de l''actif net',
           entite + '|' + arrete, ecart, @motif
    FROM dbo.v_controle_rationalisation;

    INSERT INTO dbo.mesure_reference (code, libelle, cle, valeur, motif)
    SELECT 'ANNEXE_333_1', N'Écart du tableau 333-1 à l''actif net',
           entite + '|' + arrete, ecart, @motif
    FROM dbo.v_controle_annexe_333_1;

    INSERT INTO dbo.mesure_reference (code, libelle, cle, valeur, motif)
    SELECT 'BILAN', N'Écart d''équilibre du bilan',
           entite + '|' + arrete, ecart, @motif
    FROM dbo.v_controle_bilan_desequilibre;

    INSERT INTO dbo.mesure_reference (code, libelle, cle, valeur, motif)
    SELECT 'RATIO', N'Ratio réglementaire',
           entite + '|' + arrete + '|' + code, ratio, @motif
    FROM dbo.v_ratio_arrete;

    INSERT INTO dbo.mesure_reference (code, libelle, cle, valeur, motif)
    SELECT 'SOLDE_COMPTE', N'Solde par entité, arrêté et compte du modèle',
           entite + '|' + arrete + '|' + compte_num,
           SUM(debit) - SUM(credit), @motif
    FROM dbo.v_ecriture_normalisee
    WHERE statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
    GROUP BY entite, arrete, compte_num;

    SELECT code, COUNT(*) AS mesures FROM dbo.mesure_reference
    GROUP BY code ORDER BY code;
END;

GO

