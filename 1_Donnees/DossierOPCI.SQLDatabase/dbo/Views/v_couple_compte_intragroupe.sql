
-- Le couple de comptes que l'entite liee rend lisible.
CREATE   VIEW dbo.v_couple_compte_intragroupe AS
SELECT rce.entite                          AS entite_porteuse,
       rce.compte_entite                   AS compte_porteur,
       rce.libelle_entite                  AS libelle_porteur,
       rce.compte_modele                   AS compte_modele_porteur,
       rce.entite_liee,
       -- Le compte symetrique chez l'entite liee, s'il est rattache.
       sym.compte_entite                   AS compte_symetrique,
       sym.compte_modele                   AS compte_modele_symetrique,
       CAST(CASE WHEN sym.compte_entite IS NULL THEN 0 ELSE 1 END AS BIT)
                                           AS symetrique_trouve
FROM dbo.ref_compte_entite rce
OUTER APPLY (
    SELECT TOP 1 s.compte_entite, s.compte_modele
    FROM dbo.ref_compte_entite s
    WHERE s.entite = rce.entite_liee
      AND s.entite_liee = rce.entite
) AS sym
WHERE rce.entite_liee IS NOT NULL;

GO

