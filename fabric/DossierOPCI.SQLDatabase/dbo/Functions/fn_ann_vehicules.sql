
-- Les vehicules a marquer pour une ecriture sur l'entite @x (contrat, 3.2, « Detenteurs et lecteurs d'une entite ») :
-- @x s'il est un vehicule (@vehicule, quand la ligne le dit, sinon ref_entite), puis ses detenteurs de proche en proche
-- (detention, et actif au poste 25 par entite_liee), chacun visite une fois ; pour une ligne de ref_entite (@lecteurs),
-- les lecteurs de sa denomination (preteurs de emprunt_intragroupe, entites des lots qui la portent en compte
-- auxiliaire). Seuls les vehicules sont rendus.
CREATE   FUNCTION dbo.fn_ann_vehicules (@x VARCHAR (20), @lecteurs BIT, @vehicule BIT)
RETURNS @v TABLE (entite VARCHAR (20) PRIMARY KEY)
AS
BEGIN
    IF @x IS NULL RETURN;
    DECLARE @vus TABLE (entite VARCHAR (20) PRIMARY KEY, tour INT);
    DECLARE @tour INT = 0, @n INT = 1;
    INSERT INTO @vus VALUES (@x, 0);
    WHILE @n > 0
    BEGIN
        INSERT INTO @vus (entite, tour)
        SELECT DISTINCT h.entite, @tour + 1
        FROM @vus s
        CROSS APPLY (SELECT d.entite_mere AS entite FROM dbo.detention d WHERE d.entite_fille = s.entite
                     UNION
                     SELECT a.entite_detentrice FROM dbo.actif a WHERE a.entite_liee = s.entite AND a.poste_bilan LIKE '25%') h
        WHERE s.tour = @tour AND h.entite IS NOT NULL AND NOT EXISTS (SELECT 1 FROM @vus u WHERE u.entite = h.entite);
        SET @n = @@ROWCOUNT;
        SET @tour += 1;
    END;
    INSERT INTO @v
    SELECT u.entite FROM @vus u
    WHERE (u.entite = @x AND @vehicule = 1)
       OR ((u.entite <> @x OR @vehicule IS NULL) AND EXISTS (SELECT 1 FROM dbo.ref_entite e WHERE e.code = u.entite AND e.forme_vehicule IS NOT NULL));
    IF @lecteurs = 1
        INSERT INTO @v
        SELECT DISTINCT r.entite FROM (
            SELECT g.entite_preteuse AS entite FROM dbo.emprunt_intragroupe g WHERE g.entite_emprunt = @x
            UNION
            SELECT l.entite FROM dbo.ecriture e JOIN dbo.lot_ecritures l ON l.id = e.lot_id WHERE e.comp_aux_num = @x) r
        WHERE r.entite IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.ref_entite e WHERE e.code = r.entite AND e.forme_vehicule IS NOT NULL)
          AND NOT EXISTS (SELECT 1 FROM @v w WHERE w.entite = r.entite);
    RETURN;
END;

GO

