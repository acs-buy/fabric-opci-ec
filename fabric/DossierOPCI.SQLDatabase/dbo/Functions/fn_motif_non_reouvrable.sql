-- 2.6 : la raison, sans prefixe, du 1er refus d'etat que la demande leverait (50983, puis 50984) ; NULL si l'arrete se
-- rouvre. C'est aussi la raison de 50991 a l'accord.
CREATE   FUNCTION dbo.fn_motif_non_reouvrable (@entite VARCHAR (20), @arrete VARCHAR (20))
RETURNS NVARCHAR (200)
AS
BEGIN
    IF dbo.fn_valide_pour_client(@entite, @arrete) = 0
        RETURN N'L''arrêté n''est pas validé pour le client ; il n''y a rien à rouvrir.';
    DECLARE @p VARCHAR (20) = dbo.fn_arrete_clos_posterieur(@entite, @arrete);
    IF @p IS NOT NULL
        RETURN N'L''arrêté postérieur du ' + dbo.fn_date_ecran(@p) + N' est clos ; la réouverture commence par le dernier arrêté clos.';
    RETURN NULL;
END;

GO

