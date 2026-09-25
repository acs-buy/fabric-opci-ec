
-- v_ecran_message change de source : elle lit la boite aux lettres, plus la trace d'audit.
-- SES COLONNES CHANGENT : genre et pose_le remplacent refuse_le. La table du modele est a reposer.
CREATE   VIEW dbo.v_ecran_message AS
SELECT m.pour,
       m.entite,
       m.genre,
       m.message,
       m.geste,
       m.procedure_nom,
       m.pose_le,
       DATEDIFF(MINUTE, m.pose_le, SYSUTCDATETIME()) AS il_y_a_minutes,
       m.pour + '|' + m.entite                       AS cle_ecran
FROM dbo.message_ecran m;

GO

