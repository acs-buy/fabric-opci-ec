
-- ------------------------------------------------------------------ n° 26 : le rang d'affichage d'une entite
-- Une seule regle pour tout l'ecran : vehicule en dernier (forme_vehicule renseignee), puis longueur du code, puis code.
CREATE   VIEW dbo.v_ordre_entite AS
SELECT e.code AS entite,
       CAST(ROW_NUMBER() OVER (ORDER BY CASE WHEN e.forme_vehicule IS NOT NULL THEN 1 ELSE 0 END, LEN(e.code), e.code) AS INT) AS ordre
FROM dbo.ref_entite e;

GO

