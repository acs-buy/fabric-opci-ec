
-- La table source d'une marque de retard, en clair, precedee de sa preposition (refus 50649, ecran) : jamais le nom de
-- la table.
CREATE   FUNCTION dbo.fn_ann_origine_fr (@origine NVARCHAR (128))
RETURNS NVARCHAR (200)
AS
BEGIN
    RETURN CASE @origine
        WHEN N'actif' THEN N'd’un actif'
        WHEN N'cours_titre' THEN N'd’un cours de titre'
        WHEN N'decision_distribution' THEN N'd’une décision de distribution'
        WHEN N'detention' THEN N'd’une détention de titres'
        WHEN N'ecriture' THEN N'd’une écriture comptable'
        WHEN N'ecriture_axe' THEN N'de la ventilation analytique d’une écriture'
        WHEN N'emprunt_intragroupe' THEN N'd’un contrat d’avance en compte courant'
        WHEN N'evaluation_actif' THEN N'd’une évaluation d’actif'
        WHEN N'expertise' THEN N'd’une expertise'
        WHEN N'lot_ecritures' THEN N'd’un lot d’écritures'
        WHEN N'mouvement_actif' THEN N'du registre des mouvements d’actifs'
        WHEN N'mouvement_porteur' THEN N'du registre des porteurs'
        WHEN N'parts_en_circulation' THEN N'des parts en circulation'
        WHEN N'porteur' THEN N'd’un porteur de parts'
        WHEN N'ref_arrete' THEN N'du calendrier des arrêtés'
        WHEN N'ref_compte' THEN N'du plan de comptes'
        WHEN N'ref_compte_entite' THEN N'du plan de comptes de l’entité'
        WHEN N'ref_entite' THEN N'de la fiche d’une entité'
        WHEN N'ref_ligne_annexe' THEN N'du référentiel des lignes de l’annexe'
        WHEN N'ref_ligne_etat' THEN N'du référentiel des lignes des états'
        WHEN N'ref_nature_actif' THEN N'du référentiel des natures d’actifs'
        WHEN N'ref_norme' THEN N'du référentiel des normes'
        WHEN N'ref_reference' THEN N'du référentiel des références'
        WHEN N'ref_tableau_annexe' THEN N'du référentiel des tableaux de l’annexe'
        WHEN N'saisie_annexe' THEN N'd’une saisie de l’annexe'
        WHEN N'valeur_instrument' THEN N'd’une valeur d’instrument financier'
        WHEN N'eligibilite_participation' THEN N'du classement d’une filiale'
        ELSE N'd’une source de l’annexe' END;
END;

GO

