-- 216. La table des maintiens de la fiche du dossier, en colonnes lisibles.
-- Arbitre le 21/09/2026 : dans un TABLEAU, nativeQueryRef est ignore pour une mesure (releve Fabric IQ) ;
-- l'en-tete d'une colonne se regle au modele, par le nom de l'objet. Une mesure de libelle ne peut donc pas
-- porter un en-tete court sans entrer en conflit avec la colonne brute du meme nom. La 3e voie, deja employee
-- pour v_filiale_dependances (214) et v_ecran_pieces_du_dossier (211) : la VUE rend le libelle en COLONNE.
--
-- Une ligne par maintien, plus la ligne « A faire » du dernier arrete annuel conclu qui n'a pas encore son
-- maintien (source v_maintien_requis) : c'est elle qui porte le bouton « Ouvrir le maintien ».
-- Les codes bruts restent en colonnes (statut_code, decision_code) : les mesures de couleur les lisent.
-- Prerequis : maintien_mission, v_maintien_requis. Rejouable.

CREATE   VIEW dbo.v_ecran_maintiens AS
SELECT m.entite,
       m.arrete_conclu                                       AS exercice,
       CASE m.statut WHEN 'APPROUVE' THEN N'Approuvé'
                     WHEN 'OUVERT'   THEN N'Soumis au visa'
                     WHEN 'REFUSE'   THEN N'Refusé'
                     ELSE m.statut END                       AS statut,
       m.statut                                              AS statut_code,
       CASE m.decision WHEN 'MAINTENU'     THEN N'Maintenu'
                       WHEN 'NON_MAINTENU' THEN N'Non maintenu'
                       WHEN 'EN_ATTENTE'   THEN N'En attente'
                       ELSE m.decision END                   AS decision,
       m.approuve_par                                        AS vise_par,
       CAST(m.approuve_le AS DATETIME2 (0))                  AS vise_le,
       m.cote_questionnaire,
       m.motif,
       CAST(0 AS BIT)                                        AS a_faire,
       m.entite + '|' + m.arrete_conclu                      AS cle_ecran
FROM dbo.maintien_mission m
UNION ALL
SELECT r.entite,
       r.dernier_arrete_annuel,
       N'À faire',
       'A_FAIRE',
       N'à la conclusion de l''arrêté',
       CAST(NULL AS NVARCHAR (400)),
       CAST(NULL AS DATETIME2 (0)),
       CAST(NULL AS VARCHAR (30)),
       CAST(NULL AS NVARCHAR (800)),
       CAST(1 AS BIT),
       r.entite + '|' + r.dernier_arrete_annuel + '|AF'
FROM dbo.v_maintien_requis r
WHERE r.statut_maintien IS NULL;

GO

