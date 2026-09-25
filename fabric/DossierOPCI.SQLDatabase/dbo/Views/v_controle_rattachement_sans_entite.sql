-- C34 : un rattachement sans entite couverte. La vue des documents
-- attendus ne peut alors pas le compter. ATTENDU zero.
CREATE   VIEW dbo.v_controle_rattachement_sans_entite AS
SELECT r.id, r.piece_id, r.entite, r.code_actif, r.question_id
FROM dbo.piece_rattachement r WHERE r.entite_couverte IS NULL;

GO

