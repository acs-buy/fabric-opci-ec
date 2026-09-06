
-- --- 6 : O31, tranche le 06/09/2026 ---------------------------------
-- LA PRODUCTION D'UN DOCUMENT N'EST PAS UN OBJET VISABLE. Arbitrage du
-- candidat : produire un document est un GESTE DE TRAVAIL, non une
-- decision. Trois motifs le fondent.
--   1. Ce qui engage le cabinet est deja vise ailleurs. La synthese
--      porte le visa de l'associe, l'attestation porte sa signature, et
--      les lots qui alimentent l'annexe portent celui du chef de
--      mission. Viser en plus la production reviendrait a viser une
--      seconde fois le meme contenu.
--   2. L'annexe se produit plusieurs fois au cours d'un arrete. Un visa
--      par version transformerait un geste courant en formalite.
--   3. La tracabilite est assuree sans visa : dbo.demande_document porte
--      qui a demande, quand, avec quelle version, et le refus motive le
--      cas echeant.
--
-- CE QUE LA DECISION N'AUTORISE PAS. Elle ne dispense d'aucun verrou :
-- pr_demander_document refuse toujours a qui ne tient aucun role sur
-- l'entite, et refuse une annexe incomplete au modele impose. Le controle
-- C89 nomme toute nature de visa qui viendrait porter la production, de
-- sorte qu'un retour en arriere se voie.
CREATE   VIEW dbo.v_controle_visa_de_production AS
SELECT v.role_code, v.nature,
       N'une nature de visa porte la production d''un document, alors que l''arbitrage du 06/09/2026 en fait un geste de travail et non une décision : rouvrir le point O31 avant de la conserver'
                                                    AS lecture
FROM dbo.v_role_nature_visa v
WHERE v.nature IN ('PRODUCTION', 'DOCUMENT', 'ANNEXE');

GO

