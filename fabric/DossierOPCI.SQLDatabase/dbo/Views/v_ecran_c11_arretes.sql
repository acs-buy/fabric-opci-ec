
-- L'arrete se filtre aussi sur l'arrete choisi : un reviseur qui travaille au 31/12/2025 n'a pas
-- a voir les 4 autres arretes de l'entite dans sa grille de saisie.
CREATE   VIEW dbo.v_ecran_c11_arretes AS
SELECT t.* FROM dbo.arrete_mission t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p
              WHERE p.entite = t.entite AND p.arrete = t.arrete);

GO

