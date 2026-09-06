
CREATE   VIEW dbo.v_controle_sens_contredit AS
SELECT entite, arrete, compte_num, solde, sens_constate, sens_attendu,
       N'le sens du solde contredit la classe du compte, jugée au plan que l''entité applique'
                                                           AS lecture
FROM dbo.v_controle_sens_du_solde
WHERE anomalie = 1;

GO

