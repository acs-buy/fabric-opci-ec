
-- La derniere version de chaque arrete de mission, une ligne par cellule : ce que lisent l'ecran et le Word.
CREATE   VIEW dbo.v_annexe_cellule AS
SELECT c.entite, c.arrete, c.version, c.article, c.ligne, c.colonne, c.libelle, c.ordre, c.groupe, c.signe, c.valeur_numerique,
       c.valeur_texte, c.format, c.etat, c.texte_affiche, c.texte_imprime, c.obligation, c.nature, c.comptee, c.attend_exigee,
       c.attend, c.regle, c.source, c.formule, c.motif, c.valeur_base, c.saisie_ecartee, c.calcul_id, c.calcule_le, c.calcule_par,
       t.libelle AS article_libelle, CAST(ISNULL(t.indicatif, 0) AS BIT) AS indicatif
FROM dbo.v_annexe_version v
JOIN dbo.cellule_annexe c ON c.entite = v.entite AND c.arrete = v.arrete AND c.version = v.derniere_version
LEFT JOIN dbo.ref_tableau_annexe t ON t.article = c.article;

GO

