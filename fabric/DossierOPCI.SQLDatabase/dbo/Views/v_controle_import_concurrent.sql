-- C27 : 2 imports charges sur le meme perimetre. Le second aurait
-- remplace le premier sans que rien ne le dise. ATTENDU zero.
CREATE   VIEW dbo.v_controle_import_concurrent AS
SELECT entite, arrete, COUNT(*) AS imports_charges
FROM dbo.import_fec WHERE statut = 'CHARGE'
GROUP BY entite, arrete HAVING COUNT(*) > 1;

GO

