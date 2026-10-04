-- ref_forme_rapport : 31 ligne(s) de referentiel.
-- Rejouable : la table ne se remplit que si elle est vide. Rien n'est efface.
-- Produit depuis la base de reference, ne pas modifier a la main.

IF NOT EXISTS (SELECT 1 FROM dbo.[ref_forme_rapport])
BEGIN
    INSERT INTO dbo.[ref_forme_rapport] ([code], [exemple], [page_np], [libelle], [intitule], [attestation], [fondement], [texte], [ordre], [modifie_par], [modifie_le]) VALUES
        (N'AVEC_OBSERVATION',N'E2',N'15',N'Attestation avec conclusion favorable mais avec observation(s) ayant une incidence sur la cohérence et la vraisemblance des comptes pris dans leur ensemble (désaccords, incertitudes, limitations)',N'ATTESTATION DE PRESENTATION DES COMPTES',N'1',N'NP 2300, § 20, exemple E2',N'En notre qualité d’expert-comptable et conformément aux termes de notre lettre de mission, nous avons effectué une mission de présentation des comptes … (préciser « annuels », « intermédiaires ») de … (préciser l’entité concernée) relatifs à … (préciser la période ou l’exercice concerné), qui se caractérisent par les données suivantes :,
        · Total du bilan ;,
        · Chiffre d’affaires ;,
        · Résultat net comptable.,
        Nos diligences ont été réalisées conformément à la norme professionnelle de l’Ordre des experts-comptables applicable à la mission de présentation des comptes qui ne constitue ni un examen limité ni un audit.,
        Nous formulons une (des) observations(s) sur le(s) point(s) suivant(s) susceptible(s) d’affecter la cohérence et la vraisemblance des comptes :,
        (Description motivée et chiffrée des désaccords, incertitudes ou limitations faisant l’objet de l’ (des) observation(s)),
        Sur la base de nos travaux, et sous réserve de l’incidence de l’ (des) observation(s) décrite(s) dans le paragraphe ci-dessus, nous n’avons pas relevé d’éléments remettant en cause la cohérence et la vraisemblance des comptes annuels (ou intermédiaires) pris dans leur ensemble tels qu’ils sont joints à la présente attestation.,
        Lieu, date et signature',N'3',NULL,NULL),
        (N'COMPTE_RENDU_TRAVAUX',N'E4',N'17',N'Compte rendu de travaux utilisable lorsque l’entité est soumise au commissariat aux comptes',N'COMPTE RENDU DE TRAVAUX DE L’EXPERT-COMPTABLE',N'0',N'NP 2300, § A10, exemple E4',N'En notre qualité d’expert-comptable et conformément aux termes de notre lettre de mission en date du …, nous avons effectué une mission de présentation des comptes … (préciser « annuels », « intermédiaires ») de … (préciser l’entité concernée) relatifs à … (préciser la période ou l’exercice concerné) qui se caractérisent par les données suivantes :,
        · Total du bilan ;,
        · Chiffre d’affaires ;,
        · Résultat net comptable.,
        Nous avons effectué les diligences prévues par la norme professionnelle de l’Ordre des experts-comptables applicable à la mission de présentation des comptes.,
        Lieu, date et signature',N'1',NULL,NULL),
        (N'IMPOSSIBILITE',N'E3',N'16',N'Refus d’attester (incohérences, désaccords, incertitudes, limitations)',N'RAPPORT AVEC REFUS D’ATTESTER',N'1',N'NP 2300, § 21, exemple E3',N'En notre qualité d’expert-comptable et conformément aux termes de notre lettre de mission, nous avons effectué une mission de présentation des comptes … (préciser « annuels », « intermédiaires ») de … (préciser l’entité concernée) relatifs à … (préciser la période ou l’exercice concerné), qui se caractérisent par les données suivantes :,
        · Total du bilan ;,
        · Chiffre d’affaires ;,
        · Résultat net comptable.,
        Nos diligences ont été réalisées conformément à la norme professionnelle de l’Ordre des experts-comptables applicable à la mission de présentation des comptes qui ne constitue ni un examen limité ni un audit.,
        Dans le cadre de notre mission, nous avons relevé le(s) point(s) suivant(s) qui a (ont) une incidence significative sur la cohérence et la vraisemblance des comptes :,
        (Description du (des) point(s) relevé(s) et de son (leur) incidence sur les comptes),
        Sur la base de nos travaux, et compte tenu de l’incidence significative du (des) point(s) mentionné(s) au paragraphe ci-dessus, nous ne sommes pas en mesure d’attester la cohérence et la vraisemblance des comptes annuels (ou « intermédiaires ») pris dans leur ensemble tels qu’ils sont joints au présent rapport.,
        Lieu, date et signature',N'4',NULL,NULL),
        (N'SANS_OBSERVATION',N'E1',N'14',N'Attestation sans observation',N'ATTESTATION DE PRESENTATION DES COMPTES',N'1',N'NP 2300, § 19, exemple E1',N'En notre qualité d’expert-comptable et conformément aux termes de notre lettre de mission, nous avons effectué une mission de présentation des comptes … (préciser « annuels », « intermédiaires ») de … (préciser l’entité concernée) relatifs à … (préciser la période ou l’exercice concerné), qui se caractérisent par les données suivantes :,
        · Total du bilan ;,
        · Chiffre d’affaires ;,
        · Résultat net comptable.,
        Nos diligences ont été réalisées conformément à la norme professionnelle de l’Ordre des experts-comptables applicable à la mission de présentation des comptes qui ne constitue ni un audit ni un examen limité.,
        Sur la base de nos travaux, nous n’avons pas relevé d’éléments remettant en cause la cohérence et la vraisemblance des comptes annuels (ou « intermédiaires ») pris dans leur ensemble tels qu’ils sont joints à la présente attestation.,
        Lieu, date et signature',N'2',NULL,NULL);
    PRINT 'ref_forme_rapport : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' ligne(s) chargee(s).';
END
ELSE PRINT 'ref_forme_rapport : deja chargee, rien a faire.';
GO
