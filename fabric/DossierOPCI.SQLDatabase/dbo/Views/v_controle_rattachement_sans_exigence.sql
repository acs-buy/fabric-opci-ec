-- C33 : un rattachement qui ne dit pas quelle exigence il satisfait. Ce
-- n'est pas une anomalie pour une piece rattachee a un actif, dont
-- l'exigence se lit de la nature ; c'en est une pour une piece rattachee
-- a une question, dont le verrou de la conclusion doit compter la piece.
CREATE   VIEW dbo.v_controle_rattachement_sans_exigence AS
SELECT r.id, r.piece_id, r.question_id, r.entite_couverte, r.arrete_couvert,
       p.nom_fichier
FROM dbo.piece_rattachement r
JOIN dbo.piece p ON p.id = r.piece_id
WHERE r.piece_attendue_id IS NULL AND r.question_id IS NOT NULL;

GO

