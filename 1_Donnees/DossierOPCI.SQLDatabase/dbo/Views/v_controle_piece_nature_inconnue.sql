
-- --- 8 : les controles -------------------------------------------
-- C32 : une piece dont la nature n'est pas au referentiel. La cle la
-- refuse desormais ; la vue le mesure. ATTENDU zero.
CREATE   VIEW dbo.v_controle_piece_nature_inconnue AS
SELECT p.id, p.nom_fichier, p.nature
FROM dbo.piece p
WHERE NOT EXISTS (SELECT 1 FROM dbo.ref_nature_piece n WHERE n.code = p.nature);

GO

