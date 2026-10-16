
-- ------------------------------------------------------------------ n° 21 : les flux du groupe
-- v_controle_flux_vs_ecritures, le libelle de la nature (v_flux_intragroupe) et le vehicule du debiteur ou du crediteur.
CREATE   VIEW dbo.v_ecran_flux_groupe AS
SELECT pv.vehicule, c.arrete, c.nature, fl.nature_libelle, c.entite_debitrice, c.entite_creditrice, c.montant_declare,
       c.solde_chez_le_debiteur, c.solde_chez_le_crediteur, c.ecart_debiteur, c.lecture,
       pv.vehicule + '|' + c.arrete + '|' + c.nature + '|' + c.entite_debitrice + '|' + c.entite_creditrice AS cle_ecran
FROM dbo.v_controle_flux_vs_ecritures c
CROSS APPLY (SELECT DISTINCT p.vehicule FROM dbo.v_perimetre_vehicule p
             WHERE p.arrete = c.arrete AND p.entite IN (c.entite_debitrice, c.entite_creditrice)) pv
OUTER APPLY (SELECT TOP (1) x.nature_libelle FROM dbo.v_flux_intragroupe x WHERE x.nature = c.nature) fl;

GO

