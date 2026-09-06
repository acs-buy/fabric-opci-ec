
-- --- E3 : la publication, avec l'etat bloquee ---------------------
-- La vue supprimait la ligne quand un lot propose couvrait l'arrete :
-- l'ecran perdait la ligne « Arrete » et le chef de mission ne voyait
-- plus ce qui bloquait. Elle rend desormais la ligne, avec son etat.
CREATE   VIEW dbo.v_a_viser_publication AS
SELECT v.entite, v.arrete, CAST(NULL AS VARCHAR (10)) AS cycle,
       'PUBLICATION'                                  AS nature,
       CAST(v.entite + '|' + v.arrete AS VARCHAR (30)) AS objet_ref,
       CAST(N'Valeur liquidative de ' + CAST(v.valeur_liquidative AS NVARCHAR (30))
            + N' pour ' + CAST(v.nombre_parts AS NVARCHAR (30)) + N' parts'
            + CASE WHEN bloq.lots_proposes > 0
                   THEN N', BLOQUEE par ' + CAST(bloq.lots_proposes AS NVARCHAR (10))
                        + N' lot(s) propose(s)'
                   ELSE N'' END AS NVARCHAR (300))     AS libelle,
       dbo.fn_proposant('PUBLICATION', v.entite + '|' + v.arrete)
                                                      AS propose_par,
       (SELECT MAX(l.cree_le) FROM dbo.lot_ecritures l
        WHERE l.entite = v.entite AND l.arrete = v.arrete) AS propose_le,
       bloq.lots_proposes                             AS lignes,
       v.actif_net_reevalue                           AS montant,
       CASE WHEN bloq.lots_proposes > 0 THEN 'BLOQUEE' ELSE 'CALCULEE' END
                                                      AS etat
FROM dbo.v_valeur_liquidative v
CROSS APPLY (
    SELECT COUNT(*) AS lots_proposes FROM dbo.lot_ecritures l
    WHERE l.entite = v.entite AND l.arrete = v.arrete AND l.statut = 'PROPOSE'
) AS bloq
WHERE v.valeur_liquidative IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.publication_vl p
                  WHERE p.entite = v.entite AND p.arrete = v.arrete);

GO

