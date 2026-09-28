
-- LES COMPTES D'UN CYCLE A UN ARRETE : les comptes en balance dont le numero commence par une racine
-- du cycle, ref_cycle_compte.
CREATE   FUNCTION dbo.fn_comptes_du_cycle (@entite VARCHAR (20), @arrete VARCHAR (20), @cycle VARCHAR (10))
RETURNS TABLE
AS
RETURN
SELECT DISTINCT c.compte
FROM dbo.v_comptes_en_balance c
JOIN dbo.ref_cycle_compte rc ON rc.cycle = @cycle AND c.compte LIKE rc.racine + '%'
WHERE c.entite = @entite AND c.arrete = @arrete;

GO

