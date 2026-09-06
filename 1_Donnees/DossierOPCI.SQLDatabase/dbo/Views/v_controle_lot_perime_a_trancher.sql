
-- --- 12 : les controles ---------------------------------------------
-- C17 : un lot perime encore propose. Ce n'est pas une anomalie mais une
-- file d'attente : la vue dit au chef de mission ce qu'il doit trancher.
CREATE   VIEW dbo.v_controle_lot_perime_a_trancher AS
SELECT lot_id, entite, arrete, famille, cree_le, perime_le, perime_motif
FROM dbo.v_lot_perime
WHERE statut = 'PROPOSE' AND perime_le IS NOT NULL;

GO

