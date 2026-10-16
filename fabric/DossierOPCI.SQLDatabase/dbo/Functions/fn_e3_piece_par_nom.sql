
-- ------------------------------------------------------------------ n° 3 : le reimport du classeur des valeurs
-- @lignes : tableau JSON, une ligne par actif : ligne (numero du classeur), actif, valeur_expertise, rapport (nom du fichier
-- ou numero de la piece), valeur_retenue, source (libelle ou code), motif, piece (nom du fichier ou numero). Chaque ligne
-- passe sous les controles de la saisie ; une ligne refusee est citee et n'arrete pas les autres.
CREATE   FUNCTION dbo.fn_e3_piece_par_nom (@vehicule VARCHAR (20), @arrete VARCHAR (20), @nom NVARCHAR (400))
RETURNS INT
AS
BEGIN
    SET @nom = NULLIF(LTRIM(RTRIM(@nom)), N'');
    IF @nom IS NULL RETURN NULL;
    IF TRY_CAST(@nom AS INT) IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.piece WHERE id = TRY_CAST(@nom AS INT)) RETURN TRY_CAST(@nom AS INT);
    IF (SELECT COUNT(*) FROM dbo.piece pc JOIN dbo.v_perimetre_vehicule p ON p.entite = pc.entite AND p.vehicule = @vehicule AND p.arrete = @arrete
        WHERE pc.nom_fichier = @nom) = 1
        RETURN (SELECT pc.id FROM dbo.piece pc JOIN dbo.v_perimetre_vehicule p ON p.entite = pc.entite AND p.vehicule = @vehicule AND p.arrete = @arrete
                WHERE pc.nom_fichier = @nom);
    RETURN -1;   -- inconnue ou ambigue
END;

GO

