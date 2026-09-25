
-- --- 2 : le niveau 1, avec sa reference complete ---------------------
CREATE   VIEW dbo.v_valeur_actuelle_actif AS
WITH candidate AS (
    SELECT a.entite_detentrice AS entite, a.code AS code_actif, a.nature,
           a.poste_bilan, r.arrete, r.date_arrete, r.exercice, r.type_arrete,
           CAST(a.prix_de_revient AS DECIMAL (19,2)) AS valeur_comptable,
           ev.valeur_retenue, ev.source AS source_retenue, ev.vise_par,
           ex.valeur_actuelle AS valeur_expertise,
           ex.date_valeur AS date_expertise, ex.expert, ex.methode,
           CAST(ct.quantite * ct.cours AS DECIMAL (19,2)) AS valeur_cours,
           vi.valeur_actuelle AS valeur_instrument,
           n.reference_id, n.expertise_requise
    FROM dbo.actif a
    JOIN dbo.ref_nature_actif n ON n.nature = a.nature
    JOIN dbo.ref_arrete r ON r.entite = a.entite_detentrice
                         AND r.porte_balance = 1
    -- LA VALEUR RETENUE N'ENTRE DANS LA VALORISATION QUE VISEE. Releve
    -- le 04/09/2026 : la vue lisait toute valeur retenue, quel que soit
    -- son etat, et le semis du script 83 porte precisement une valeur
    -- RENVOYEE par le chef de mission sur IMM-201. La difference
    -- d'estimation des immeubles de l'OPCI en a ete faussee de
    -- 230 000,00, la valeur renvoyee se substituant a l'expertise. Le
    -- defaut existait depuis le lot E et ne se voyait pas, la table
    -- etant vide. C'est le visa qui fait la valeur, article 30 de la
    -- NPMQ : la supervision porte sur le bon deroulement de la mission.
    LEFT JOIN dbo.evaluation_actif ev ON ev.code_actif = a.code
                                     AND ev.entite = r.entite
                                     AND ev.arrete = r.arrete
                                     AND ev.etat = 'VISE'
    LEFT JOIN dbo.cours_titre ct ON ct.code_actif = a.code
                                AND ct.entite = r.entite AND ct.arrete = r.arrete
    LEFT JOIN dbo.valeur_instrument vi ON vi.code_actif = a.code
                                      AND vi.entite = r.entite
                                      AND vi.arrete = r.arrete
    OUTER APPLY (
        SELECT TOP (1) e.valeur_actuelle, e.date_valeur, e.expert, e.methode
        FROM dbo.expertise e
        WHERE e.code_actif = a.code AND e.date_valeur <= r.date_arrete
        ORDER BY e.date_valeur DESC
    ) AS ex
    WHERE a.nature NOT IN ('TITRES_ENTITE_IMMOBILIERE', 'AVANCE_COMPTE_COURANT')
      AND (a.date_acquisition IS NULL OR a.date_acquisition <= r.date_arrete)
)
SELECT c.entite, c.code_actif, c.nature, c.poste_bilan, c.arrete,
       c.date_arrete, c.exercice, c.type_arrete, c.valeur_comptable,
       COALESCE(c.valeur_retenue, c.valeur_expertise, c.valeur_cours,
                c.valeur_instrument) AS valeur_actuelle,
       CAST(COALESCE(c.valeur_retenue, c.valeur_expertise, c.valeur_cours,
                     c.valeur_instrument) - c.valeur_comptable
            AS DECIMAL (19,2))                        AS difference_estimation,
       CASE WHEN c.valeur_retenue    IS NOT NULL THEN c.source_retenue
            WHEN c.valeur_expertise  IS NOT NULL THEN 'EXPERTISE'
            WHEN c.valeur_cours      IS NOT NULL THEN 'MARCHE'
            WHEN c.valeur_instrument IS NOT NULL THEN 'MODELE'
       END                                            AS source,
       c.date_expertise, c.expert, c.methode, c.vise_par, c.valeur_expertise,
       CAST(CASE WHEN c.valeur_retenue IS NOT NULL
                  AND c.valeur_expertise IS NOT NULL
                 THEN c.valeur_retenue - c.valeur_expertise END
            AS DECIMAL (19,2))                        AS ecart_a_l_expertise,
       -- La reference vient desormais du referentiel : la colonne article
       -- est un report, non une saisie.
       CAST(rf.reference AS VARCHAR (40))             AS article,
       rf.norme, rf.reference, rf.citation_courte, rf.intitule AS article_intitule,
       rf.lu_sur_piece, rf.norme_en_vigueur,
       c.expertise_requise
FROM candidate c
LEFT JOIN dbo.v_reference rf ON rf.id = c.reference_id
WHERE COALESCE(c.valeur_retenue, c.valeur_expertise, c.valeur_cours,
               c.valeur_instrument) IS NOT NULL;

GO

