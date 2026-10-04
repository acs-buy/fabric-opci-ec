
-- Le controle : un terme de formule qui ne designe aucune ligne de son etat. ATTENDU zero.
CREATE   VIEW dbo.v_controle_formule_ligne_etat AS
SELECT l.etat, l.code, LTRIM(RTRIM(REPLACE(s.value, N'-', N''))) AS terme_inconnu, l.formule
FROM dbo.ref_ligne_etat l
CROSS APPLY STRING_SPLIT(REPLACE(l.formule, N' - ', N' + -'), N'+') s
WHERE l.type_ligne IN ('TOTAL', 'RESULTAT') AND l.formule IS NOT NULL AND l.formule <> N'somme des lignes de detail'
  AND NOT EXISTS (SELECT 1 FROM dbo.ref_ligne_etat x WHERE x.etat = l.etat AND x.code = LTRIM(RTRIM(REPLACE(s.value, N'-', N''))));

GO

