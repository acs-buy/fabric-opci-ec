
-- --- 7 : le verrou de classe, K7 --------------------------------------
-- Un compte d'entite rattache a un compte modele est de la meme classe :
-- rattacher un compte de charges a un compte d'immobilisation ferait
-- lire une charge comme un actif.
CREATE   VIEW dbo.v_controle_classe_rattachement AS
SELECT r.entite, r.compte_entite, r.compte_modele,
       LEFT(r.compte_entite, 1) AS classe_entite,
       LEFT(r.compte_modele, 1) AS classe_modele
FROM dbo.ref_compte_entite r
-- CORRIGE le 04/09/2026 : la vue refusait tout changement de classe, ce
-- qui comptait 36 rattachements du PCG comme fautifs. Les 2 plans ne
-- partagent pas la structure de leurs classes, le PCG mettant les comptes
-- courants d'associes en classe 4 la ou le plan de l'article 411-3 met
-- les emprunts en classe 5. La vue exclut donc les correspondances
-- declarees dans dbo.ref_correspondance_plan, posee par le script 92.
WHERE LEFT(r.compte_entite, 1) <> LEFT(r.compte_modele, 1)
  AND r.compte_entite <> r.compte_modele
  AND NOT EXISTS (SELECT 1 FROM dbo.ref_correspondance_plan c
                  WHERE c.compte_source = r.compte_entite
                    AND c.compte_modele = r.compte_modele);

GO

