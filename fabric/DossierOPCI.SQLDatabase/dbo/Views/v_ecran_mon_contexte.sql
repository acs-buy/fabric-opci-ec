
CREATE   VIEW dbo.v_ecran_mon_contexte AS
SELECT c.utilisateur,
       c.vehicule,
       c.arrete,
       -- modifie_le RETIRE de la grille le 13/09/2026, choix (a) de l'agent Fabric IQ.
       -- Motif : la colonne porte un DEFAULT, qui ne joue qu'a l'INSERTION. Apres une
       -- modification par la grille, elle affichait encore l'heure de la creation de la
       -- ligne. Aucun declencheur AFTER UPDATE n'a ete pose, et je n'ai PAS verifie que la
       -- base SQL Fabric en accepte. Une colonne qui ment est pire qu'une colonne absente.
       -- Elle reste dans la TABLE, ou elle date la creation du contexte sans rien affirmer
       -- de plus ; elle sort seulement de la grille.
       -- Le message dit au reviseur POURQUOI ses grilles sont vides, au lieu de le laisser deviner.
       CASE
           WHEN c.vehicule IS NULL OR c.arrete IS NULL
               THEN N'Choisissez un vehicule et une date d''arrete : les grilles du dessous sont '
                    + N'vides tant que les 2 ne sont pas renseignes.'
           WHEN NOT EXISTS (SELECT 1 FROM dbo.v_perimetre_groupe g WHERE g.vehicule = c.vehicule)
               THEN N'« ' + c.vehicule + N' » n''est pas un vehicule, c''est une entite detenue. '
                    + N'Les vehicules ouverts sont : '
                    + STUFF((SELECT N', ' + v.vehicule FROM dbo.v_ecran_vehicules_ouverts v
                             ORDER BY v.vehicule FOR XML PATH(''), TYPE)
                            .value('.', 'nvarchar(400)'), 1, 2, N'')
           WHEN NOT EXISTS (SELECT 1 FROM dbo.v_arrete_statut a
                            WHERE a.entite = c.vehicule AND a.arrete = c.arrete)
               THEN N'Aucun arrete du ' + CONVERT(nvarchar(10), c.arrete, 103)
                    + N' n''existe pour ' + c.vehicule + N'.'
           WHEN EXISTS (SELECT 1 FROM dbo.v_arrete_statut a
                        WHERE a.entite = c.vehicule AND a.arrete = c.arrete AND a.statut <> 'OUVERT')
               -- 13/09/2026 : ce message dit le STATUT, il n'annonce aucune consequence. La premiere
               -- redaction affirmait « les grilles sont en lecture », ce qui est FAUX : une vue de
               -- contexte reste saisissable quel que soit le statut de l'arrete. Aucun verrou n'est
               -- pose a ce jour sur la saisie d'un arrete clos, et l'ecrire aurait fait croire le
               -- contraire au reviseur.
               THEN N'Dossier ' + c.vehicule + N', arrete du '
                    + CONVERT(nvarchar(10), c.arrete, 103) + N', statut '
                    + (SELECT TOP 1 a.statut FROM dbo.v_arrete_statut a
                       WHERE a.entite = c.vehicule AND a.arrete = c.arrete)
                    + N'. Le seul arrete OUVERT de ce vehicule est le '
                    + ISNULL((SELECT TOP 1 CONVERT(nvarchar(10), CAST(a.arrete AS date), 103)
                              FROM dbo.v_arrete_statut a
                              WHERE a.entite = c.vehicule AND a.statut = 'OUVERT'
                              ORDER BY a.arrete DESC), N'(aucun)') + N'.'
           ELSE N'Dossier ' + c.vehicule + N', arrete du ' + CONVERT(nvarchar(10), c.arrete, 103)
                + N', ouvert. '
                + CAST((SELECT COUNT(*) FROM dbo.v_perimetre_groupe g WHERE g.vehicule = c.vehicule)
                       AS nvarchar(10))
                + N' entites dans le perimetre.'
       END AS message_ecran
FROM dbo.contexte_reviseur c
WHERE c.utilisateur = SESSION_USER;

GO

