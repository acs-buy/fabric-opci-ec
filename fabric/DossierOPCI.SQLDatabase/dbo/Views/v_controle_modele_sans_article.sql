
-- C46 : un modele dont une ligne ne cite aucun article dans sa source.
-- Un modele sans fondement est une ecriture inventee. ATTENDU zero.
CREATE   VIEW dbo.v_controle_modele_sans_article AS
SELECT q.reference, m.ordre, m.compte_num, LEFT(m.source, 60) AS source
FROM dbo.modele_ecriture m
JOIN dbo.ref_question q ON q.id = m.question_id
WHERE m.source NOT LIKE N'%art. %';

GO

