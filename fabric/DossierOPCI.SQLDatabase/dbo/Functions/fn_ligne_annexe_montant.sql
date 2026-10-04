
-- Le calcul de l'annexe, en 4 temps materialises : les sources (etats, sommes distribuables, racines, acomptes non
-- repartis, saisie), les lignes sans formule de codes, les lignes de formule de codes, puis la feuille complete.
CREATE   FUNCTION dbo.fn_ligne_annexe_montant ()
RETURNS @res TABLE (article VARCHAR (10) NOT NULL, code VARCHAR (24) NOT NULL, libelle NVARCHAR (400) NOT NULL, niveau INT NOT NULL,
                    type_ligne VARCHAR (14) NOT NULL, signe VARCHAR (4) NULL, ordre INT NOT NULL, renvoi NVARCHAR (600) NULL,
                    formule NVARCHAR (300) NULL, tableau NVARCHAR (300) NOT NULL, entite VARCHAR (20) NOT NULL, arrete VARCHAR (20) NOT NULL,
                    exercice_n DECIMAL (19, 2) NULL, exercice_n_1 DECIMAL (19, 2) NULL, valeur_saisie NVARCHAR (2000) NULL,
                    montant_saisi DECIMAL (19, 2) NULL, a_saisir BIT NOT NULL,
                    colonne_1 DECIMAL (19, 2) NULL, colonne_2 DECIMAL (19, 2) NULL, colonne_3 DECIMAL (19, 2) NULL,
                    colonne_4 DECIMAL (19, 2) NULL, colonne_5 DECIMAL (19, 2) NULL, colonne_6 DECIMAL (19, 2) NULL,
                    colonne_7 DECIMAL (19, 2) NULL, formule_calcul NVARCHAR (400) NULL,
                    PRIMARY KEY (entite, arrete, article, code))
AS BEGIN
    -- les arretes, avec l'arrete N-1 et celui de l'exercice d'avant (la colonne N-1 d'une ligne N1)
    DECLARE @a TABLE (entite VARCHAR (20) NOT NULL, arrete VARCHAR (20) NOT NULL, arrete_n_1 VARCHAR (20) NULL, arrete_n_2 VARCHAR (20) NULL,
                      porte_balance BIT NULL, porte_balance_n_1 BIT NULL, porte_balance_n_2 BIT NULL, premier_exercice BIT NULL,
                      PRIMARY KEY (entite, arrete));
    INSERT @a
    SELECT a.entite, a.arrete, a.arrete_n_1, p.arrete_n_1, a.porte_balance, a.porte_balance_n_1, p.porte_balance_n_1, a.premier_exercice
    FROM dbo.v_arrete_etat a LEFT JOIN dbo.v_arrete_etat p ON p.entite = a.entite AND p.arrete = a.arrete_n_1;

    DECLARE @m TABLE (entite VARCHAR (20) NOT NULL, arrete VARCHAR (20) NOT NULL, code VARCHAR (20) NOT NULL,
                      exercice_n DECIMAL (19, 2) NULL, exercice_n_1 DECIMAL (19, 2) NULL, PRIMARY KEY (entite, arrete, code));
    INSERT @m SELECT entite, arrete, code, exercice_n, exercice_n_1 FROM dbo.fn_ligne_etat_montant();

    DECLARE @sd TABLE (entite VARCHAR (20) NOT NULL, arrete VARCHAR (20) NOT NULL, total DECIMAL (19, 2) NULL, PRIMARY KEY (entite, arrete));
    INSERT @sd SELECT entite, arrete, total_distribuable FROM dbo.fn_sommes_distribuables();

    DECLARE @r TABLE (article VARCHAR (10) NOT NULL, code VARCHAR (24) NOT NULL, entite VARCHAR (20) NOT NULL, arrete VARCHAR (20) NOT NULL,
                      montant DECIMAL (19, 2) NULL, PRIMARY KEY (entite, arrete, article, code));
    INSERT @r SELECT article, code, entite, arrete, montant FROM dbo.v_ligne_annexe_racine;

    DECLARE @u TABLE (entite VARCHAR (20) NOT NULL, arrete VARCHAR (20) NOT NULL, PRIMARY KEY (entite, arrete));
    INSERT @u SELECT entite, arrete FROM dbo.v_acompte_non_reparti;

    DECLARE @s TABLE (entite VARCHAR (20) NOT NULL, arrete VARCHAR (20) NOT NULL, article VARCHAR (10) NOT NULL, ligne NVARCHAR (300) NOT NULL,
                      c1 DECIMAL (19, 2) NULL, c2 DECIMAL (19, 2) NULL, c3 DECIMAL (19, 2) NULL, c4 DECIMAL (19, 2) NULL,
                      c5 DECIMAL (19, 2) NULL, c6 DECIMAL (19, 2) NULL, c7 DECIMAL (19, 2) NULL,
                      valeur NVARCHAR (2000) NULL, montant DECIMAL (19, 2) NULL, n INT NOT NULL, PRIMARY KEY (entite, arrete, article, ligne));
    INSERT @s
    SELECT sa.entite, sa.arrete, sa.article, sa.ligne,
           MAX(CASE WHEN sa.colonne = '1' THEN sa.montant END), MAX(CASE WHEN sa.colonne = '2' THEN sa.montant END),
           MAX(CASE WHEN sa.colonne = '3' THEN sa.montant END), MAX(CASE WHEN sa.colonne = '4' THEN sa.montant END),
           MAX(CASE WHEN sa.colonne = '5' THEN sa.montant END), MAX(CASE WHEN sa.colonne = '6' THEN sa.montant END),
           MAX(CASE WHEN sa.colonne = '7' THEN sa.montant END),
           MAX(sa.valeur), MAX(sa.montant), COUNT(*)
    FROM dbo.saisie_annexe sa GROUP BY sa.entite, sa.arrete, sa.article, sa.ligne;

    -- les lignes sans formule de codes : la saisie, sinon le calcul
    DECLARE @f TABLE (article VARCHAR (10) NOT NULL, code VARCHAR (24) NOT NULL, entite VARCHAR (20) NOT NULL, arrete VARCHAR (20) NOT NULL,
                      n DECIMAL (19, 2) NULL, n_1 DECIMAL (19, 2) NULL,
                      c1 DECIMAL (19, 2) NULL, c2 DECIMAL (19, 2) NULL, c3 DECIMAL (19, 2) NULL, c4 DECIMAL (19, 2) NULL,
                      c5 DECIMAL (19, 2) NULL, c6 DECIMAL (19, 2) NULL, c7 DECIMAL (19, 2) NULL, PRIMARY KEY (entite, arrete, article, code));
    INSERT @f
    SELECT l.article, l.code, a.entite, a.arrete, b.n, b.n_1,
           COALESCE(s.c1, b.n), COALESCE(s.c2, b.n_1), s.c3, s.c4, s.c5, s.c6, s.c7
    FROM dbo.ref_ligne_annexe l
    CROSS JOIN @a a
    LEFT JOIN @m m ON m.entite = a.entite AND m.arrete = a.arrete
         AND m.code = CASE WHEN l.formule_calcul LIKE 'ETAT:%' THEN SUBSTRING(l.formule_calcul, 6, 40)
                           WHEN l.formule_calcul LIKE 'ETAT[_]N1:%' THEN SUBSTRING(l.formule_calcul, 9, 40) END
    LEFT JOIN @m mp ON mp.entite = a.entite AND mp.arrete = a.arrete_n_1
         AND mp.code = CASE WHEN l.formule_calcul LIKE 'ETAT[_]N1:%' THEN SUBSTRING(l.formule_calcul, 9, 40) END
    LEFT JOIN @sd sd ON sd.entite = a.entite AND sd.arrete = a.arrete
    LEFT JOIN @sd sdp ON sdp.entite = a.entite AND sdp.arrete = a.arrete_n_1
    LEFT JOIN @u u ON u.entite = a.entite AND u.arrete = a.arrete
    LEFT JOIN @u up ON up.entite = a.entite AND up.arrete = a.arrete_n_1
    LEFT JOIN @r r ON r.entite = a.entite AND r.arrete = a.arrete AND r.article = l.article AND r.code = l.code
    LEFT JOIN @r rp ON rp.entite = a.entite AND rp.arrete = a.arrete_n_1 AND rp.article = l.article AND rp.code = l.code
    LEFT JOIN @r rpp ON rpp.entite = a.entite AND rpp.arrete = a.arrete_n_2 AND rpp.article = l.article AND rpp.code = l.code
    LEFT JOIN @s s ON s.entite = a.entite AND s.arrete = a.arrete AND s.article = l.article AND s.ligne = l.code
    CROSS APPLY (SELECT
        CASE
          WHEN l.formule_calcul LIKE 'ETAT:%' THEN m.exercice_n
          WHEN l.formule_calcul LIKE 'ETAT[_]N1:%' THEN m.exercice_n_1
          WHEN l.formule_calcul = 'SD:total' THEN sd.total
          WHEN a.porte_balance = 0 THEN NULL
          WHEN l.formule_calcul LIKE 'REPARTI:%' THEN CASE WHEN u.entite IS NOT NULL THEN NULL ELSE ISNULL(r.montant, 0) END
          WHEN l.formule_calcul = 'N1' THEN CASE WHEN a.porte_balance_n_1 = 1 THEN ISNULL(rp.montant, 0) END
          WHEN l.racines IS NOT NULL THEN ISNULL(r.montant, 0)
        END AS n,
        CASE
          WHEN a.premier_exercice = 1 THEN NULL
          WHEN l.formule_calcul LIKE 'ETAT:%' THEN m.exercice_n_1
          WHEN l.formule_calcul LIKE 'ETAT[_]N1:%' THEN mp.exercice_n_1
          WHEN l.formule_calcul = 'SD:total' THEN sdp.total
          WHEN a.porte_balance_n_1 = 0 OR a.porte_balance_n_1 IS NULL THEN NULL
          WHEN l.formule_calcul LIKE 'REPARTI:%' THEN CASE WHEN up.entite IS NOT NULL THEN NULL ELSE ISNULL(rp.montant, 0) END
          WHEN l.formule_calcul = 'N1' THEN CASE WHEN a.porte_balance_n_2 = 1 THEN ISNULL(rpp.montant, 0) END
          WHEN l.racines IS NOT NULL THEN ISNULL(rp.montant, 0)
        END AS n_1) b
    WHERE NOT (l.formule_calcul IS NOT NULL AND l.formule_calcul NOT LIKE '%:%' AND l.formule_calcul <> 'N1');

    -- les lignes de formule de codes : chaque colonne se calcule si toutes ses composantes y ont une valeur
    DECLARE @x TABLE (article VARCHAR (10) NOT NULL, code VARCHAR (24) NOT NULL, entite VARCHAR (20) NOT NULL, arrete VARCHAR (20) NOT NULL,
                      c1 DECIMAL (19, 2) NULL, c2 DECIMAL (19, 2) NULL, c3 DECIMAL (19, 2) NULL, c4 DECIMAL (19, 2) NULL,
                      c5 DECIMAL (19, 2) NULL, c6 DECIMAL (19, 2) NULL, c7 DECIMAL (19, 2) NULL, PRIMARY KEY (entite, arrete, article, code));
    INSERT @x
    SELECT f.article, f.code, a.entite, a.arrete,
           CASE WHEN COUNT(*) = COUNT(c.c1) THEN SUM(f.signe * c.c1) END,
           CASE WHEN COUNT(*) = COUNT(c.c2) THEN SUM(f.signe * c.c2) END,
           CASE WHEN COUNT(*) = COUNT(c.c3) THEN SUM(f.signe * c.c3) END,
           CASE WHEN COUNT(*) = COUNT(c.c4) THEN SUM(f.signe * c.c4) END,
           CASE WHEN COUNT(*) = COUNT(c.c5) THEN SUM(f.signe * c.c5) END,
           CASE WHEN COUNT(*) = COUNT(c.c6) THEN SUM(f.signe * c.c6) END,
           CASE WHEN COUNT(*) = COUNT(c.c7) THEN SUM(f.signe * c.c7) END
    FROM dbo.v_ligne_annexe_formule f
    CROSS JOIN @a a
    LEFT JOIN @f c ON c.article = f.article AND c.code = f.code_composante AND c.entite = a.entite AND c.arrete = a.arrete
    WHERE NOT EXISTS (SELECT 1 FROM dbo.v_controle_formule_annexe k WHERE k.article = f.article AND k.code = f.code)
    GROUP BY f.article, f.code, a.entite, a.arrete;

    INSERT @res
    SELECT l.article, l.code, l.libelle, l.niveau, l.type_ligne, l.signe,
           l.ordre, l.renvoi, l.formule,
           t.libelle,
           a.entite, a.arrete,
           COALESCE(fe.n, x.c1),
           COALESCE(fe.n_1, x.c2),
           s.valeur,
           s.montant,
           CASE WHEN s.n IS NULL AND (l.type_ligne = 'SAISIE' OR (l.formule_calcul LIKE 'REPARTI:%' AND fe.c1 IS NULL)) THEN 1 ELSE 0 END,
           COALESCE(s.c1, fe.c1, x.c1), COALESCE(s.c2, fe.c2, x.c2), COALESCE(s.c3, fe.c3, x.c3), COALESCE(s.c4, fe.c4, x.c4),
           COALESCE(s.c5, fe.c5, x.c5), COALESCE(s.c6, fe.c6, x.c6), COALESCE(s.c7, fe.c7, x.c7),
           l.formule_calcul
    FROM dbo.ref_ligne_annexe l
    JOIN dbo.ref_tableau_annexe t ON t.article = l.article
    CROSS JOIN @a a
    LEFT JOIN @f fe ON fe.article = l.article AND fe.code = l.code AND fe.entite = a.entite AND fe.arrete = a.arrete
    LEFT JOIN @x x ON x.article = l.article AND x.code = l.code AND x.entite = a.entite AND x.arrete = a.arrete
    LEFT JOIN @s s ON s.entite = a.entite AND s.arrete = a.arrete AND s.article = l.article AND s.ligne = l.code;
    RETURN;
END;

GO

