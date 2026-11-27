-- Les libelles d'en-tete viennent de la vue, et une mesure ne lit jamais une colonne d'affichage : renommer une
-- colonne au modele par l'API ou le TMDL ne met pas a jour les mesures qui la lisent, a la difference de Power BI
-- Desktop, et la mesure tombe ; nativeQueryRef est ignore pour une colonne d'un tableEx comme pour une mesure.
-- La regle, pour toutes les vues d'ecran :
--   1. la vue porte le libelle que le reviseur lit, entre crochets et avec ses accents : [Rôle], [État] ;
--   2. une mesure ne lit que des colonnes techniques, en minuscules et sans accent : role_code, a_designer.
-- Avec cette regle, renommer un libelle ne touche aucune mesure. [Titre equipe] lit a_designer ; [Alerte equipe]
-- lit cumul_a_signaler, a_designer et sans_connexion ; [Fond alerte equipe] lit [Alerte equipe].

CREATE VIEW dbo.v_ecran_equipe_mission AS
WITH roles_attendus AS (
    SELECT r.code, r.ordre
      FROM dbo.ref_role r
     WHERE r.code IN ('ASSOCIE', 'CHEF_MISSION', 'PREPARATEUR')
),
vivant AS (
    SELECT m.entite, m.role, m.personne, m.connexion, m.du, m.pose_par, m.pose_le,
           ROW_NUMBER() OVER (PARTITION BY m.entite, m.role ORDER BY m.du DESC) AS rang
      FROM dbo.role_mission m
     WHERE m.au IS NULL
)
SELECT e.code                                              AS entite,
       ra.code                                             AS role_code,
       -- colonnes d'AFFICHAGE : leur nom EST l'en-tete lu par le reviseur
       CASE ra.code WHEN 'ASSOCIE'      THEN N'Associé signataire'
                    WHEN 'CHEF_MISSION' THEN N'Chef de mission'
                    WHEN 'PREPARATEUR'  THEN N'Collaborateur'
                    ELSE ra.code END                       AS [Rôle],
       ISNULL(v.personne, N'Non désigné')                  AS [Personne],
       CAST(v.du AS DATE)                                  AS [Depuis],
       CASE WHEN v.personne IS NULL THEN N'à désigner'
            WHEN v.connexion IS NULL THEN N'sans connexion'
            ELSE N'désigné' END                            AS [État],
       -- colonnes TECHNIQUES : lues par les mesures, jamais affichees, jamais renommees
       v.connexion                                         AS connexion,
       CAST(CASE WHEN v.personne IS NULL THEN 1 ELSE 0 END AS BIT)                          AS a_designer,
       CAST(CASE WHEN v.personne IS NOT NULL AND v.connexion IS NULL THEN 1 ELSE 0 END AS BIT) AS sans_connexion,
       CAST(CASE WHEN v.connexion IS NOT NULL AND ra.code IN ('ASSOCIE', 'CHEF_MISSION') AND EXISTS (
                     SELECT 1 FROM vivant a
                      WHERE a.entite = e.code AND a.rang = 1 AND a.role <> ra.code
                        AND a.connexion = v.connexion AND a.role IN ('ASSOCIE', 'CHEF_MISSION'))
                 THEN 1 ELSE 0 END AS BIT)                 AS cumul_a_signaler,
       v.pose_par                                          AS designe_par,
       v.pose_le                                           AS designe_le,
       ra.ordre                                            AS ordre,
       e.code + '|' + ra.code                              AS cle_ecran
FROM dbo.ref_entite e
CROSS JOIN roles_attendus ra
LEFT JOIN vivant v ON v.entite = e.code AND v.role = ra.code AND v.rang = 1
WHERE e.est_client = 1;

GO

