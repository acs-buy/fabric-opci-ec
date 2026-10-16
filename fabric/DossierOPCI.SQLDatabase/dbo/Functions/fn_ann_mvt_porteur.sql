-- Les mouvements du registre des porteurs d'une nature, dates de ]@bas, @haut] (oracle, mvt_porteur).
CREATE   FUNCTION dbo.fn_ann_mvt_porteur (@c INT, @nature VARCHAR (20), @bas DATE, @haut DATE)
RETURNS TABLE
AS
RETURN
    SELECT m.date_valeur, m.nature, m.nombre_parts, m.montant
    FROM dbo.mouvement_porteur m JOIN dbo.porteur p ON p.id = m.porteur_id JOIN dbo.calcul_annexe ca ON ca.entite = p.entite
    WHERE ca.calcul_id = @c AND m.nature = @nature AND CAST(m.date_valeur AS DATE) > @bas AND CAST(m.date_valeur AS DATE) <= @haut;

GO

