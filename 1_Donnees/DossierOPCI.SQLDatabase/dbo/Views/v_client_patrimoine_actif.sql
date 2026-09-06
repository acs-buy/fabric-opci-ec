
CREATE   VIEW dbo.v_client_patrimoine_actif AS
SELECT p.entite + '|' + p.arrete AS cle_arrete, p.entite, p.arrete,
       p.code_actif, p.famille,
       CASE p.famille WHEN 'IMMEUBLE'       THEN N'Immeuble'
                      WHEN 'TITRE'          THEN N'Titres'
                      WHEN 'COMPTE_COURANT' THEN N'Compte courant'
                      WHEN 'INSTRUMENT'     THEN N'Instrument'
                      ELSE p.famille END    AS famille_libelle,
       p.poste_bilan, p.valeur_comptable, p.valeur_actuelle, p.difference_estimation,
       CASE p.source WHEN 'EXPERTISE'   THEN N'Expertise'
                     WHEN 'ANR_FILIALE' THEN N'Actif net réévalué de la filiale'
                     WHEN 'NOMINAL'     THEN N'Montant nominal'
                     ELSE p.source END    AS source_libelle,
       p.article, p.entite_liee, p.quote_part
FROM dbo.v_patrimoine_valorise p
JOIN dbo.ref_arrete r ON r.entite = p.entite AND r.arrete = p.arrete
WHERE r.porte_balance = 1
  AND p.code_actif NOT LIKE 'IR4-%';

GO

