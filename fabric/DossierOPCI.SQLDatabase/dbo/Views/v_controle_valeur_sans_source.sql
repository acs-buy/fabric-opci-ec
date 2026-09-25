CREATE   VIEW dbo.v_controle_valeur_sans_source AS
SELECT entite, code_actif, arrete, valeur_actuelle
FROM dbo.v_patrimoine_valorise WHERE source IS NULL;

GO

