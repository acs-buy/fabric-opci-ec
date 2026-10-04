

-- 4. LE PREMIER OBSTACLE AU VISE DE LA REVUE. Ordre : l'etat, le verrou, les cycles, les lots du
-- perimetre. Les conditions de personne n'y entrent pas.
CREATE   FUNCTION dbo.fn_obstacle_visa_revue (@entite VARCHAR (20), @arrete VARCHAR (20))
RETURNS NVARCHAR (2000)
AS
BEGIN
    DECLARE @etat VARCHAR (12) = dbo.fn_etat_revue(@entite, @arrete), @n INT, @l NVARCHAR (1600);
    IF @etat = 'A_CONCLURE' RETURN N'50341|Visa refusé : la revue ne porte pas de conclusion générale. La conclure avant de la viser.';
    IF @etat = 'VISEE' RETURN N'50511|Visa refusé : la revue est déjà visée.';
    IF @etat = 'RENVOYEE' RETURN N'50512|Visa refusé : la conclusion générale a été renvoyée ; la reprendre avant de la viser.';
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1 RETURN N'50514|Décision refusée : le dossier de cet arrêté est visé et verrouillé ; le déverrouiller d''abord.';
    -- tous les cycles du programme, visés selon leur derniere decision
    SELECT @l = STRING_AGG(CAST(c.code AS NVARCHAR (MAX)), N', ') WITHIN GROUP (ORDER BY c.ordre)
    FROM dbo.ref_cycle c
    WHERE dbo.fn_cycle_au_programme(@entite, @arrete, c.code) = 1 AND dbo.fn_etat_cycle(@entite, @arrete, c.code) <> 'VISE';
    IF @l IS NOT NULL
        RETURN N'50344|Visa refusé : des cycles du programme ne sont pas visés : ' + @l + N'. La revue se vise après ses cycles.';
    -- aucun lot du perimetre n'attend son visa
    SELECT @n = COUNT(*), @l = STRING_AGG(CAST(entite AS NVARCHAR (MAX)), N', ') FROM
        (SELECT entite, COUNT(*) AS k FROM dbo.v_lots_perimetre WHERE vehicule = @entite AND arrete = @arrete AND statut = 'PROPOSE' GROUP BY entite) x;
    IF @n > 0
    BEGIN
        SET @n = (SELECT COUNT(*) FROM dbo.v_lots_perimetre WHERE vehicule = @entite AND arrete = @arrete AND statut = 'PROPOSE');
        RETURN N'50515|Visa refusé : ' + CAST(@n AS NVARCHAR (10)) + N' lot(s) du périmètre attendent leur visa (entités ' + @l + N'). La revue se vise après eux.';
    END;
    RETURN NULL;
END;

GO

