

-- 3. LE PREMIER OBSTACLE AU VISE D'UN CYCLE, « numero|message », NULL sans obstacle. Ordre : l'etat,
-- le verrou, la revue visee, puis E1 de 1 a 4 sur le perimetre du vehicule (regle 0.7). Les conditions de
-- personne, auteur et role, n'y entrent pas.
CREATE   FUNCTION dbo.fn_obstacle_visa_cycle (@entite VARCHAR (20), @arrete VARCHAR (20), @cycle VARCHAR (10))
RETURNS NVARCHAR (2000)
AS
BEGIN
    DECLARE @etat VARCHAR (12) = dbo.fn_etat_cycle(@entite, @arrete, @cycle), @n INT, @l NVARCHAR (1600);
    IF @etat = 'A_CONCLURE' RETURN N'50331|Visa refusé : ce cycle ne porte pas de conclusion. Le conclure avant de le viser.';
    IF @etat = 'VISE' RETURN N'50505|Visa refusé : ce cycle est déjà visé.';
    IF @etat = 'RENVOYE' RETURN N'50506|Visa refusé : la conclusion de ce cycle a été renvoyée ; la reprendre avant de la viser.';
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1 RETURN N'50508|Décision refusée : le dossier de cet arrêté est visé et verrouillé.';
    IF dbo.fn_revue_visee(@entite, @arrete) = 1 RETURN N'50509|Refusé : la revue de cet arrêté est visée ; déverrouiller le dossier avant de rouvrir un cycle.';
    -- E1, 1 : les questions du cycle au programme
    SELECT @n = COUNT(*) FROM dbo.v_questions_programme WHERE entite = @entite AND arrete = @arrete AND cycle = @cycle AND etat_ligne <> 'REPONDUE';
    IF @n > 0
    BEGIN
        SELECT @l = STRING_AGG(CAST(reference AS NVARCHAR (MAX)), N', ') WITHIN GROUP (ORDER BY ordre, reference)
        FROM (SELECT TOP (5) reference, ordre FROM dbo.v_questions_programme WHERE entite = @entite AND arrete = @arrete AND cycle = @cycle
              AND etat_ligne <> 'REPONDUE' ORDER BY ordre, reference) x;
        RETURN N'50501|Visa refusé : ' + CAST(@n AS NVARCHAR (10)) + N' question(s) du cycle sont sans réponse, dont ' + @l + N'.';
    END;
    -- E1, 2 : les feuilles du cycle, filiales du perimetre comprises
    IF EXISTS (SELECT 1 FROM dbo.v_feuilles_du_cycle WHERE vehicule = @entite AND arrete = @arrete AND cycle = @cycle AND conclue_le IS NULL)
    BEGIN
        SELECT @l = STRING_AGG(CAST(cote + CASE WHEN entite <> vehicule THEN N' (' + entite + N')' ELSE N'' END AS NVARCHAR (MAX)), N', ')
                    WITHIN GROUP (ORDER BY CASE WHEN entite = vehicule THEN 0 ELSE 1 END, entite, cote)
        FROM (SELECT TOP (10) cote, entite, vehicule FROM dbo.v_feuilles_du_cycle
              WHERE vehicule = @entite AND arrete = @arrete AND cycle = @cycle AND conclue_le IS NULL
              ORDER BY CASE WHEN entite = vehicule THEN 0 ELSE 1 END, entite, cote) x;
        RETURN N'50502|Visa refusé : des feuilles du cycle ne sont pas conclues : ' + @l + N'.';
    END;
    -- E1, 3 : les lots du cycle qui attendent leur visa
    SELECT @n = COUNT(*) FROM dbo.v_lots_perimetre WHERE vehicule = @entite AND arrete = @arrete AND cycle = @cycle AND statut = 'PROPOSE';
    IF @n > 0
    BEGIN
        SELECT @l = STRING_AGG(CAST(CAST(lot_id AS NVARCHAR (12)) + CASE WHEN entite <> vehicule THEN N' (' + entite + N')' ELSE N'' END AS NVARCHAR (MAX)), N', ')
                    WITHIN GROUP (ORDER BY lot_id)
        FROM (SELECT TOP (10) lot_id, entite, vehicule FROM dbo.v_lots_perimetre
              WHERE vehicule = @entite AND arrete = @arrete AND cycle = @cycle AND statut = 'PROPOSE' ORDER BY lot_id) x;
        RETURN N'50503|Visa refusé : ' + CAST(@n AS NVARCHAR (10)) + N' lot(s) du cycle attendent leur visa : lots ' + @l + N'.';
    END;
    -- E1, 4 : une feuille conclue apres la conclusion du cycle
    IF EXISTS (SELECT 1 FROM dbo.v_feuilles_du_cycle WHERE vehicule = @entite AND arrete = @arrete AND cycle = @cycle AND conclue_apres_cycle = 1)
    BEGIN
        SELECT @l = STRING_AGG(CAST(cote + CASE WHEN entite <> vehicule THEN N' (' + entite + N')' ELSE N'' END AS NVARCHAR (MAX)), N', ')
                    WITHIN GROUP (ORDER BY cote)
        FROM (SELECT TOP (10) cote, entite, vehicule FROM dbo.v_feuilles_du_cycle
              WHERE vehicule = @entite AND arrete = @arrete AND cycle = @cycle AND conclue_apres_cycle = 1 ORDER BY cote) x;
        RETURN N'50504|Visa refusé : des feuilles ont été conclues après la conclusion du cycle : ' + @l + N'. Reconclure le cycle pour en reprendre la synthèse.';
    END;
    RETURN NULL;
END;

GO

