-- 177 -- Le coffre des pieces, filtre par le contexte sans devenir inutilisable
-- 13/09/2026, arbitrage du candidat : « l'affichage des documents du coffre doit suivre le
-- contexte de l'OPCI selectionnee ».
--
-- LA DIFFICULTE, mesuree avant d'ecrire : la table piece ne porte AUCUNE entite. Le lien a un
-- dossier passe uniquement par piece_rattachement. Le coffre porte 98 pieces, dont 67 rattachees
-- et 31 LIBRES, et 52 sont rattachees au groupe OMEGA a l'arrete du 31/12/2025.
-- Un filtre strict sur le contexte ne montrerait donc que 52 pieces et ferait DISPARAITRE les
-- 31 libres. Or c'est precisement celles-la que le reviseur doit voir pour les rattacher : une
-- piece qu'on vient de deposer au coffre n'est rattachee a rien. Le filtre aurait rendu l'ecran de
-- rattachement inutilisable.
--
-- LA REGLE RETENUE, qui est celle d'un coffre de cabinet : une piece se voit si elle est rattachee
-- au dossier regarde, OU si elle n'est rattachee a rien. Une piece rattachee a un AUTRE dossier ne
-- se voit pas, ce qui est le but de l'arbitrage. Une piece libre reste a disposition de tous.
CREATE   VIEW dbo.v_ctx_piece_du_coffre AS
SELECT t.*,
       etat_rattachement = CAST(CASE WHEN EXISTS (SELECT 1 FROM dbo.piece_rattachement r
                                                  WHERE r.piece_id = t.piece_id)
                                     THEN N'Rattachée au dossier' ELSE N'Libre, à rattacher' END
                                AS nvarchar(30))
FROM dbo.v_ecran_piece_du_coffre t
WHERE EXISTS (SELECT 1 FROM dbo.piece_rattachement r
              JOIN dbo.v_mon_perimetre p ON p.entite = r.entite AND p.arrete = r.arrete
              WHERE r.piece_id = t.piece_id)
   OR NOT EXISTS (SELECT 1 FROM dbo.piece_rattachement r WHERE r.piece_id = t.piece_id);

GO

