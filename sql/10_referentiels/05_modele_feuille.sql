-- modele_feuille : 24 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[modele_feuille])
BEGIN
    INSERT INTO dbo.[modele_feuille] ([code], [libelle], [standard], [nom_fichier], [chemin_coffre], [empreinte_sha256], [version], [en_vigueur_depuis], [modifie_par], [modifie_le]) VALUES
        (N'AFF-DISTRIB',N'Sommes distribuables par catégorie et suivi de l''obligation de distribution',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'CAP-FRAIS',N'Suivi des frais d''acquisition par actif détenu, en compte de capital',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'CAP-PARTS',N'Parts en circulation rapprochées du registre des porteurs et de l''attestation du dépositaire',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'CESS-PMV',N'Calcul des plus et moins-values de cession, actif par actif, nettes des frais',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'COHER-VARIAT',N'Revue de cohérence pluriannuelle et explication écrite des variations',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'COMPTES-CARACT',N'Éléments caractéristiques de l''OPCI sur les cinq derniers exercices',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'FIN-INVENT',N'Inventaire détaillé des dépôts et instruments financiers non immobiliers',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'FRAIS-SURPERF',N'Calcul de la commission de surperformance de l''exercice',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'HB-ENGAGE',N'Recensement des engagements donnés et reçus, rapproché des contrats et des actes',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'IMMO-CBAIL',N'Évaluation du droit du crédit-preneur et suivi des redevances restant à payer',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'IMMO-EXPERTISE',N'Valeur actuelle des immeubles, terrains et droits réels, rapprochée du rapport d''expertise',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'IMMO-LOYERS',N'Dépouillement des baux en vigueur, rapproché du produit de loyers comptabilisé',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'IMMO-RENTE',N'Bien acquis moyennant paiement de rentes viagères, dette constatée et arrérages versés',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'PART-ANR',N'Actif net réévalué des entités détenues et quote-part de détention retenue',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'PART-CC',N'Avances en compte courant dans les filiales, intérêts courus et soldes réciproques',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'PERM-PLANCPT',N'Rapprochement du plan de comptes de l''OPCI au modèle du règlement',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'PLANIF-SELECT',N'Sélection des cycles applicables à partir des postes du bilan servis à l''arrêté',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'STD',N'Feuille de travail standard',N'1',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'SYN-RAPPRO',N'Rapprochement du bilan et du compte de résultat produits à la balance générale',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'TIERS-AGEE',N'Balance âgée des créances locataires et détermination des dépréciations',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'TRESO-EMPRUNTS',N'Échéancier des emprunts, charge financière de la période et confirmation du prêteur',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'TRESO-RAPPRO',N'État de rapprochement bancaire et justification des opérations non dénouées',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'VALO-ECARTS',N'Différences d''estimation par actif, écart de la valeur actuelle au coût d''acquisition',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL),
        (N'VALO-VL',N'Calcul de la valeur liquidative et rapprochement de l''actif net aux capitaux propres',N'0',NULL,NULL,NULL,N'1.0',N'2026-08-23',NULL,NULL);
    PRINT 'modele_feuille : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'modele_feuille : deja chargee, rien a faire.';
GO
