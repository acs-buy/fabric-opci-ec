-- 199 : une seule table de differences, pour que le segment de famille commande UNE table.
--
-- MOTIF, et c'est une regle de conception de la V2 : « le detail se choisit, il ne s'empile pas ».
-- L'ecran 3.2 de la V1 empilait 4 grilles, une par famille, sur 1052 px avec ascenseur. Le rapport
-- V2 porte un segment de famille et une seule table. Sans cette vue, le segment ne commanderait
-- rien : il faudrait 4 visuels superposes et des signets, ce qui est le meme empilement deguise.
--
-- CE QUI REND L'UNION LEGITIME, verifie le 15/09/2026 : les 4 vues portent EXACTEMENT 17 colonnes
-- chacune, les memes, et chacune porte deja sa colonne famille. L'union n'invente aucune colonne
-- et ne renomme rien.
--
-- CE QUE CETTE VUE NE FAIT PAS : elle ne filtre pas par l'utilisateur connecte. C'est voulu. Un
-- rapport ne lit jamais une vue de contexte, le modele s'y connectant sous identite fixe ; le
-- filtrage vient de la regle de securite du modele et des segments de la page. Cf.
-- 61_DEPLOIEMENT/regle_de_securite_v2.md, paragraphe 7.
--
-- REJOUABLE : CREATE OR ALTER, aucune ecriture de donnee, aucune suppression.

CREATE   VIEW dbo.v_differences_detail AS
SELECT entite, arrete, exercice, code_actif, nature, poste_bilan, famille,
       valeur_comptable, valeur_actuelle, difference_estimation, source,
       article, norme, reference, citation_courte, entite_liee, quote_part
FROM dbo.v_differences_immeubles
UNION ALL
SELECT entite, arrete, exercice, code_actif, nature, poste_bilan, famille,
       valeur_comptable, valeur_actuelle, difference_estimation, source,
       article, norme, reference, citation_courte, entite_liee, quote_part
FROM dbo.v_differences_titres
UNION ALL
SELECT entite, arrete, exercice, code_actif, nature, poste_bilan, famille,
       valeur_comptable, valeur_actuelle, difference_estimation, source,
       article, norme, reference, citation_courte, entite_liee, quote_part
FROM dbo.v_differences_comptes_courants
UNION ALL
SELECT entite, arrete, exercice, code_actif, nature, poste_bilan, famille,
       valeur_comptable, valeur_actuelle, difference_estimation, source,
       article, norme, reference, citation_courte, entite_liee, quote_part
FROM dbo.v_differences_instruments;

GO

