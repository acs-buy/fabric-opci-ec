
-- --- 4 : le classement des interets, par objet ----------------------
-- Une seule definition, lue par les vues et par les scripts de balance.
CREATE   VIEW dbo.ref_classement_interet AS
SELECT v.objet, v.compte_charge, v.compte_produit, v.resultat, v.reference
FROM (VALUES
 ('ACQUISITION', '623', '724', 'IMMOBILIER',
  N'Article 322-5 : les charges d''emprunt liees a des actifs immobiliers entrent dans les charges de l''activite immobiliere. Article 322-4 pour le produit chez le preteur, l''avance etant un actif a caractere immobilier au compte 266.'),
 ('TRAVAUX', '623', '724', 'IMMOBILIER',
  N'Article 322-5, meme regle : des travaux portent sur un actif immobilier.'),
 ('TRESORERIE', '608', '708', 'FINANCIER',
  N'Articles 322-7 et 322-9 : les charges d''emprunts qui ne sont pas affectes a des actifs immobiliers entrent dans les charges sur operations financieres.')
) AS v (objet, compte_charge, compte_produit, resultat, reference);

GO

