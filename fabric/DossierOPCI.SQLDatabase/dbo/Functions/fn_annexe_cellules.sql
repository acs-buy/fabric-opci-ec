
-- Les cellules d'une version donnee (contrat, 1.4) : la relecture d'un document passe sa version.
CREATE   FUNCTION dbo.fn_annexe_cellules (@entite VARCHAR (20), @arrete VARCHAR (20), @version INT)
RETURNS TABLE
AS
RETURN
    SELECT c.entite, c.arrete, c.version, c.article, c.ligne, c.colonne, c.libelle, c.ordre, c.groupe, c.signe, c.valeur_numerique,
           c.valeur_texte, c.format, c.etat, c.texte_affiche, c.texte_imprime, c.obligation, c.nature, c.comptee, c.attend_exigee,
           c.attend, c.regle, c.source, c.formule, c.motif, c.valeur_base, c.saisie_ecartee, c.calcul_id, c.calcule_le, c.calcule_par,
           t.libelle AS article_libelle, CAST(ISNULL(t.indicatif, 0) AS BIT) AS indicatif
    FROM dbo.cellule_annexe c
    LEFT JOIN dbo.ref_tableau_annexe t ON t.article = c.article
    WHERE c.entite = @entite AND c.arrete = @arrete AND c.version = @version;

GO

