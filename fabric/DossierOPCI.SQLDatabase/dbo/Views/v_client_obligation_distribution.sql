
-- --- 5b : l'obligation de distribution, categorie par categorie ------------
-- Demande du candidat du 06/09/2026 : le client lit comment l'obligation minimale
-- se calcule, article L. 214-69 du CMF, II : la base, le taux et le montant de
-- chaque fraction. Les codes de dbo.obligation_distribution (script 52) sont
-- rapproches des categories du referentiel (script 58) pour en lire le libelle
-- et l'article ; une categorie non renseignee n'apparait pas.
CREATE   VIEW dbo.v_client_obligation_distribution AS
SELECT o.entite + '|' + o.exercice AS cle_arrete, o.entite, o.exercice AS arrete,
       r.ordre, r.libelle AS categorie, r.article,
       o.base_calcul,
       CAST(o.taux / 100.0 AS DECIMAL (9,4)) AS taux,
       o.montant AS obligation,
       o.dont_indirect_n_moins_1 AS report_indirect_n_moins_1,
       o.etat
FROM dbo.obligation_distribution o
JOIN dbo.ref_obligation_distribution r
  ON r.categorie = CASE o.categorie WHEN 'REVENUS_85'          THEN 'RESULTAT'
                                    WHEN 'PLUS_VALUES_50'      THEN 'PLUS_VALUES'
                                    WHEN 'DIVIDENDES_SIIC_100' THEN 'EXONEREES'
                                    ELSE o.categorie END
JOIN dbo.ref_arrete a ON a.entite = o.entite AND a.arrete = o.exercice
WHERE a.porte_balance = 1;

GO

