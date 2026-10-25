CREATE   VIEW dbo.v_ecran_referentiel_lignes AS
SELECT CAST(t.referentiel AS VARCHAR (120)) AS referentiel, t.cle, CAST(t.ligne AS NVARCHAR (MAX)) AS ligne,
       CAST(DATETRUNC(second, t.modifie_le) AS DATETIME2 (0)) AS modifie_le, CAST(t.modifie_par AS NVARCHAR (400)) AS modifie_par,
       CAST(t.emploi AS INT) AS emploi, CAST(t.employee_par AS NVARCHAR (MAX)) AS employee_par,
       CAST(t.lecture_seule AS INT) AS lecture_seule, CAST(t.ecartee_le AS DATE) AS ecartee_le
FROM (
    -- ref_compte
    SELECT 'ref_compte' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) + ISNULL(e2.n, 0) + ISNULL(e3.n, 0) + ISNULL(e4.n, 0) + ISNULL(e5.n, 0) + ISNULL(e6.n, 0) + ISNULL(e7.n, 0) + ISNULL(e8.n, 0) + ISNULL(e9.n, 0) + ISNULL(e10.n, 0) AS emploi,
           CONCAT_WS(N' · ', CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'cours de titre' ELSE N'cours de titre' END) END, CASE WHEN e2.n > 0 THEN CONCAT(e2.n, N' ', CASE WHEN e2.n < 2 THEN N'intention d’écriture' ELSE N'intentions d’écriture' END) END, CASE WHEN e3.n > 0 THEN CONCAT(e3.n, N' ', CASE WHEN e3.n < 2 THEN N'modèle d’écriture' ELSE N'modèles d’écriture' END) END, CASE WHEN e4.n > 0 THEN CONCAT(e4.n, N' ', CASE WHEN e4.n < 2 THEN N'sous-compte' ELSE N'sous-comptes' END) END, CASE WHEN e5.n > 0 THEN CONCAT(e5.n, N' ', CASE WHEN e5.n < 2 THEN N'compte d’entité' ELSE N'comptes d’entité' END) END, CASE WHEN e6.n > 0 THEN CONCAT(e6.n, N' ', CASE WHEN e6.n < 2 THEN N'contrepartie d’estimation' ELSE N'contreparties d’estimation' END) END, CASE WHEN e7.n > 0 THEN CONCAT(e7.n, N' ', CASE WHEN e7.n < 2 THEN N'correspondance de plan' ELSE N'correspondances de plan' END) END, CASE WHEN e8.n > 0 THEN CONCAT(e8.n, N' ', CASE WHEN e8.n < 2 THEN N'référence croisée' ELSE N'références croisées' END) END, CASE WHEN e9.n > 0 THEN CONCAT(e9.n, N' ', CASE WHEN e9.n < 2 THEN N'compte courant révisé' ELSE N'comptes courants révisés' END) END, CASE WHEN e10.n > 0 THEN CONCAT(e10.n, N' ', CASE WHEN e10.n < 2 THEN N'valeur d’instrument' ELSE N'valeurs d’instrument' END) END) AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.ref_compte x
    LEFT JOIN (SELECT d.compte AS k, COUNT(*) AS n FROM dbo.cours_titre d WHERE d.compte IS NOT NULL GROUP BY d.compte) e1 ON e1.k = x.compte
    LEFT JOIN (SELECT z.k, COUNT(*) AS n FROM dbo.intention_ecriture d CROSS APPLY (SELECT d.compte_num UNION SELECT d.compte_contrepartie) z (k) WHERE z.k IS NOT NULL GROUP BY z.k) e2 ON e2.k = x.compte
    LEFT JOIN (SELECT d.compte_num AS k, COUNT(*) AS n FROM dbo.modele_ecriture d WHERE d.compte_num IS NOT NULL GROUP BY d.compte_num) e3 ON e3.k = x.compte
    LEFT JOIN (SELECT d.compte_parent AS k, COUNT(*) AS n FROM dbo.ref_compte d WHERE d.compte_parent IS NOT NULL GROUP BY d.compte_parent) e4 ON e4.k = x.compte
    LEFT JOIN (SELECT d.compte_modele AS k, COUNT(*) AS n FROM dbo.ref_compte_entite d WHERE d.compte_modele IS NOT NULL GROUP BY d.compte_modele) e5 ON e5.k = x.compte
    LEFT JOIN (SELECT z.k, COUNT(*) AS n FROM dbo.ref_contrepartie_estimation d CROSS APPLY (SELECT d.compte_estimation UNION SELECT d.compte_contrepartie) z (k) WHERE z.k IS NOT NULL GROUP BY z.k) e6 ON e6.k = x.compte
    LEFT JOIN (SELECT d.compte_modele AS k, COUNT(*) AS n FROM dbo.ref_correspondance_plan d WHERE d.compte_modele IS NOT NULL GROUP BY d.compte_modele) e7 ON e7.k = x.compte
    LEFT JOIN (SELECT d.compte_num AS k, COUNT(*) AS n FROM dbo.ref_croisee d WHERE d.compte_num IS NOT NULL GROUP BY d.compte_num) e8 ON e8.k = x.compte
    LEFT JOIN (SELECT d.compte AS k, COUNT(*) AS n FROM dbo.revision_compte_courant d WHERE d.compte IS NOT NULL GROUP BY d.compte) e9 ON e9.k = x.compte
    LEFT JOIN (SELECT d.compte AS k, COUNT(*) AS n FROM dbo.valeur_instrument d WHERE d.compte IS NOT NULL GROUP BY d.compte) e10 ON e10.k = x.compte
    CROSS APPLY (SELECT CAST(CAST(x.compte AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_cycle
    SELECT 'ref_cycle' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) + ISNULL(e2.n, 0) + ISNULL(e3.n, 0) + ISNULL(e4.n, 0) + ISNULL(e5.n, 0) AS emploi,
           CONCAT_WS(N' · ', CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'conclusion' ELSE N'conclusions' END) END, CASE WHEN e2.n > 0 THEN CONCAT(e2.n, N' ', CASE WHEN e2.n < 2 THEN N'feuille' ELSE N'feuilles' END) END, CASE WHEN e3.n > 0 THEN CONCAT(e3.n, N' ', CASE WHEN e3.n < 2 THEN N'racine de comptes' ELSE N'racines de comptes' END) END, CASE WHEN e4.n > 0 THEN CONCAT(e4.n, N' ', CASE WHEN e4.n < 2 THEN N'pièce attendue' ELSE N'pièces attendues' END) END, CASE WHEN e5.n > 0 THEN CONCAT(e5.n, N' ', CASE WHEN e5.n < 2 THEN N'question' ELSE N'questions' END) END) AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.ref_cycle x
    LEFT JOIN (SELECT d.cycle AS k, COUNT(*) AS n FROM dbo.conclusion_cycle d WHERE d.cycle IS NOT NULL GROUP BY d.cycle) e1 ON e1.k = x.code
    LEFT JOIN (SELECT d.cycle AS k, COUNT(*) AS n FROM dbo.feuille_travail d WHERE d.cycle IS NOT NULL GROUP BY d.cycle) e2 ON e2.k = x.code
    LEFT JOIN (SELECT d.cycle AS k, COUNT(*) AS n FROM dbo.ref_cycle_compte d WHERE d.cycle IS NOT NULL GROUP BY d.cycle) e3 ON e3.k = x.code
    LEFT JOIN (SELECT d.cycle AS k, COUNT(*) AS n FROM dbo.ref_piece_attendue d WHERE d.cycle IS NOT NULL GROUP BY d.cycle) e4 ON e4.k = x.code
    LEFT JOIN (SELECT d.cycle AS k, COUNT(*) AS n FROM dbo.ref_question d WHERE d.cycle IS NOT NULL GROUP BY d.cycle) e5 ON e5.k = x.code
    CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_phase
    SELECT 'ref_phase' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) + ISNULL(e2.n, 0) + ISNULL(e3.n, 0) AS emploi,
           CONCAT_WS(N' · ', CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'feuille' ELSE N'feuilles' END) END, CASE WHEN e2.n > 0 THEN CONCAT(e2.n, N' ', CASE WHEN e2.n < 2 THEN N'pièce attendue' ELSE N'pièces attendues' END) END, CASE WHEN e3.n > 0 THEN CONCAT(e3.n, N' ', CASE WHEN e3.n < 2 THEN N'question' ELSE N'questions' END) END) AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.ref_phase x
    LEFT JOIN (SELECT d.phase AS k, COUNT(*) AS n FROM dbo.feuille_travail d WHERE d.phase IS NOT NULL GROUP BY d.phase) e1 ON e1.k = x.code
    LEFT JOIN (SELECT d.phase AS k, COUNT(*) AS n FROM dbo.ref_piece_attendue d WHERE d.phase IS NOT NULL GROUP BY d.phase) e2 ON e2.k = x.code
    LEFT JOIN (SELECT d.phase AS k, COUNT(*) AS n FROM dbo.ref_question d WHERE d.phase IS NOT NULL GROUP BY d.phase) e3 ON e3.k = x.code
    CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_question
    SELECT 'ref_question' AS referentiel, k.cle, COALESCE(NULLIF(x.reference, N''), k.cle) AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) + ISNULL(e2.n, 0) + ISNULL(e3.n, 0) + ISNULL(e4.n, 0) + ISNULL(e5.n, 0) + ISNULL(e6.n, 0) + ISNULL(e7.n, 0) + ISNULL(e8.n, 0) + ISNULL(e9.n, 0) + ISNULL(e10.n, 0) + ISNULL(e11.n, 0) AS emploi,
           CONCAT_WS(N' · ', CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'écriture en brouillon' ELSE N'écritures en brouillon' END) END, CASE WHEN e2.n > 0 THEN CONCAT(e2.n, N' ', CASE WHEN e2.n < 2 THEN N'ligne de feuille' ELSE N'lignes de feuille' END) END, CASE WHEN e3.n > 0 THEN CONCAT(e3.n, N' ', CASE WHEN e3.n < 2 THEN N'feuille' ELSE N'feuilles' END) END, CASE WHEN e4.n > 0 THEN CONCAT(e4.n, N' ', CASE WHEN e4.n < 2 THEN N'lot d’écritures' ELSE N'lots d’écritures' END) END, CASE WHEN e5.n > 0 THEN CONCAT(e5.n, N' ', CASE WHEN e5.n < 2 THEN N'modèle d’écriture' ELSE N'modèles d’écriture' END) END, CASE WHEN e6.n > 0 THEN CONCAT(e6.n, N' ', CASE WHEN e6.n < 2 THEN N'pièce rattachée' ELSE N'pièces rattachées' END) END, CASE WHEN e7.n > 0 THEN CONCAT(e7.n, N' ', CASE WHEN e7.n < 2 THEN N'programme' ELSE N'programmes' END) END, CASE WHEN e8.n > 0 THEN CONCAT(e8.n, N' ', CASE WHEN e8.n < 2 THEN N'article' ELSE N'articles' END) END, CASE WHEN e9.n > 0 THEN CONCAT(e9.n, N' ', CASE WHEN e9.n < 2 THEN N'racine de comptes' ELSE N'racines de comptes' END) END, CASE WHEN e10.n > 0 THEN CONCAT(e10.n, N' ', CASE WHEN e10.n < 2 THEN N'modèle de feuille' ELSE N'modèles de feuille' END) END, CASE WHEN e11.n > 0 THEN CONCAT(e11.n, N' ', CASE WHEN e11.n < 2 THEN N'référence' ELSE N'références' END) END) AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_question x
    LEFT JOIN (SELECT d.question_id AS k, COUNT(*) AS n FROM dbo.ecriture_brouillon d WHERE d.question_id IS NOT NULL GROUP BY d.question_id) e1 ON e1.k = x.id
    LEFT JOIN (SELECT d.question_id AS k, COUNT(*) AS n FROM dbo.feuille_question d WHERE d.question_id IS NOT NULL GROUP BY d.question_id) e2 ON e2.k = x.id
    LEFT JOIN (SELECT d.question_id AS k, COUNT(*) AS n FROM dbo.feuille_travail d WHERE d.question_id IS NOT NULL GROUP BY d.question_id) e3 ON e3.k = x.id
    LEFT JOIN (SELECT d.question_id AS k, COUNT(*) AS n FROM dbo.lot_ecritures d WHERE d.question_id IS NOT NULL GROUP BY d.question_id) e4 ON e4.k = x.id
    LEFT JOIN (SELECT d.question_id AS k, COUNT(*) AS n FROM dbo.modele_ecriture d WHERE d.question_id IS NOT NULL GROUP BY d.question_id) e5 ON e5.k = x.id
    LEFT JOIN (SELECT d.question_id AS k, COUNT(*) AS n FROM dbo.piece_rattachement d WHERE d.question_id IS NOT NULL GROUP BY d.question_id) e6 ON e6.k = x.id
    LEFT JOIN (SELECT d.question_id AS k, COUNT(*) AS n FROM dbo.programme_question d WHERE d.question_id IS NOT NULL GROUP BY d.question_id) e7 ON e7.k = x.id
    LEFT JOIN (SELECT d.question_id AS k, COUNT(*) AS n FROM dbo.ref_question_article d WHERE d.question_id IS NOT NULL GROUP BY d.question_id) e8 ON e8.k = x.id
    LEFT JOIN (SELECT d.question_id AS k, COUNT(*) AS n FROM dbo.ref_question_compte d WHERE d.question_id IS NOT NULL GROUP BY d.question_id) e9 ON e9.k = x.id
    LEFT JOIN (SELECT d.question_id AS k, COUNT(*) AS n FROM dbo.ref_question_modele d WHERE d.question_id IS NOT NULL GROUP BY d.question_id) e10 ON e10.k = x.id
    LEFT JOIN (SELECT d.question_reference AS k, COUNT(*) AS n FROM dbo.ref_question_reference d WHERE d.question_reference IS NOT NULL GROUP BY d.question_reference) e11 ON e11.k = x.reference
    CROSS APPLY (SELECT CAST(CAST(x.id AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_question_article
    SELECT 'ref_question_article' AS referentiel, k.cle, CONCAT(ISNULL(q.reference, CAST(x.question_id AS NVARCHAR (20))), N' · ', CAST(x.article AS NVARCHAR (200))) AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           0 AS emploi,
           N'' AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.ref_question_article x
    LEFT JOIN dbo.ref_question q ON q.id = x.question_id
    CROSS APPLY (SELECT CAST(CONCAT(CAST(x.question_id AS NVARCHAR (200)), N' · ', CAST(x.article AS NVARCHAR (200))) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_article
    SELECT 'ref_article' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) + ISNULL(e2.n, 0) + ISNULL(e3.n, 0) + ISNULL(e4.n, 0) + ISNULL(e5.n, 0) + ISNULL(e6.n, 0) AS emploi,
           CONCAT_WS(N' · ', CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'obligation de distribution' ELSE N'obligations de distribution' END) END, CASE WHEN e2.n > 0 THEN CONCAT(e2.n, N' ', CASE WHEN e2.n < 2 THEN N'question' ELSE N'questions' END) END, CASE WHEN e3.n > 0 THEN CONCAT(e3.n, N' ', CASE WHEN e3.n < 2 THEN N'ratio' ELSE N'ratios' END) END, CASE WHEN e4.n > 0 THEN CONCAT(e4.n, N' ', CASE WHEN e4.n < 2 THEN N'limite' ELSE N'limites' END) END, CASE WHEN e5.n > 0 THEN CONCAT(e5.n, N' ', CASE WHEN e5.n < 2 THEN N'mention dans une limite' ELSE N'mentions dans les limites' END) END, CASE WHEN e6.n > 0 THEN CONCAT(e6.n, N' ', CASE WHEN e6.n < 2 THEN N'saisie de l’annexe' ELSE N'saisies de l’annexe' END) END) AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_article x
    LEFT JOIN (SELECT d.article_cite AS k, COUNT(*) AS n FROM dbo.ref_obligation_distribution d WHERE d.article_cite IS NOT NULL GROUP BY d.article_cite) e1 ON e1.k = x.article
    LEFT JOIN (SELECT d.article AS k, COUNT(*) AS n FROM dbo.ref_question_article d WHERE d.article IS NOT NULL GROUP BY d.article) e2 ON e2.k = x.article
    LEFT JOIN (SELECT d.article_cite AS k, COUNT(*) AS n FROM dbo.ref_ratio d WHERE d.article_cite IS NOT NULL GROUP BY d.article_cite) e3 ON e3.k = x.article
    LEFT JOIN (SELECT d.article_cite AS k, COUNT(*) AS n FROM dbo.ref_ratio_memoire d WHERE d.article_cite IS NOT NULL GROUP BY d.article_cite) e4 ON e4.k = x.article
    LEFT JOIN (SELECT d.article AS k, COUNT(*) AS n FROM dbo.ref_ratio_memoire_article d WHERE d.article IS NOT NULL GROUP BY d.article) e5 ON e5.k = x.article
    LEFT JOIN (SELECT d.article AS k, COUNT(*) AS n FROM dbo.saisie_annexe d WHERE d.article IS NOT NULL GROUP BY d.article) e6 ON e6.k = x.article
    CROSS APPLY (SELECT CAST(CAST(x.article AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_reference
    SELECT 'ref_reference' AS referentiel, k.cle, CONCAT(x.norme, N' ', x.reference) AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) + ISNULL(e2.n, 0) + ISNULL(e3.n, 0) + ISNULL(e4.n, 0) + ISNULL(e5.n, 0) + ISNULL(e6.n, 0) + ISNULL(e7.n, 0) AS emploi,
           CONCAT_WS(N' · ', CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'compte' ELSE N'comptes' END) END, CASE WHEN e2.n > 0 THEN CONCAT(e2.n, N' ', CASE WHEN e2.n < 2 THEN N'contrepartie d’estimation' ELSE N'contreparties d’estimation' END) END, CASE WHEN e3.n > 0 THEN CONCAT(e3.n, N' ', CASE WHEN e3.n < 2 THEN N'correspondance de plan' ELSE N'correspondances de plan' END) END, CASE WHEN e4.n > 0 THEN CONCAT(e4.n, N' ', CASE WHEN e4.n < 2 THEN N'forme de conclusion' ELSE N'formes de conclusion' END) END, CASE WHEN e5.n > 0 THEN CONCAT(e5.n, N' ', CASE WHEN e5.n < 2 THEN N'nature d’actif' ELSE N'natures d’actif' END) END, CASE WHEN e6.n > 0 THEN CONCAT(e6.n, N' ', CASE WHEN e6.n < 2 THEN N'nature de pièce' ELSE N'natures de pièce' END) END, CASE WHEN e7.n > 0 THEN CONCAT(e7.n, N' ', CASE WHEN e7.n < 2 THEN N'question' ELSE N'questions' END) END) AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_reference x
    LEFT JOIN (SELECT d.reference_id AS k, COUNT(*) AS n FROM dbo.ref_compte d WHERE d.reference_id IS NOT NULL GROUP BY d.reference_id) e1 ON e1.k = x.id
    LEFT JOIN (SELECT d.reference_id AS k, COUNT(*) AS n FROM dbo.ref_contrepartie_estimation d WHERE d.reference_id IS NOT NULL GROUP BY d.reference_id) e2 ON e2.k = x.id
    LEFT JOIN (SELECT d.reference_id AS k, COUNT(*) AS n FROM dbo.ref_correspondance_plan d WHERE d.reference_id IS NOT NULL GROUP BY d.reference_id) e3 ON e3.k = x.id
    LEFT JOIN (SELECT d.reference_id AS k, COUNT(*) AS n FROM dbo.ref_forme_conclusion d WHERE d.reference_id IS NOT NULL GROUP BY d.reference_id) e4 ON e4.k = x.id
    LEFT JOIN (SELECT d.reference_id AS k, COUNT(*) AS n FROM dbo.ref_nature_actif d WHERE d.reference_id IS NOT NULL GROUP BY d.reference_id) e5 ON e5.k = x.id
    LEFT JOIN (SELECT d.reference_id AS k, COUNT(*) AS n FROM dbo.ref_nature_piece d WHERE d.reference_id IS NOT NULL GROUP BY d.reference_id) e6 ON e6.k = x.id
    LEFT JOIN (SELECT d.reference_id AS k, COUNT(*) AS n FROM dbo.ref_question_reference d WHERE d.reference_id IS NOT NULL GROUP BY d.reference_id) e7 ON e7.k = x.id
    CROSS APPLY (SELECT CAST(CAST(x.id AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_norme
    SELECT 'ref_norme' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) + ISNULL(e2.n, 0) + ISNULL(e3.n, 0) + ISNULL(e4.n, 0) AS emploi,
           CONCAT_WS(N' · ', CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'article' ELSE N'articles' END) END, CASE WHEN e2.n > 0 THEN CONCAT(e2.n, N' ', CASE WHEN e2.n < 2 THEN N'correspondance de plan' ELSE N'correspondances de plan' END) END, CASE WHEN e3.n > 0 THEN CONCAT(e3.n, N' ', CASE WHEN e3.n < 2 THEN N'norme abrogée' ELSE N'normes abrogées' END) END, CASE WHEN e4.n > 0 THEN CONCAT(e4.n, N' ', CASE WHEN e4.n < 2 THEN N'référence' ELSE N'références' END) END) AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_norme x
    LEFT JOIN (SELECT d.norme AS k, COUNT(*) AS n FROM dbo.ref_article d WHERE d.norme IS NOT NULL GROUP BY d.norme) e1 ON e1.k = x.code
    LEFT JOIN (SELECT d.norme_source AS k, COUNT(*) AS n FROM dbo.ref_correspondance_plan d WHERE d.norme_source IS NOT NULL GROUP BY d.norme_source) e2 ON e2.k = x.code
    LEFT JOIN (SELECT d.abroge_par AS k, COUNT(*) AS n FROM dbo.ref_norme d WHERE d.abroge_par IS NOT NULL GROUP BY d.abroge_par) e3 ON e3.k = x.code
    LEFT JOIN (SELECT d.norme AS k, COUNT(*) AS n FROM dbo.ref_reference d WHERE d.norme IS NOT NULL GROUP BY d.norme) e4 ON e4.k = x.code
    CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- modele_feuille
    SELECT 'modele_feuille' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) + ISNULL(e2.n, 0) AS emploi,
           CONCAT_WS(N' · ', CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'feuille' ELSE N'feuilles' END) END, CASE WHEN e2.n > 0 THEN CONCAT(e2.n, N' ', CASE WHEN e2.n < 2 THEN N'question' ELSE N'questions' END) END) AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.modele_feuille x
    LEFT JOIN (SELECT d.modele_code AS k, COUNT(*) AS n FROM dbo.feuille_travail d WHERE d.modele_code IS NOT NULL GROUP BY d.modele_code) e1 ON e1.k = x.code
    LEFT JOIN (SELECT d.modele_code AS k, COUNT(*) AS n FROM dbo.ref_question_modele d WHERE d.modele_code IS NOT NULL GROUP BY d.modele_code) e2 ON e2.k = x.code
    CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_question_modele
    SELECT 'ref_question_modele' AS referentiel, k.cle, CONCAT(ISNULL(q.reference, CAST(x.question_id AS NVARCHAR (20))), N' · ', CAST(x.modele_code AS NVARCHAR (200))) AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           0 AS emploi,
           N'' AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.ref_question_modele x
    LEFT JOIN dbo.ref_question q ON q.id = x.question_id
    CROSS APPLY (SELECT CAST(CONCAT(CAST(x.question_id AS NVARCHAR (200)), N' · ', CAST(x.modele_code AS NVARCHAR (200))) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- modele_ecriture
    SELECT 'modele_ecriture' AS referentiel, k.cle, CONCAT(ISNULL(q.reference, CAST(x.question_id AS NVARCHAR (20))), N' · ', x.ordre) AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           0 AS emploi,
           N'' AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.modele_ecriture x
    LEFT JOIN dbo.ref_question q ON q.id = x.question_id
    CROSS APPLY (SELECT CAST(CAST(x.id AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_piece_attendue
    SELECT 'ref_piece_attendue' AS referentiel, k.cle, CONCAT(COALESCE(NULLIF(x.cycle, N''), NULLIF(x.phase, N''), N''), N' · ', x.ordre) AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) AS emploi,
           ISNULL(CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'pièce rattachée' ELSE N'pièces rattachées' END) END, N'') AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.ref_piece_attendue x
    LEFT JOIN (SELECT d.piece_attendue_id AS k, COUNT(*) AS n FROM dbo.piece_rattachement d WHERE d.piece_attendue_id IS NOT NULL GROUP BY d.piece_attendue_id) e1 ON e1.k = x.id
    CROSS APPLY (SELECT CAST(CAST(x.id AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_nature_piece
    SELECT 'ref_nature_piece' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) AS emploi,
           ISNULL(CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'pièce' ELSE N'pièces' END) END, N'') AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.ref_nature_piece x
    LEFT JOIN (SELECT d.nature AS k, COUNT(*) AS n FROM dbo.piece d WHERE d.nature IS NOT NULL GROUP BY d.nature) e1 ON e1.k = x.code
    CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_nature_actif
    SELECT 'ref_nature_actif' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) AS emploi,
           ISNULL(CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'actif' ELSE N'actifs' END) END, N'') AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.ref_nature_actif x
    LEFT JOIN (SELECT d.nature AS k, COUNT(*) AS n FROM dbo.actif d WHERE d.nature IS NOT NULL GROUP BY d.nature) e1 ON e1.k = x.nature
    CROSS APPLY (SELECT CAST(CAST(x.nature AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_contrepartie_estimation
    SELECT 'ref_contrepartie_estimation' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           0 AS emploi,
           N'' AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.ref_contrepartie_estimation x
    CROSS APPLY (SELECT CAST(CAST(x.compte_estimation AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_correspondance_plan
    SELECT 'ref_correspondance_plan' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           0 AS emploi,
           N'' AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.ref_correspondance_plan x
    CROSS APPLY (SELECT CAST(CONCAT(CAST(x.norme_source AS NVARCHAR (200)), N' · ', CAST(x.compte_source AS NVARCHAR (200))) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_nature_arrete
    SELECT 'ref_nature_arrete' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) + ISNULL(e2.n, 0) AS emploi,
           CONCAT_WS(N' · ', CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'arrêté ouvert' ELSE N'arrêtés ouverts' END) END, CASE WHEN e2.n > 0 THEN CONCAT(e2.n, N' ', CASE WHEN e2.n < 2 THEN N'arrêté planifié' ELSE N'arrêtés planifiés' END) END) AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.ref_nature_arrete x
    LEFT JOIN (SELECT d.type_arrete AS k, COUNT(*) AS n FROM dbo.arrete_mission d WHERE d.type_arrete IS NOT NULL GROUP BY d.type_arrete) e1 ON e1.k = x.code
    LEFT JOIN (SELECT d.type_arrete AS k, COUNT(*) AS n FROM dbo.ref_arrete d WHERE d.type_arrete IS NOT NULL GROUP BY d.type_arrete) e2 ON e2.k = x.code
    CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_forme_conclusion
    SELECT 'ref_forme_conclusion' AS referentiel, k.cle, COALESCE(NULLIF(x.libelle, N''), k.cle) AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) + ISNULL(e2.n, 0) AS emploi,
           CONCAT_WS(N' · ', CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'conclusion de cycle' ELSE N'conclusions de cycle' END) END, CASE WHEN e2.n > 0 THEN CONCAT(e2.n, N' ', CASE WHEN e2.n < 2 THEN N'feuille' ELSE N'feuilles' END) END) AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_forme_conclusion x
    LEFT JOIN (SELECT d.forme AS k, COUNT(*) AS n FROM dbo.conclusion_cycle d WHERE d.forme IS NOT NULL GROUP BY d.forme) e1 ON e1.k = x.code
    LEFT JOIN (SELECT d.forme_conclusion AS k, COUNT(*) AS n FROM dbo.feuille_travail d WHERE d.forme_conclusion IS NOT NULL GROUP BY d.forme_conclusion) e2 ON e2.k = x.code
    CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_role
    SELECT 'ref_role' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) + ISNULL(e2.n, 0) AS emploi,
           CONCAT_WS(N' · ', CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'mandat' ELSE N'mandats' END) END, CASE WHEN e2.n > 0 THEN CONCAT(e2.n, N' ', CASE WHEN e2.n < 2 THEN N'nature visable' ELSE N'natures visables' END) END) AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.ref_role x
    LEFT JOIN (SELECT d.role AS k, COUNT(*) AS n FROM dbo.role_mission d WHERE d.role IS NOT NULL GROUP BY d.role) e1 ON e1.k = x.code
    LEFT JOIN (SELECT d.role_code AS k, COUNT(*) AS n FROM dbo.role_nature_visa d WHERE d.role_code IS NOT NULL GROUP BY d.role_code) e2 ON e2.k = x.code
    CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- role_nature_visa
    SELECT 'role_nature_visa' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           0 AS emploi,
           N'' AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.role_nature_visa x
    CROSS APPLY (SELECT CAST(CONCAT(CAST(x.role_code AS NVARCHAR (200)), N' · ', CAST(x.nature AS NVARCHAR (200))) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_question_reference
    SELECT 'ref_question_reference' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           0 AS emploi,
           N'' AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.ref_question_reference x
    LEFT JOIN dbo.ref_reference rk ON rk.id = x.reference_id
    CROSS APPLY (SELECT CAST(CONCAT(CAST(x.question_reference AS NVARCHAR (200)), N' · ', CONCAT(rk.norme, N' ', rk.reference)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_rubrique_resultat
    SELECT 'ref_rubrique_resultat' AS referentiel, k.cle, COALESCE(NULLIF(x.libelle, N''), k.cle) AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) AS emploi,
           ISNULL(CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'compte' ELSE N'comptes' END) END, N'') AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_rubrique_resultat x
    LEFT JOIN (SELECT d.rubrique_resultat AS k, COUNT(*) AS n FROM dbo.ref_compte d WHERE d.rubrique_resultat IS NOT NULL GROUP BY d.rubrique_resultat) e1 ON e1.k = x.code
    CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_ratio
    SELECT 'ref_ratio' AS referentiel, k.cle, COALESCE(NULLIF(x.libelle, N''), k.cle) AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           0 AS emploi,
           N'' AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_ratio x
    CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_categorie_actif_cmf
    SELECT 'ref_categorie_actif_cmf' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           0 AS emploi,
           N'' AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_categorie_actif_cmf x
    CROSS APPLY (SELECT CAST(CAST(x.rang AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_obligation_distribution
    SELECT 'ref_obligation_distribution' AS referentiel, k.cle, COALESCE(NULLIF(x.libelle, N''), k.cle) AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) AS emploi,
           ISNULL(CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'décision' ELSE N'décisions' END) END, N'') AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_obligation_distribution x
    LEFT JOIN (SELECT d.categorie AS k, COUNT(*) AS n FROM dbo.decision_distribution d WHERE d.categorie IS NOT NULL GROUP BY d.categorie) e1 ON e1.k = x.categorie
    CROSS APPLY (SELECT CAST(CAST(x.categorie AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_ligne_etat
    SELECT 'ref_ligne_etat' AS referentiel, k.cle, CONCAT(COALESCE((SELECT lv.libelle FROM dbo.ref_libelle_valeur lv WHERE lv.table_nom = 'ref_ligne_etat' AND lv.colonne = 'etat' AND lv.valeur = x.etat), x.etat), N' · ', COALESCE(NULLIF(x.libelle, N''), k.cle)) AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           0 AS emploi,
           N'' AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_ligne_etat x
    CROSS APPLY (SELECT CAST(CONCAT(CAST(x.etat AS NVARCHAR (200)), N' · ', CAST(x.code AS NVARCHAR (200))) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_tableau_annexe
    SELECT 'ref_tableau_annexe' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) AS emploi,
           ISNULL(CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'ligne d’annexe' ELSE N'lignes d’annexe' END) END, N'') AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_tableau_annexe x
    LEFT JOIN (SELECT d.article AS k, COUNT(*) AS n FROM dbo.ref_ligne_annexe d WHERE d.article IS NOT NULL GROUP BY d.article) e1 ON e1.k = x.article
    CROSS APPLY (SELECT CAST(CAST(x.article AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_livrable
    SELECT 'ref_livrable' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) + ISNULL(e2.n, 0) AS emploi,
           CONCAT_WS(N' · ', CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'demande de document' ELSE N'demandes de document' END) END, CASE WHEN e2.n > 0 THEN CONCAT(e2.n, N' ', CASE WHEN e2.n < 2 THEN N'document produit' ELSE N'documents produits' END) END) AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.ref_livrable x
    LEFT JOIN (SELECT d.livrable AS k, COUNT(*) AS n FROM dbo.demande_document d WHERE d.livrable IS NOT NULL GROUP BY d.livrable) e1 ON e1.k = x.code
    LEFT JOIN (SELECT d.livrable AS k, COUNT(*) AS n FROM dbo.document_produit d WHERE d.livrable IS NOT NULL GROUP BY d.livrable) e2 ON e2.k = x.code
    CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_ligne_annexe
    SELECT 'ref_ligne_annexe' AS referentiel, k.cle, CONCAT(CAST(x.article AS NVARCHAR (200)), N', ligne ', x.ordre, N' : ', x.libelle) AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           0 AS emploi,
           N'' AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_ligne_annexe x
    CROSS APPLY (SELECT CAST(CONCAT(CAST(x.article AS NVARCHAR (200)), N' · ', CAST(x.code AS NVARCHAR (200))) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_cas_eligibilite
    SELECT 'ref_cas_eligibilite' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) AS emploi,
           ISNULL(CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'participation' ELSE N'participations' END) END, N'') AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_cas_eligibilite x
    LEFT JOIN (SELECT d.cas_relation AS k, COUNT(*) AS n FROM dbo.eligibilite_participation d WHERE d.cas_relation IS NOT NULL GROUP BY d.cas_relation) e1 ON e1.k = x.cas
    CROSS APPLY (SELECT CAST(CAST(x.cas AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_cas_immeuble
    SELECT 'ref_cas_immeuble' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) AS emploi,
           ISNULL(CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'actif' ELSE N'actifs' END) END, N'') AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_cas_immeuble x
    LEFT JOIN (SELECT d.cas_r214_81 AS k, COUNT(*) AS n FROM dbo.actif d WHERE d.cas_r214_81 IS NOT NULL GROUP BY d.cas_r214_81) e1 ON e1.k = x.cas
    CROSS APPLY (SELECT CAST(CAST(x.cas AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_droit_reel
    SELECT 'ref_droit_reel' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) AS emploi,
           ISNULL(CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'actif' ELSE N'actifs' END) END, N'') AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_droit_reel x
    LEFT JOIN (SELECT d.droit_r214_82 AS k, COUNT(*) AS n FROM dbo.actif d WHERE d.droit_r214_82 IS NOT NULL GROUP BY d.droit_r214_82) e1 ON e1.k = x.droit
    CROSS APPLY (SELECT CAST(CAST(x.droit AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_controle
    SELECT 'ref_controle' AS referentiel, k.cle, COALESCE(NULLIF(x.libelle, N''), k.cle) AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) AS emploi,
           ISNULL(CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'relevé' ELSE N'relevés' END) END, N'') AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.ref_controle x
    LEFT JOIN (SELECT d.vue AS k, COUNT(*) AS n FROM dbo.releve_controle d WHERE d.vue IS NOT NULL GROUP BY d.vue) e1 ON e1.k = x.vue
    CROSS APPLY (SELECT CAST(CAST(x.vue AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_forme_rapport
    SELECT 'ref_forme_rapport' AS referentiel, k.cle, CASE WHEN NULLIF(x.exemple, N'') IS NOT NULL THEN CONCAT(N'NP 2300, exemple ', x.exemple) ELSE k.cle END AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           0 AS emploi,
           N'' AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_forme_rapport x
    CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_source_valeur
    SELECT 'ref_source_valeur' AS referentiel, k.cle, COALESCE(NULLIF(x.libelle, N''), k.cle) AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           0 AS emploi,
           N'' AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_source_valeur x
    CROSS APPLY (SELECT CAST(CAST(x.source AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_ratio_memoire
    SELECT 'ref_ratio_memoire' AS referentiel, k.cle, COALESCE(NULLIF(x.libelle, N''), k.cle) AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) + ISNULL(e2.n, 0) + ISNULL(e3.n, 0) AS emploi,
           CONCAT_WS(N' · ', CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'conclusion' ELSE N'conclusions' END) END, CASE WHEN e2.n > 0 THEN CONCAT(e2.n, N' ', CASE WHEN e2.n < 2 THEN N'mention d’article' ELSE N'mentions d’articles' END) END, CASE WHEN e3.n > 0 THEN CONCAT(e3.n, N' ', CASE WHEN e3.n < 2 THEN N'seuil propre' ELSE N'seuils propres' END) END) AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_ratio_memoire x
    LEFT JOIN (SELECT d.code AS k, COUNT(*) AS n FROM dbo.conclusion_ratio d WHERE d.code IS NOT NULL GROUP BY d.code) e1 ON e1.k = x.code
    LEFT JOIN (SELECT d.code AS k, COUNT(*) AS n FROM dbo.ref_ratio_memoire_article d WHERE d.code IS NOT NULL GROUP BY d.code) e2 ON e2.k = x.code
    LEFT JOIN (SELECT d.code AS k, COUNT(*) AS n FROM dbo.ref_ratio_vehicule d WHERE d.code IS NOT NULL GROUP BY d.code) e3 ON e3.k = x.code
    CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_ratio_vehicule
    SELECT 'ref_ratio_vehicule' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           0 AS emploi,
           N'' AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_ratio_vehicule x
    CROSS APPLY (SELECT CAST(CONCAT(CAST(x.entite AS NVARCHAR (200)), N' · ', CAST(x.code AS NVARCHAR (200))) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_cycle_compte
    SELECT 'ref_cycle_compte' AS referentiel, k.cle, k.cle AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           0 AS emploi,
           N'' AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.ref_cycle_compte x
    CROSS APPLY (SELECT CAST(CONCAT(CAST(x.cycle AS NVARCHAR (200)), N' · ', CAST(x.racine AS NVARCHAR (200))) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_question_compte
    SELECT 'ref_question_compte' AS referentiel, k.cle, CONCAT(ISNULL(q.reference, CAST(x.question_id AS NVARCHAR (20))), N' · ', CAST(x.racine AS NVARCHAR (200))) AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           0 AS emploi,
           N'' AS employee_par,
           0 AS lecture_seule,
           CAST(x.ecartee_le AS DATE) AS ecartee_le
    FROM dbo.ref_question_compte x
    LEFT JOIN dbo.ref_question q ON q.id = x.question_id
    CROSS APPLY (SELECT CAST(CONCAT(CAST(x.question_id AS NVARCHAR (200)), N' · ', CAST(x.racine AS NVARCHAR (200))) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_parametre
    SELECT 'ref_parametre' AS referentiel, k.cle, COALESCE(NULLIF(x.libelle, N''), k.cle) AS ligne,
           CASE WHEN x.pose_par = N'installation' THEN NULL ELSE x.pose_le END AS modifie_le, CASE WHEN x.pose_par = N'installation' THEN NULL ELSE x.pose_par END AS modifie_par,
           0 AS emploi,
           N'' AS employee_par,
           CASE WHEN x.genre = 'INSTALLATION' THEN 1 ELSE 0 END AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_parametre x
    CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
    UNION ALL
    -- ref_sujet_tenue
    SELECT 'ref_sujet_tenue' AS referentiel, k.cle, COALESCE(NULLIF(x.libelle, N''), k.cle) AS ligne,
           x.modifie_le AS modifie_le, x.modifie_par AS modifie_par,
           ISNULL(e1.n, 0) AS emploi,
           ISNULL(CASE WHEN e1.n > 0 THEN CONCAT(e1.n, N' ', CASE WHEN e1.n < 2 THEN N'question' ELSE N'questions' END) END, N'') AS employee_par,
           0 AS lecture_seule,
           CAST(NULL AS DATE) AS ecartee_le
    FROM dbo.ref_sujet_tenue x
    LEFT JOIN (SELECT d.sujet_tenue AS k, COUNT(*) AS n FROM dbo.ref_question d WHERE d.sujet_tenue IS NOT NULL GROUP BY d.sujet_tenue) e1 ON e1.k = x.code
    CROSS APPLY (SELECT CAST(CAST(x.code AS NVARCHAR (200)) AS NVARCHAR (400)) AS cle) k
) t;

GO

