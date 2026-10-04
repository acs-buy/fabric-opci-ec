
-- 2. LE CALCUL SE MATERIALISE, COUCHE PAR COUCHE. Chaque couche se calcule en 0,1 s environ, mais composees en vues
-- l'optimiseur recalcule le detail des etats a chaque jointure : 35 s pour les etats, et l'erreur 8623 (« the query
-- processor ran out of internal resources ») des que l'annexe les lisait, mesure du 03/10/2026. Une fonction table a
-- plusieurs instructions calcule sa couche une fois et rend une table : le calcul ne change pas, il cesse d'etre
-- recompose. Les vues restent l'interface lue par le modele, l'ecran et les controles.
CREATE   FUNCTION dbo.fn_ligne_etat_detail ()
RETURNS @r TABLE (etat VARCHAR (14) NOT NULL, code VARCHAR (20) NOT NULL, entite VARCHAR (20) NOT NULL, arrete VARCHAR (20) NOT NULL,
                  montant DECIMAL (19, 2) NULL, PRIMARY KEY (entite, arrete, etat, code))
AS BEGIN
    INSERT @r (etat, code, entite, arrete, montant) SELECT etat, code, entite, arrete, montant FROM dbo.v_ligne_etat_detail;
    RETURN;
END;

GO

