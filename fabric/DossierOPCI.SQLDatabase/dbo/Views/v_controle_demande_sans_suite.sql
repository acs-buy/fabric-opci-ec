
-- --- 5 : les controles ------------------------------------------------
-- C88 : une demande restee a l'etat DEMANDEE sans document produit. La
-- fonction Python ne l'a pas honoree, ou elle a echoue sans le dire.
CREATE   VIEW dbo.v_controle_demande_sans_suite AS
SELECT d.id, d.entite, d.arrete, d.livrable, d.version, d.demande_par,
       d.demande_le,
       DATEDIFF(MINUTE, d.demande_le, SYSUTCDATETIME()) AS minutes,
       N'cette demande est enregistrée depuis plus d''une heure et aucun document n''a été écrit : la fonction de production n''a pas abouti'
                                                        AS lecture
FROM dbo.demande_document d
WHERE d.etat = 'DEMANDEE'
  AND DATEDIFF(MINUTE, d.demande_le, SYSUTCDATETIME()) > 60;

GO

