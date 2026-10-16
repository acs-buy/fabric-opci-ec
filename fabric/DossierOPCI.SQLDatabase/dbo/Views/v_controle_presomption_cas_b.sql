
-- Signal du cas b : la presomption de designation n'est pas acquise. Le cas b tient a la designation par l'OPCI ou
-- sa societe de gestion, pendant 2 exercices successifs, de la majorite des membres des organes ; plus de 40 % des
-- droits de vote sans associe au-dessus la font seulement presumer. Une ligne n'est pas une anomalie : la
-- designation se justifie alors sur pieces.
CREATE   VIEW dbo.v_controle_presomption_cas_b AS
SELECT entite_mere, entite_fille, droits_de_vote, autre_associe_superieur,
       N'Présomption non acquise : la désignation de la majorité des membres des organes pendant 2 exercices successifs se justifie sur pièces. Le cas b la présume lorsque l''organisme dispose de plus de 40 % des droits de vote et qu''aucun autre associé n''en détient davantage.'
                                                AS lecture
FROM dbo.eligibilite_participation
WHERE cas_relation = 'b'
  AND (droits_de_vote IS NULL OR droits_de_vote <= 0.40
       OR autre_associe_superieur = 1);

GO

