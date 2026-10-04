
-- Le plafond lit la definition unique.
CREATE   VIEW dbo.v_plafond_distribuable AS
SELECT entite, arrete, resultat_distribuable, plus_values_distribuables,
       total_distribuable AS plafond_distribuable
FROM dbo.v_sommes_distribuables;

GO

