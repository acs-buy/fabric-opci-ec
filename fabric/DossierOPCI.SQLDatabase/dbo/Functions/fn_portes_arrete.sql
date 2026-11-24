-- --- 1. les portes d'ouverture d'un arrete, jugees sans ecrire ---------------------------------------
-- Source unique du trigger tr_arrete_portes et du pre-controle de pr_ecran_ouvrir_arrete_corps.
-- Rend 'NNNNN|texte' pour la 1re porte fermee, NULL si toutes sont ouvertes. Juge l'arrete AVANT comme APRES son
-- INSERT dans arrete_mission : la porte 3 ne lit que les arretes annuels anterieurs (am.arrete < @arrete).
CREATE   FUNCTION dbo.fn_portes_arrete (@entite VARCHAR (20), @arrete VARCHAR (20))
RETURNS NVARCHAR (2000)
AS
BEGIN
    -- Porte 1 : un actif dont la nature exige une expertise, dans le perimetre de l'entite et de ses filiales a l'arrete
    -- (dbo.fn_filiales_a_l_arrete, B), sans expertise a la date de l'arrete, ouvre le refus.
    DECLARE @sans_expertise NVARCHAR (1200) =
        (SELECT STRING_AGG(CAST(x.code AS NVARCHAR (24)), N', ') WITHIN GROUP (ORDER BY x.code)
         FROM (SELECT DISTINCT TOP 20 a.code
               FROM dbo.actif a
               JOIN dbo.ref_nature_actif r
                 ON r.nature = a.nature
                AND r.expertise_requise = 1
               WHERE (a.entite_detentrice = @entite
                      OR a.entite_detentrice IN (SELECT f.entite_fille
                                                 FROM dbo.fn_filiales_a_l_arrete(@entite, @arrete) f))
                 AND NOT EXISTS (SELECT 1 FROM dbo.expertise e
                                 WHERE e.code_actif = a.code
                                   AND e.date_valeur = @arrete)
               ORDER BY a.code) AS x);
    IF @sans_expertise IS NOT NULL
        RETURN N'50025|' + N'Expertises à enregistrer à l''arrêté : ' + @sans_expertise + N'.';

    -- Porte 1 : une filiale a l'arrete (dbo.fn_filiales_a_l_arrete, B) sans balance validee (lot IMPORTEE) ouvre le refus.
    DECLARE @sans_balance NVARCHAR (1200) =
        (SELECT STRING_AGG(CAST(x.entite_fille AS NVARCHAR (24)), N', ') WITHIN GROUP (ORDER BY x.entite_fille)
         FROM (SELECT DISTINCT TOP 20 d.entite_fille
               FROM dbo.fn_filiales_a_l_arrete(@entite, @arrete) d
               WHERE NOT EXISTS (SELECT 1 FROM dbo.lot_ecritures l
                                 WHERE l.entite = d.entite_fille
                                   AND l.arrete = @arrete
                                   AND l.famille = 'IMPORTEE'
                                   AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE'))
               ORDER BY d.entite_fille) AS x);
    IF @sans_balance IS NOT NULL
        RETURN N'50026|' + N'Balances à valider : ' + @sans_balance + N'.';

    -- Porte 3 : le dernier arrete annuel anterieur de l'entite doit porter un maintien approuve. Sans arrete annuel
    -- anterieur, la porte ne s'applique pas, l'acceptation repondant de l'ouverture.
    DECLARE @dernier_annuel VARCHAR (20) =
        (SELECT MAX(am.arrete) FROM dbo.arrete_mission am
         WHERE am.entite = @entite AND am.type_arrete = 'ANNUEL' AND am.arrete < @arrete);
    IF @dernier_annuel IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM dbo.maintien_mission m
                       WHERE m.entite = @entite
                         AND m.arrete_conclu = @dernier_annuel
                         AND m.statut = 'APPROUVE')
        RETURN N'50027|' + N'Le dernier arrêté annuel (' + @dernier_annuel + N') de l''entité ' + @entite + N' n''a pas de maintien de mission approuvé. Le faire approuver par l''associé signataire, puis réessayer ; une dérogation ne lève pas ce blocage.';
    RETURN NULL;
END;

GO

