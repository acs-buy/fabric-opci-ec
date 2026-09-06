
-- --- 6 : la lecture de la peremption --------------------------------
-- Elle compare la date de creation du lot a la derniere modification de
-- son perimetre, et rend le fait qui l'a perime.
CREATE   VIEW dbo.v_lot_perime AS
SELECT l.id AS lot_id, l.entite, l.arrete, l.famille, l.statut, l.cree_le,
       l.perime_le, l.perime_motif, l.perime_par,
       derniere.horodatage                            AS derniere_modification,
       derniere.fait,
       CAST(CASE WHEN derniere.horodatage > l.cree_le THEN 1 ELSE 0 END AS BIT)
           AS perimetre_modifie_apres,
       -- Le paragraphe de la NPMQ qui fonde la peremption, lu du
       -- referentiel et non recopie.
       (SELECT citation_courte FROM dbo.v_reference
        WHERE norme = 'NPMQ' AND reference = '28')     AS fondement_integrite,
       (SELECT citation_courte FROM dbo.v_reference
        WHERE norme = 'NPMQ' AND reference = '30')     AS fondement_supervision
FROM dbo.lot_ecritures l
OUTER APPLY (
    -- Le dernier fait susceptible d'avoir change le fondement du lot :
    -- une expertise enregistree, une valeur retenue posee ou visee, un
    -- cours saisi, une revision de compte courant.
    SELECT TOP (1) x.horodatage, x.fait FROM (
        SELECT e.enregistre_le AS horodatage,
               CAST(N'Expertise enregistree sur ' + e.code_actif
                    AS NVARCHAR (300)) AS fait
        FROM dbo.expertise e
        JOIN dbo.actif a ON a.code = e.code_actif
        WHERE a.entite_detentrice = l.entite
        UNION ALL
        SELECT COALESCE(ev.vise_le, ev.propose_le),
               CAST(N'Valeur retenue ' + ev.etat + N' sur ' + ev.code_actif
                    AS NVARCHAR (300))
        FROM dbo.evaluation_actif ev
        WHERE ev.entite = l.entite AND ev.arrete = l.arrete
        UNION ALL
        SELECT ct.saisi_le,
               CAST(N'Cours saisi sur ' + ct.code_actif AS NVARCHAR (300))
        FROM dbo.cours_titre ct
        WHERE ct.entite = l.entite AND ct.arrete = l.arrete
        UNION ALL
        SELECT rc.saisi_le,
               CAST(N'Compte courant revise sur ' + rc.entite_fille
                    AS NVARCHAR (300))
        FROM dbo.revision_compte_courant rc
        WHERE rc.entite = l.entite AND rc.arrete = l.arrete
    ) AS x
    WHERE x.horodatage IS NOT NULL
    ORDER BY x.horodatage DESC
) AS derniere;

GO

