
-- ------------------------------------------------------------------------------------------------- 333-3
CREATE   FUNCTION dbo.fn_ann_signe_333_3 (@code VARCHAR (24))
RETURNS VARCHAR (4)
AS
BEGIN
    RETURN CASE @code WHEN 'AN_DEBUT' THEN '+' WHEN 'SOUSCRIPTIONS' THEN '+' WHEN 'FRAIS_ACQ' THEN '-' WHEN 'CHANGE' THEN '+ /-'
        WHEN 'VAR_DE_IMMO' THEN '+ /-' WHEN 'VAR_DE_FIN' THEN '+/-' WHEN 'DISTRIB_PREC' THEN '-' WHEN 'RESULTAT' THEN '+/-'
        WHEN 'AC_RES_NET' THEN '-' WHEN 'AC_CESSIONS' THEN '-' WHEN 'FUSION' THEN '+/-' WHEN 'AN_FIN' THEN '=' END;
END;

GO

