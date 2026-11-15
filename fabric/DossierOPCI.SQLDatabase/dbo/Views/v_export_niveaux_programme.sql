-- ===================================================================== 1. LE CLASSEUR DES NIVEAUX DE PROGRAMME
-- ecran 5, lot 5, script 335 (61_DEPLOIEMENT/generer_e5_335_export_niveaux_programme.py)
-- Decision D-v : une ligne par question de cycle (hors ECARTEE), les croix de son niveau en base quand il est pose,
-- sinon la proposition mecanique du 28/09/2026 (exporter_niveaux_a_cocher.py) ; le motif dit laquelle. Lue par la
-- fonction exporter_niveaux (n° 194), triee par ordre_cycle et ordre_question.
CREATE   VIEW dbo.v_export_niveaux_programme
AS
SELECT p.cycle, p.cycle_libelle, p.reference, p.enonce, p.applicabilite, p.type_reponse, p.feuille_type, p.racines_cycle,
       p.racines_directes,
       CAST(CASE WHEN p.niveau_programme IS NOT NULL THEN CASE WHEN p.niveau_programme = 1 THEN N'X' END
                 WHEN p.socle = 1 OR p.complement IS NOT NULL THEN N'X' END AS NVARCHAR (1)) AS allege,
       CAST(CASE WHEN p.niveau_programme IS NOT NULL THEN CASE WHEN p.niveau_programme <= 2 THEN N'X' END
                 ELSE N'X' END AS NVARCHAR (1)) AS classique,
       CAST(N'X' AS NVARCHAR (1)) AS etendu,
       CAST(CASE WHEN p.niveau_programme = 1 THEN N'niveau posé en base : allégé, classique et étendu'
                 WHEN p.niveau_programme = 2 THEN N'niveau posé en base : classique et étendu'
                 WHEN p.niveau_programme = 3 THEN N'niveau posé en base : étendu seul'
                 WHEN p.niveau_programme IS NOT NULL THEN N'niveau posé en base : ' + CAST(p.niveau_programme AS NVARCHAR (4))
                 WHEN p.complement IS NOT NULL THEN N'1re question du cycle, pour que le cycle reste couvert (' + p.complement + N')'
                 WHEN p.socle = 1 THEN CASE WHEN DATALENGTH(p.feuille_type) > 0 AND DATALENGTH(p.racines_directes) > 0 THEN N'feuille type et compte lié'
                                            WHEN DATALENGTH(p.feuille_type) > 0 THEN N'feuille type' ELSE N'compte lié' END
                 ELSE N'référentiel applicable' END AS NVARCHAR (200)) AS motif,
       p.niveau_programme, p.ordre_cycle, p.ordre_question
FROM (SELECT b.*,
             CASE WHEN b.socle = 1 THEN NULL
                  WHEN b.vl = 1 AND b.rang_vl = 1 AND MAX(CASE WHEN b.vl = 1 THEN b.socle END) OVER (PARTITION BY b.cycle) = 0 THEN N'arrêté de VL'
                  WHEN MAX(b.vl) OVER (PARTITION BY b.cycle) = 0 AND MAX(b.socle) OVER (PARTITION BY b.cycle) = 0 AND b.rang_cycle = 1 THEN N'clôture'
             END AS complement
      FROM (SELECT q.cycle, c.libelle AS cycle_libelle, q.reference, q.enonce, q.applicabilite, q.type_reponse, f.feuille_type,
                   rc.racines_cycle, rd.racines_directes, q.niveau_programme, c.ordre AS ordre_cycle, q.ordre AS ordre_question,
                   CASE WHEN DATALENGTH(f.feuille_type) > 0 OR DATALENGTH(rd.racines_directes) > 0 THEN 1 ELSE 0 END AS socle,
                   CASE WHEN q.applicabilite COLLATE Latin1_General_100_BIN2 = 'LES_DEUX' THEN 1 ELSE 0 END AS vl,
                   ROW_NUMBER() OVER (PARTITION BY q.cycle ORDER BY q.ordre, q.id) AS rang_cycle,
                   ROW_NUMBER() OVER (PARTITION BY q.cycle, CASE WHEN q.applicabilite COLLATE Latin1_General_100_BIN2 = 'LES_DEUX' THEN 1 ELSE 0 END
                                      ORDER BY q.ordre, q.id) AS rang_vl
            FROM dbo.ref_question q
            JOIN dbo.ref_cycle c ON c.code = q.cycle
            OUTER APPLY (SELECT STRING_AGG(m.modele_code, ', ') WITHIN GROUP (ORDER BY m.modele_code) AS feuille_type
                         FROM dbo.ref_question_modele m WHERE m.question_id = q.id) f
            OUTER APPLY (SELECT STRING_AGG(x.racine, ', ') WITHIN GROUP (ORDER BY x.racine) AS racines_cycle
                         FROM dbo.ref_cycle_compte x WHERE x.cycle = q.cycle) rc
            OUTER APPLY (SELECT STRING_AGG(x.racine, ', ') WITHIN GROUP (ORDER BY x.racine) AS racines_directes
                         FROM dbo.ref_question_compte x WHERE x.question_id = q.id) rd
            WHERE q.cycle IS NOT NULL AND q.statut <> 'ECARTEE') b) p;

GO

