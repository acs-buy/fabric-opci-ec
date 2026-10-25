-- 2. L'outil du script : le message de reussite de la validation
-- ecran 5, lot 1, script 324 (61_DEPLOIEMENT/generer_e5_324_questions.py) : genere, ne pas modifier a la main.
-- Objet n° 32 : le message de reussite, au caractere pres sur message_resultat de la maquette (« 1 question validee »
-- au singulier, « dans la phase » pour une phase) ; le nom d'usage est celui de v_ecran_cycle_ou_phase.
CREATE   FUNCTION dbo.fn_e5_message_validation (@nom NVARCHAR (400), @genre VARCHAR (5), @n INT)
RETURNS NVARCHAR (600)
AS
BEGIN
    RETURN @nom + N' : ' + CAST(@n AS NVARCHAR (12))
         + CASE WHEN @n < 2 THEN N' question validée' ELSE N' questions validées' END
         + CASE WHEN @genre = 'PHASE' THEN N', aucune question à valider dans la phase.' ELSE N', aucune question à valider dans le cycle.' END;
END;

GO

