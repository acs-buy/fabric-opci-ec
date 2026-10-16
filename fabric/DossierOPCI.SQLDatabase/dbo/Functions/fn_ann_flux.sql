-- Mouvements de l'exercice ]N-1 ; N] du registre dbo.mouvement_actif dont l'actif releve des comptes, ou de l'actif
-- @code seul (oracle, flux).
CREATE   FUNCTION dbo.fn_ann_flux (@c INT, @a VARCHAR (20), @comptes VARCHAR (400), @exclues VARCHAR (400), @code VARCHAR (40))
RETURNS @r TABLE (e DECIMAL (38, 12), sd DECIMAL (38, 12), n INT)
AS
BEGIN
    DECLARE @n1 VARCHAR (20) = (SELECT arrete_n_1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a);
    DECLARE @bas DATE = dbo.fn_ann_date(@c, @n1), @haut DATE = dbo.fn_ann_date(@c, @a);
    INSERT INTO @r
    SELECT ISNULL(SUM(CASE WHEN m.nature IN ('ACQUISITION', 'TRAVAUX') THEN ISNULL(m.montant, 0) END), 0),
           ISNULL(SUM(CASE WHEN m.nature IN ('CESSION', 'SORTIE') THEN ISNULL(m.valeur_nette_sortie, 0) END), 0),
           COUNT(*)
    FROM dbo.mouvement_actif m JOIN dbo.calcul_annexe ca ON ca.entite = m.entite
    WHERE ca.calcul_id = @c AND @bas IS NOT NULL AND CAST(m.date_mouvement AS DATE) > @bas AND CAST(m.date_mouvement AS DATE) <= @haut
      AND ((@code IS NOT NULL AND m.code_actif = @code) OR (@code IS NULL AND dbo.fn_ann_poste_ok(@c, m.code_actif, @comptes, @exclues) = 1));
    RETURN;
END;

GO

