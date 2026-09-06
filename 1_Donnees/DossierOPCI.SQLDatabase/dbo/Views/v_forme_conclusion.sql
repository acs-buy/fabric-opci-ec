-- Les formes de conclusion et leur paragraphe.
CREATE   VIEW dbo.v_forme_conclusion AS
SELECT f.code, f.libelle, CAST(f.favorable AS BIT) AS favorable, f.ordre,
       r.citation_courte, r.intitule AS paragraphe_intitule, r.citation
FROM dbo.ref_forme_conclusion f
LEFT JOIN dbo.v_reference r ON r.id = f.reference_id;

GO

