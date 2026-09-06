-- C3 : un titre ou un compte courant sans entite liee, qui ne peut donc
-- pas se valoriser. ATTENDU zero hors le cas d'illustration IR4.
CREATE   VIEW dbo.v_controle_actif_sans_entite_liee AS
SELECT code, entite_detentrice, nature
FROM dbo.actif
WHERE nature IN ('TITRES_ENTITE_IMMOBILIERE', 'AVANCE_COMPTE_COURANT')
  AND entite_liee IS NULL AND code NOT LIKE 'IR4%';

GO

