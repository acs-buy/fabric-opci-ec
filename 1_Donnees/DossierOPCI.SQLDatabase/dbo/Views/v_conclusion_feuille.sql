
-- --- 8 : la conclusion d'une feuille, avec son paragraphe ----------
CREATE   VIEW dbo.v_conclusion_feuille AS
SELECT f.cote, f.entite, f.arrete, f.cycle, f.forme_conclusion,
       fc.libelle                                     AS forme_libelle,
       CAST(fc.favorable AS BIT)                      AS favorable,
       fc.citation_courte,
       fc.paragraphe_intitule,
       f.conclusion, f.conclue_par, f.conclue_le, f.reviseur, f.revise_le
FROM dbo.feuille_travail f
LEFT JOIN dbo.v_forme_conclusion fc ON fc.code = f.forme_conclusion
WHERE f.forme_conclusion IS NOT NULL;

GO

