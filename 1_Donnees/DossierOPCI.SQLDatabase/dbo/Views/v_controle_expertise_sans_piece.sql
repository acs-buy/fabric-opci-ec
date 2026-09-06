
-- --- 4 : le controle. ATTENDU : 30 pieces, 0 expertise sans piece,
--         94 actifs calculables ------------------------------------
CREATE   VIEW dbo.v_controle_expertise_sans_piece AS
SELECT e.id, e.code_actif, e.date_valeur, e.valeur_actuelle, e.expert
FROM dbo.expertise e WHERE e.piece_id IS NULL;

GO

