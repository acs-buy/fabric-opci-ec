

-- --- 6 : V4, l'etat du dossier et le prochain arrete -----------------
-- dbo.v_prerequis_arrete ne couvre que la porte 1, et seulement les
-- arretes deja presents dans les lots ou les detentions : elle ne dit
-- rien de l'acceptation, du maintien, ni d'un arrete jamais ouvert.
-- L'ecran C0 a besoin de l'etat du dossier ET du motif du refus a venir.
CREATE   VIEW dbo.v_etat_dossier AS
SELECT e.code                             AS entite,
       e.denomination                     AS entite_libelle,
       -- L'acceptation. Une entite sans ligne n'est pas refusee : elle
       -- n'est pas encore proposee, ce qui n'est pas la meme chose.
       COALESCE(ac.statut, 'ABSENTE')     AS acceptation_statut,
       ac.decision                        AS acceptation_decision,
       ac.approuve_par                    AS acceptation_approuvee_par,
       ac.approuve_le                      AS acceptation_approuvee_le,
       -- Le maintien du dernier exercice conclu.
       mt.arrete_conclu                   AS maintien_exercice,
       COALESCE(mt.statut, 'ABSENT')      AS maintien_statut,
       mt.decision                        AS maintien_decision,
       -- Le chef de mission en fonction, lu de dbo.role_mission.
       rm.personne                        AS chef_de_mission,
       -- Le dossier de travail.
       (SELECT COUNT(*) FROM dbo.arrete_mission am WHERE am.entite = e.code)
                                          AS arretes_ouverts,
       (SELECT MAX(am.arrete) FROM dbo.arrete_mission am
        WHERE am.entite = e.code)         AS dernier_arrete_ouvert,
       (SELECT COUNT(*) FROM dbo.feuille_travail f WHERE f.entite = e.code)
                                          AS feuilles,
       (SELECT COUNT(*) FROM dbo.feuille_travail f
        WHERE f.entite = e.code AND f.forme_conclusion IS NOT NULL)
                                          AS feuilles_conclues,
       -- Les 2 prerequis de la porte 1, RAPPORTES AU DERNIER ARRETE
       -- OUVERT. Le total sur tous les arretes n'est pas lisible :
       -- dbo.v_prerequis_arrete croise chaque actif avec chaque arrete
       -- porteur de lot, et rendait 81 expertises manquantes pour
       -- l'OPCI, mesure le 04/09/2026, dont la plus grande part porte
       -- sur des arretes que personne n'ouvrira.
       (SELECT COUNT(*) FROM dbo.v_prerequis_arrete p
        WHERE p.entite = e.code AND p.manquant = 'EXPERTISE_MANQUANTE'
          AND p.arrete = (SELECT MAX(am.arrete) FROM dbo.arrete_mission am
                          WHERE am.entite = e.code))
                                          AS expertises_manquantes,
       (SELECT COUNT(*) FROM dbo.v_prerequis_arrete p
        WHERE p.entite = e.code AND p.manquant = 'BALANCE_FILIALE_MANQUANTE'
          AND p.arrete = (SELECT MAX(am.arrete) FROM dbo.arrete_mission am
                          WHERE am.entite = e.code))
                                          AS balances_filiales_manquantes,
       -- Les questions de mission repondues, sur celles qui sont dues.
       (SELECT COUNT(*) FROM dbo.v_questions_du_cycle v
        WHERE v.entite = e.code AND v.phase = 'ACCEPT'
          AND v.etat_ligne = 'REPONDUE')   AS acceptation_questions_repondues,
       (SELECT COUNT(*) FROM dbo.ref_question q
        WHERE q.phase = 'ACCEPT' AND q.obligatoire = 1)
                                          AS acceptation_questions_dues
FROM dbo.ref_entite e
LEFT JOIN dbo.acceptation_mission ac ON ac.entite = e.code
OUTER APPLY (SELECT TOP 1 m.* FROM dbo.maintien_mission m
             WHERE m.entite = e.code ORDER BY m.arrete_conclu DESC) AS mt
OUTER APPLY (SELECT TOP 1 r.personne FROM dbo.role_mission r
             WHERE r.entite = e.code AND r.role = 'CHEF_MISSION'
               AND r.au IS NULL ORDER BY r.du DESC) AS rm;

GO

