
-- C69 : un immeuble sans adresse, surface ou secteur. L'article 336-2
-- les exige actif par actif, et aucune liberte de globalisation ne les
-- couvre : seuls la valeur actuelle et le pourcentage sont
-- globalisables. La vue mesure ce qui reste a saisir.
CREATE   VIEW dbo.v_controle_inventaire_incomplet AS
SELECT entite, arrete, code_actif, adresse, surface_m2, secteur, etat
FROM dbo.v_inventaire_immeubles
WHERE etat <> N'complet';

GO

