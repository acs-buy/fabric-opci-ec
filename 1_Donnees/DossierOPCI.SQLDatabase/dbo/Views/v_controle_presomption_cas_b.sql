
-- C72 : le cas b retenu sans que ses 2 conditions cumulatives soient
-- verifiees. La presomption exige plus de 40 % des droits de vote ET
-- qu'aucun autre associe n'en detienne davantage. ATTENDU zero.
CREATE   VIEW dbo.v_controle_presomption_cas_b AS
SELECT entite_mere, entite_fille, droits_de_vote, autre_associe_superieur,
       N'Le cas b présume la désignation lorsque l''organisme dispose de plus de 40 % des droits de vote ET qu''aucun autre associé n''en détient davantage. Les 2 conditions sont cumulatives.'
                                                AS lecture
FROM dbo.eligibilite_participation
WHERE cas_relation = 'b'
  AND (droits_de_vote IS NULL OR droits_de_vote <= 0.40
       OR autre_associe_superieur = 1);

GO

