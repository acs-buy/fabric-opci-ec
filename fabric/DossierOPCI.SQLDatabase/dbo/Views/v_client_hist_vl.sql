-- La valeur liquidative des seuls arretes vises pour le client : la valeur precedente et l'ecart se lisent sur
-- l'arrete vise precedent de la meme entite.
CREATE   VIEW dbo.v_client_hist_vl AS
SELECT v.entite, v.arrete, v.actif_net_reevalue, v.nombre_parts, v.source,
       v.version_regles, v.valeur_liquidative, v.motif_refus,
       LAG(v.valeur_liquidative) OVER (PARTITION BY v.entite ORDER BY v.arrete)
           AS valeur_liquidative_precedente,
       CAST(v.valeur_liquidative
          - LAG(v.valeur_liquidative) OVER (PARTITION BY v.entite ORDER BY v.arrete)
            AS DECIMAL (19,2)) AS ecart,
       v.arrete_libelle
FROM dbo.v_valeur_liquidative v
WHERE EXISTS (SELECT 1 FROM dbo.v_arrete_client c WHERE c.entite = v.entite AND c.arrete = v.arrete);

GO

