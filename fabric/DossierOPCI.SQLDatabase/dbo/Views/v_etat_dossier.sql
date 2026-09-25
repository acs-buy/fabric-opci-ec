-- 172 -- Les arretes ouverts, 2 colonnes qui comptaient tout
-- 13/09/2026. Trouve en preparant la maquette de l'ecran 1.1, en rapprochant 2 sources qui
-- devaient dire la meme chose : v_etat_dossier annonce 5 arretes ouverts pour OMEGA-OPCI quand
-- v_arrete_statut n'en donne qu'UN seul, celui du 30/06/2026, les 4 autres etant CLOS.
-- Les 2 colonnes comptaient sur arrete_mission sans filtrer le statut. Leur nom et leur libelle
-- d'ecran, « Nombre d'arretes ouverts pour l'entite », annoncaient autre chose.
-- C'est le 4e defaut du meme genre en 2 jours : un terme dont le nom promet une population et
-- dont le calcul en prend une autre. Celui-ci s'affichait sur le tableau de bord de Client.
-- 165 -- Les questions d'acceptation, numerateur et denominateur remis sur la meme population
-- 12/09/2026. Defaut trouve avant qu'il n'atteigne un ecran, l'agent Fabric IQ s'appretant a
-- afficher « 110 / 92 » sur la ligne OMEGA-OPCI du tableau de bord de Client.
-- MESURE QUI L'ETABLIT : ref_question porte 92 questions obligatoires et 18 facultatives en phase
-- ACCEPT, soit 110 ; v_questions_du_cycle porte 110 lignes en phase ACCEPT, toutes REPONDUE et
-- toutes sur la seule entite OMEGA-OPCI. Le taux reel de cette entite est donc 100 %, non 120 %.
-- C'est la faute que notre propre controle C84 denonce, un numerateur et un denominateur pris sur
-- 2 populations differentes, et que j'ai commise le 09/09 sur un ecart de 28 291 330,67.
-- CE QUI NE CHANGE PAS, l'agent posant sur cette vue en lecture directe : les 2 colonnes gardent
-- leur nom, leur type entier et leur rang. Aucune resynchronisation du modele n'est requise.
-- --- 6 : V4, l'etat du dossier et le prochain arrete -----------------
-- dbo.v_prerequis_arrete ne couvre que la porte 1, et seulement les
-- arretes deja presents dans les lots ou les detentions : elle ne dit
-- rien de l'acceptation, du maintien, ni d'un arrete jamais ouvert.
-- L'ecran C0 a besoin de l'etat du dossier ET du motif du refus a venir.
CREATE VIEW dbo.v_etat_dossier AS
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
       -- ARRETES OUVERTS, RECTIFIE LE 13/09/2026. Ces 2 colonnes portaient le mot OUVERT dans
       -- leur nom et comptaient TOUS les arretes, clos compris. OMEGA-OPCI en porte 5, dont
       -- 4 CLOS et 1 seul OUVERT, celui du 30/06/2026 : la carte du tableau de bord affichait
       -- donc 5 arretes ouverts. Le statut se lit dans v_arrete_statut, qui le tire d'un visa de
       -- nature CLOTURE ; aucune circularite, cette vue lit arrete_mission et non celle-ci.
       -- Les noms de colonne ne changent pas, donc aucune resynchronisation du modele.
       (SELECT COUNT(*) FROM dbo.v_arrete_statut vs
        WHERE vs.entite = e.code AND vs.statut = 'OUVERT')
                                          AS arretes_ouverts,
       -- Le dernier arrete OUVERT, et non le dernier arrete tout court. Les 2 coincidaient sur le
       -- jeu du jour, ce qui rendait le defaut invisible : le plus recent se trouvait etre le seul
       -- ouvert. Rien ne garantit que cela dure.
       (SELECT MAX(vs.arrete) FROM dbo.v_arrete_statut vs
        WHERE vs.entite = e.code AND vs.statut = 'OUVERT')
                                          AS dernier_arrete_ouvert,
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
       -- LES QUESTIONS D'ACCEPTATION, RECTIFIEES LE 12/09/2026.
       -- Les 2 compteurs ne portaient pas sur la meme population. Le numerateur comptait TOUTES
       -- les questions repondues de l'entite, obligatoires ou non ; le denominateur comptait les
       -- MODELES obligatoires du referentiel, sans lien a l'entite, d'ou le meme 92 partout.
       -- L'entite OMEGA-OPCI affichait ainsi 110 sur 92, soit 120 %, alors qu'elle avait repondu
       -- a la totalite de ses 110 questions, 92 obligatoires et 18 facultatives. Et les
       -- 15 filiales affichaient 0 sur 92 alors qu'AUCUNE ligne de questionnaire n'y est posee :
       -- l'ecran leur imputait un retard la ou il n'y a pas d'obligation, et un chef de mission
       -- qui triait par ce rapport ouvrait 15 dossiers pour rien.
       -- Les 2 compteurs portent desormais sur les questions OBLIGATOIRES POSEES A L'ENTITE, et
       -- ils rendent NULL quand aucune ne l'est, un tiret valant mieux qu'un zero accusateur.
       (SELECT CASE WHEN COUNT(*) = 0 THEN NULL
                    ELSE SUM(CASE WHEN v.etat_ligne = 'REPONDUE' THEN 1 ELSE 0 END) END
        FROM dbo.v_questions_du_cycle v
        WHERE v.entite = e.code AND v.phase = 'ACCEPT'
          AND v.obligatoire = 1)           AS acceptation_questions_repondues,
       (SELECT NULLIF(COUNT(*), 0) FROM dbo.v_questions_du_cycle v
        WHERE v.entite = e.code AND v.phase = 'ACCEPT'
          AND v.obligatoire = 1)           AS acceptation_questions_dues
FROM dbo.ref_entite e
LEFT JOIN dbo.acceptation_mission ac ON ac.entite = e.code
OUTER APPLY (SELECT TOP 1 m.* FROM dbo.maintien_mission m
             WHERE m.entite = e.code ORDER BY m.arrete_conclu DESC) AS mt
OUTER APPLY (SELECT TOP 1 r.personne FROM dbo.role_mission r
             WHERE r.entite = e.code AND r.role = 'CHEF_MISSION'
               AND r.au IS NULL ORDER BY r.du DESC) AS rm;
;

GO

