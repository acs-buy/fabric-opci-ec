-- 182 -- Les 3 vues que la cle primaire ne sauve pas recoivent une cle_ecran
-- 13/09/2026. Suite du script 181. Sur 73 vues lisibles par une grille, 52 portaient deja
-- cle_ecran, 17 recoivent la cle primaire de leur table, 1 sa colonne de regroupement, et 3
-- restaient sans cle parce que leur table a une cle primaire de 2 colonnes :
--   feuille_question    (cote varchar, question_id int)   lue par v_ctx_feuille_question
--                                                          et par v_ecran_c11_questions
--   ref_compte_entite   (entite varchar, compte_entite varchar)
--
-- Le service refuse de servir les lignes d'une grille sans colonne identifiante, HTTP 400,
-- « There is no primary key column detected in source table or column configuration ».
-- Une cle COMPOSITE n'a pas ete eprouvee : ces 3 vues recoivent donc la solution deja employee
-- 52 fois dans ce projet, une colonne cle_ecran qui concatene les composantes.
--
-- FORME DE LA CLE, reprise du script 144 sans y rien changer : les composantes converties en
-- nvarchar(200), le NULL rendu par une chaine vide, et le separateur barre verticale.
-- CONSEQUENCE A CONNAITRE, ET ELLE A DEJA COUTE : la barre verticale interdit d'employer le pipe
-- comme separateur de sqlcmd sur ces vues. Le projet emploie le tilde partout pour cette raison.
--
-- PREVENU AVANT LA POSE : ces 3 vues gagnent une colonne. Une feuille PowerTable deja posee sur
-- l'une d'elles affichera « Database schema changes detected » tant que ses colonnes ne sont pas
-- resynchronisees. Au 13/09/2026 aucune des 3 n'est lue par une feuille posee, mais la regle
-- vaut pour la prochaine fois : on annonce un changement de colonnes avant de l'ecrire.

CREATE   VIEW dbo.v_ctx_feuille_question AS
SELECT ISNULL(CONVERT(nvarchar(200), t.cote), N'') + N'|'
     + ISNULL(CONVERT(nvarchar(200), t.question_id), N'') AS cle_ecran,
       t.*
FROM dbo.feuille_question t
WHERE EXISTS (SELECT 1 FROM dbo.feuille_travail f
              JOIN dbo.v_mon_perimetre p ON p.entite = f.entite AND p.arrete = f.arrete
              WHERE f.cote = t.cote);

GO

