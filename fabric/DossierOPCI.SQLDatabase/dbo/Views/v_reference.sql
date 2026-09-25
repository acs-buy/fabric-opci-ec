
-- --- 6 : la vue de lecture, une reference et sa norme ----------------
-- C'est elle que les autres vues liront : changer un intitule dans
-- dbo.ref_norme change ce que tous les ecrans affichent.
CREATE   VIEW dbo.v_reference AS
SELECT r.id, r.norme, r.reference, r.genre, r.intitule, r.citation,
       CAST(r.lu_sur_piece AS BIT) AS lu_sur_piece, r.page_piece, r.lu_le,
       n.libelle_court                                   AS norme_libelle,
       n.libelle_complet                                 AS norme_libelle_complet,
       n.autorite, n.acte_agrement, n.date_application, n.edition,
       n.piece_au_dossier,
       CAST(n.en_vigueur AS BIT)                         AS norme_en_vigueur,
       CAST(n.applicable_presentation AS BIT)            AS applicable_presentation,
       n.abroge_par,
       -- La citation complete, telle qu'un rapport doit l'ecrire.
       CAST(CASE WHEN r.genre = 'PARAGRAPHE'
                 THEN n.libelle_court + N', paragraphe ' + r.reference
                 ELSE n.libelle_court + N', article ' + r.reference END
            AS NVARCHAR (200))                           AS citation_courte
FROM dbo.ref_reference r
JOIN dbo.ref_norme n ON n.code = r.norme;

GO

