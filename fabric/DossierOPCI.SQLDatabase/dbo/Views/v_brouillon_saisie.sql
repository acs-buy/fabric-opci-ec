
-- --- 5 : la vue du brouillon, aux 10 colonnes du format --------------
-- Le libelle du compte est repris du plan de comptes et non saisi : 2
-- libelles pour un meme compte se contredisent tot ou tard.
CREATE   VIEW dbo.v_brouillon_saisie AS
SELECT b.id, b.entite, b.arrete, b.feuille_cote, b.question_id,
       b.feuille_question_id,
       r.date_arrete                       AS date_ecriture,
       b.journal_code                      AS journal,
       b.compte_num                        AS compte,
       COALESCE(rce.libelle_entite, c.libelle_complet, c.libelle,
                        b.compte_num) AS libelle_compte,
       b.code_tiers,
       b.reference,
       b.libelle                           AS libelle_ecriture,
       b.debit, b.credit,
       b.code_actif                        AS axe_analytique,
       a.nature                            AS axe_nature,
       CAST(CASE WHEN b.debit = 0 AND b.credit = 0 THEN 1 ELSE 0 END AS BIT)
           AS ligne_a_completer,
       b.saisi_par, b.saisi_le
FROM dbo.ecriture_brouillon b
LEFT JOIN dbo.ref_compte c ON c.compte = b.compte_num
        -- LE LIBELLE VIENT DU PLAN DE L ENTITE QUAND ELLE EN A UN.
        -- Le compte insere reste celui du brouillon, saisi par le
        -- reviseur dans le plan de son entite : seul son libelle se
        -- cherchait a tort dans le plan du modele, qui ignore par
        -- exemple le 4551 d une filiale.
        LEFT JOIN dbo.ref_compte_entite rce ON rce.entite = b.entite
                                          AND rce.compte_entite = b.compte_num
LEFT JOIN dbo.actif a ON a.code = b.code_actif
LEFT JOIN dbo.ref_arrete r ON r.entite = b.entite AND r.arrete = b.arrete;

GO

