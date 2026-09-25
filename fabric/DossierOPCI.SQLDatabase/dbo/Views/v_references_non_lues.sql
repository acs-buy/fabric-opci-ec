-- C12 : les references non lues sur piece. Ce n'est pas une anomalie,
-- c'est l'etat de la verification : la vue dit ce qui reste a lire.
CREATE   VIEW dbo.v_references_non_lues AS
SELECT norme, norme_libelle, reference, genre, intitule
FROM dbo.v_reference WHERE lu_sur_piece = 0;

GO

