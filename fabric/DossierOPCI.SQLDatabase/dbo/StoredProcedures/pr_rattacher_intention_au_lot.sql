
-- --- 4 : rattacher l'intention a son lot, apres validation -------------
CREATE   PROCEDURE dbo.pr_rattacher_intention_au_lot
    @intention_id INT,
    @lot_id       INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.intention_ecriture SET lot_id = @lot_id
    WHERE id = @intention_id AND lot_id IS NULL;
END;

GO

