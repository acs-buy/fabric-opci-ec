
-- Le prochain arrete ouvrable par entite, et ce qui empeche de l'ouvrir.
-- L'ecran C0 affiche le motif AVANT le clic : un bouton grise sans motif
-- laisse le preparateur sans geste.
CREATE   VIEW dbo.v_prochain_arrete AS
WITH suivant AS (
    SELECT r.entite, r.arrete, r.type_arrete, r.exercice, r.date_arrete,
           ROW_NUMBER() OVER (PARTITION BY r.entite ORDER BY r.arrete) AS rang
    FROM dbo.ref_arrete r
    WHERE r.nature_technique = 'MISSION'
      AND NOT EXISTS (SELECT 1 FROM dbo.arrete_mission am
                      WHERE am.entite = r.entite AND am.arrete = r.arrete)
)
SELECT s.entite, s.arrete, s.type_arrete,
       n.libelle                          AS nature_libelle,
       s.exercice, s.date_arrete,
       d.acceptation_statut, d.acceptation_decision, d.maintien_statut,
       d.arretes_ouverts,
       -- Les prerequis SUR L'ARRETE VISE, non sur le dernier ouvert :
       -- c'est lui qui conditionne l'ouverture.
       x.exp_manq                         AS expertises_manquantes,
       x.bal_manq                         AS balances_filiales_manquantes,
       -- Le motif du refus a venir. L'ordre des tests est celui des
       -- portes : l'acceptation d'abord, elle conditionne tout le reste ;
       -- puis le maintien, exige a partir du second exercice ; puis les
       -- prerequis techniques de la porte 1.
       CASE
         WHEN d.acceptation_statut <> 'APPROUVE'
           THEN N'L''acceptation de la mission n''est pas approuvée pour '
                + N'cette entité. Répondre au questionnaire d''acceptation, '
                + N'puis faire approuver la décision par l''associé.'
         WHEN d.acceptation_decision <> 'ACCEPTEE'
           THEN N'La décision d''acceptation portée au dossier n''est pas '
                + N'« acceptée ». Reprendre la décision avant d''ouvrir un '
                + N'arrêté.'
         WHEN d.arretes_ouverts > 0 AND d.maintien_statut <> 'APPROUVE'
           THEN N'Le maintien de la mission n''est pas approuvé alors qu''un '
                + N'exercice a déjà été ouvert. Répondre au questionnaire de '
                + N'maintien, puis faire approuver la décision.'
         WHEN x.exp_manq > 0
           THEN N'Il manque ' + CAST(x.exp_manq AS NVARCHAR (10))
                + N' rapport(s) d''évaluateur à la date de cet arrêté. '
                + N'Déposer les rapports au coffre et les rattacher.'
         WHEN x.bal_manq > 0
           THEN N'Il manque ' + CAST(x.bal_manq AS NVARCHAR (10))
                + N' balance(s) de filiale pour cet arrêté. Charger les '
                + N'balances avant d''ouvrir.'
         ELSE NULL
       END                                AS motif_du_refus,
       CAST(CASE WHEN d.acceptation_statut = 'APPROUVE'
                  AND d.acceptation_decision = 'ACCEPTEE'
                  AND (d.arretes_ouverts = 0 OR d.maintien_statut = 'APPROUVE')
                  AND x.exp_manq = 0
                  AND x.bal_manq = 0
                 THEN 1 ELSE 0 END AS BIT) AS ouvrable
FROM suivant s
JOIN dbo.v_etat_dossier d ON d.entite = s.entite
LEFT JOIN dbo.ref_nature_arrete n ON n.code = s.type_arrete
CROSS APPLY (
    SELECT COUNT(CASE WHEN p.manquant = 'EXPERTISE_MANQUANTE' THEN 1 END)
               AS exp_manq,
           COUNT(CASE WHEN p.manquant = 'BALANCE_FILIALE_MANQUANTE' THEN 1 END)
               AS bal_manq
    FROM dbo.v_prerequis_arrete p
    WHERE p.entite = s.entite AND p.arrete = s.arrete
) AS x
WHERE s.rang = 1;

GO

