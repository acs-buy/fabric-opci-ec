CREATE   VIEW dbo.v_controle_actif_sans_valeur AS
SELECT a.code AS code_actif, a.entite_detentrice AS entite, a.nature,
       r.arrete, r.date_arrete, r.nature_technique,
       rf.citation_courte AS reference
FROM dbo.actif a
JOIN dbo.ref_nature_actif n ON n.nature = a.nature
LEFT JOIN dbo.v_reference rf ON rf.id = n.reference_id
-- FILTRE CORRIGE le 04/09/2026. La vue filtrait sur
-- nature_technique = 'MISSION', or UN SEUL arrete sur 31 porte cette
-- nature dans le jeu, celui de OMEGA-OPCI au 31/12/2025 : les 12 filiales
-- n'en ont aucun, et la vue rendait 0 ligne. Son zero etait un FAUX ZERO,
-- le controle ne portant sur rien. Le filtre retenu est porte_balance = 1,
-- qui designe les arretes reellement comptabilises.
JOIN dbo.ref_arrete r ON r.entite = a.entite_detentrice AND r.porte_balance = 1
WHERE (a.date_acquisition IS NULL OR a.date_acquisition <= r.date_arrete)
  AND a.code NOT LIKE 'IR4%'
  -- LE PREMIER ARRETE DE CHAQUE ENTITE EST EXCLU, et voici le fait qui
  -- l'exige. Le filtre sur nature_technique = 'MISSION' masquait le
  -- probleme en ne laissant qu'un arrete sur 31 ; corrige, le controle a
  -- rendu 15 actifs sans valeur, TOUS a l'arrete 2023-12-31 : 3 immeubles
  -- en direct, 11 titres de filiales et 1 immeuble de OMEGA-SCI-1. Cet
  -- arrete est le comparatif d'ouverture du dossier, il ne porte que
  -- 5 ecritures et aucune expertise, les premieres etant du 31/12/2024.
  -- Un arrete d'ouverture ne valorise rien : l'y exiger serait reprocher
  -- au dossier de ne pas avoir de passe.
  AND r.date_arrete > (SELECT MIN(r2.date_arrete) FROM dbo.ref_arrete r2
                       WHERE r2.entite = r.entite AND r2.porte_balance = 1)
  AND NOT EXISTS (SELECT 1 FROM dbo.v_patrimoine_valorise p
                  WHERE p.code_actif = a.code AND p.entite = r.entite
                    AND p.arrete = r.arrete);

GO

