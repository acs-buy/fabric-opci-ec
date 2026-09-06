-- C19 : une expertise sans horodatage d'enregistrement. ATTENDU zero.
CREATE   VIEW dbo.v_controle_expertise_sans_horodatage AS
SELECT id, code_actif, date_valeur, enregistre_par, enregistre_le
FROM dbo.expertise WHERE enregistre_le IS NULL OR enregistre_par IS NULL;

GO

