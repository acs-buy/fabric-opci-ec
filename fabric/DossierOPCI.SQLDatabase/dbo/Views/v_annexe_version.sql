
-- La derniere version de chaque arrete de mission, et la version validee (contrat, 1.4 et 2.4) : visa.annexe_version du
-- visa de cloture courant ; les cellules imprimees autrement entre les 2 ; les memes pour l'arrete N-1.
CREATE   VIEW dbo.v_annexe_version AS
SELECT e.entite, e.arrete, d.derniere_version, d.cree_le,
       vv.annexe_version AS version_validee,
       CASE WHEN vv.annexe_version IS NOT NULL AND d.derniere_version IS NOT NULL
            THEN (SELECT COUNT(*) FROM dbo.fn_annexe_imprime_autrement(e.entite, e.arrete, vv.annexe_version, d.derniere_version)) END
           AS cellules_differentes_validee,
       e.arrete_n_1 AS n1_arrete,
       n1.cellules_differentes_validee AS n1_cellules_differentes_validee
FROM dbo.v_arrete_etat e
JOIN dbo.ref_arrete r ON r.entite = e.entite AND r.arrete = e.arrete
OUTER APPLY (SELECT TOP (1) av.version AS derniere_version, av.cree_le FROM dbo.annexe_version av
             WHERE av.entite = e.entite AND av.arrete = e.arrete AND av.arrete_cree_le = r.cree_le
             ORDER BY av.version DESC) d
OUTER APPLY (SELECT vi.annexe_version FROM dbo.v_visa_cloture_courant vc JOIN dbo.visa vi ON vi.id = vc.visa_id
             WHERE vc.entite = e.entite AND vc.arrete = e.arrete) vv
OUTER APPLY (SELECT CASE WHEN vi.annexe_version IS NOT NULL AND d1.derniere_version IS NOT NULL
                         THEN (SELECT COUNT(*) FROM dbo.fn_annexe_imprime_autrement(e.entite, e.arrete_n_1, vi.annexe_version, d1.derniere_version)) END
                         AS cellules_differentes_validee
             FROM dbo.v_visa_cloture_courant vc JOIN dbo.visa vi ON vi.id = vc.visa_id
             JOIN dbo.ref_arrete r1 ON r1.entite = e.entite AND r1.arrete = e.arrete_n_1
             OUTER APPLY (SELECT TOP (1) av.version AS derniere_version FROM dbo.annexe_version av
                          WHERE av.entite = e.entite AND av.arrete = e.arrete_n_1 AND av.arrete_cree_le = r1.cree_le
                          ORDER BY av.version DESC) d1
             WHERE vc.entite = e.entite AND vc.arrete = e.arrete_n_1) n1;

GO

