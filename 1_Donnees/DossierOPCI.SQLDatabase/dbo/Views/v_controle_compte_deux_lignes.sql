
-- C59 : un compte rattache a PLUS D'UNE ligne du meme etat. Il serait
-- alors compte 2 fois dans le total. ATTENDU zero.
CREATE   VIEW dbo.v_controle_compte_deux_lignes AS
SELECT c.compte, l.etat, COUNT(*) AS lignes,
       STRING_AGG(CAST(l.code AS NVARCHAR (MAX)), N', ') AS codes
FROM dbo.ref_compte c
JOIN dbo.ref_ligne_etat l ON l.racines IS NOT NULL
                         AND EXISTS (SELECT 1
                                     FROM STRING_SPLIT(l.racines, ',') s
                                     WHERE c.compte LIKE s.value + '%')
GROUP BY c.compte, l.etat
HAVING COUNT(*) > 1;

GO

