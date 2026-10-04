
CREATE   VIEW dbo.v_sommes_distribuables AS
SELECT entite, arrete, resultat_distribuable, plus_values_distribuables, total_distribuable,
       acomptes_verses, acomptes_non_repartis, repartition_connue, source
FROM dbo.fn_sommes_distribuables();

GO

