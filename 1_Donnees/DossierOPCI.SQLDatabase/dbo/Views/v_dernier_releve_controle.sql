
CREATE   VIEW dbo.v_dernier_releve_controle AS
SELECT r.vue, c.code, c.libelle, c.genre, c.fondement,
       r.lignes, r.anomalies, r.releve_le, r.releve_par, r.message,
       CASE WHEN r.message IS NOT NULL
            THEN N'à reprendre : ' + r.message
            WHEN c.genre = 'MESURE' AND r.lignes = 0
            THEN N'rien à mesurer'
            WHEN c.genre = 'MESURE'
            THEN CAST(r.lignes AS NVARCHAR (8)) + N' ligne(s) mesurée(s), sans anomalie'
            WHEN r.anomalies = 0 AND c.genre = 'ZERO_ATTENDU'
            THEN N'sans anomalie'
            WHEN r.anomalies = 0
            THEN N'sans anomalie sur ' + CAST(r.lignes AS NVARCHAR (8))
                 + N' ligne(s) rapprochée(s)'
            WHEN c.genre = 'ZERO_ATTENDU'
            THEN CAST(r.anomalies AS NVARCHAR (8)) + N' anomalie(s)'
            ELSE CAST(r.anomalies AS NVARCHAR (8)) + N' écart(s) sur '
                 + CAST(r.lignes AS NVARCHAR (8)) + N' ligne(s) rapprochée(s)'
            END                                    AS lecture
FROM dbo.releve_controle r
JOIN dbo.ref_controle c ON c.vue = r.vue
WHERE r.releve_le = (SELECT MAX(releve_le) FROM dbo.releve_controle);

GO

