
-- --- 6 : les controles ----------------------------------------------
-- C51 : un compte rattache portant une entite liee sans symetrique
-- rattache chez elle.
-- ELLE N'EST PAS ATTENDUE A ZERO, et la mesure du 04/09/2026 le montre :
-- 36 couples sur 36 sont incomplets. Le motif est un fait du plan de
-- comptes, non un defaut : les 12 filiales portent chacune un compte
-- 4551 vers la mere, mais la mere porte UN SEUL compte 266 « Autres
-- creances immobilisees », global et non ventile par filiale. Le couple
-- ne se refermera que si le plan de la mere est subdivise par filiale,
-- ce que l'article 411-3 permet sans l'imposer. La vue mesure donc ce
-- qui reste a subdiviser, et le controle de symetrie du script 94
-- continue de rapprocher les 2 cotes par les montants.
CREATE   VIEW dbo.v_controle_couple_incomplet AS
SELECT entite_porteuse, compte_porteur, entite_liee
FROM dbo.v_couple_compte_intragroupe
WHERE symetrique_trouve = 0;

GO

