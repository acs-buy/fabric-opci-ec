

-- v_controle_axe_manquant : anomalie si un compte porteur d'actif recoit une ecriture sans axe
CREATE   VIEW v_controle_axe_manquant AS
SELECT
    l.arrete,
    l.entite,
    l.id            AS lot,
    l.famille,
    e.id            AS ecriture,
    e.compte_num    AS compte,
    COALESCE(c.libelle_complet, c.libelle) AS libelle,
    e.debit,
    e.credit,
    e.ecriture_lib
FROM ecriture e
JOIN lot_ecritures l      ON l.id = e.lot_id
JOIN ref_compte    c      ON c.compte = e.compte_num
LEFT JOIN ecriture_axe ax ON ax.ecriture_id = e.id
WHERE c.porte_actif = 1
  AND (ax.ecriture_id IS NULL OR ax.code_actif IS NULL);

GO

