
CREATE   FUNCTION dbo.fn_ligne_etat_montant ()
RETURNS @r TABLE (entite VARCHAR (20) NOT NULL, arrete VARCHAR (20) NOT NULL, etat VARCHAR (14) NOT NULL, code VARCHAR (20) NOT NULL,
                  exercice_n DECIMAL (19, 2) NULL, exercice_n_1 DECIMAL (19, 2) NULL, PRIMARY KEY (entite, arrete, code))
AS BEGIN
    INSERT @r (entite, arrete, etat, code, exercice_n, exercice_n_1)
    SELECT entite, arrete, etat, code, exercice_n, exercice_n_1 FROM dbo.v_ligne_etat_montant;
    RETURN;
END;

GO

