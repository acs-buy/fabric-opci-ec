
-- ------------------------------------------------------------------------------------------------- lectures
-- Debit moins credit des comptes de la racine (oracle, Dossier.S) ; NULL sans balance a l'arrete. Les lots
-- d'affectation sont ecartes pour les classes 6 et 7, et pour toute racine quand @hors_aff vaut 1 (regle K1).
-- @exclues : racines exclues separees par des virgules. @aux : '*' pour tout auxiliaire, sinon l'auxiliaire exact.
CREATE   FUNCTION dbo.fn_ann_S (@calcul_id INT, @arrete VARCHAR (20), @racine VARCHAR (40), @exclues VARCHAR (400) = '',
                                     @aux NVARCHAR (40) = N'*', @hors_aff BIT = 0)
RETURNS DECIMAL (38, 12)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.annexe_w_arr WHERE calcul_id = @calcul_id AND arrete = @arrete AND porte_balance = 1)
        RETURN NULL;
    RETURN ISNULL((
        SELECT SUM(s.solde) FROM dbo.annexe_w_sol s
        WHERE s.calcul_id = @calcul_id AND s.arrete = @arrete AND s.compte_num LIKE @racine + '%'
          AND NOT EXISTS (SELECT 1 FROM STRING_SPLIT(@exclues, ',') x WHERE LTRIM(RTRIM(x.value)) <> '' AND s.compte_num LIKE LTRIM(RTRIM(x.value)) + '%')
          AND NOT (s.aff = 1 AND (@hors_aff = 1 OR LEFT(s.compte_num, 1) IN ('6', '7')))
          AND (@aux = N'*' OR s.comp_aux_num = @aux)), 0);
END;

GO

