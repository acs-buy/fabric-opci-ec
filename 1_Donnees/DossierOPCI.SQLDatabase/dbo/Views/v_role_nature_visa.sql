
-- --- 2 : la vue de la repartition des visas, pour lecture -------
CREATE   VIEW dbo.v_role_nature_visa AS
SELECT n.role_code, r.libelle AS role_libelle, n.nature, n.motif,
       CAST(r.vise AS BIT) AS role_habilite
FROM dbo.role_nature_visa n
JOIN dbo.ref_role r ON r.code = n.role_code;

GO

