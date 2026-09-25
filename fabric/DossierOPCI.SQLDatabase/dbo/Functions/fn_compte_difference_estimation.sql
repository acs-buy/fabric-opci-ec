-- =====================================================================
-- LOT E du plan fusionne, troisieme partie : le compte de difference
-- d'estimation se DERIVE du poste de bilan de l'actif, il ne se saisit
-- pas et il ne se code pas en dur.
--
-- LA REGLE, LUE SUR PIECE dans le plan de comptes de l'article 411-3. Les
-- libelles s'apparient un a un, rang par rang :
--   compte 21 « Immeubles locatifs », dont 211 Terrains, 213 Constructions,
--              214 Constructions sur sol d'autrui   -> 271 « sur immeubles
--              locatifs »
--   compte 22 « Immobilisations en cours »          -> 272 « sur
--              immobilisations en cours »
--   compte 23 « Autres droits reels »               -> 273 « sur autres
--              droits reels »
--   compte 24 « Contrats de credit-bail »           -> 274 « sur contrats
--              de credits bail »
--   compte 25 « Titres a caractere immobilier »     -> 275, subdivision
--              creee par la solution au titre de l'article 411-1
--   compte 26 « Autres actifs immobiliers »         -> 276 « Differences
--              d'estimation sur autres actifs immobiliers »
--   classe 3, depots et instruments financiers      -> 37 « Differences
--              d'estimation sur depots et instruments financiers et
--              assimiles »
-- Le compte de difference est donc « 27 » suivi du deuxieme chiffre du
-- compte de l'actif pour la classe 2, et « 37 » pour la classe 3. La
-- contrepartie aux capitaux propres se lit ensuite dans
-- dbo.ref_contrepartie_estimation, deja posee par le script 60.
--
-- POURQUOI LA DERIVATION PLUTOT QU'UNE COLONNE SAISIE. Une meme nature se
-- porte a des comptes differents : un immeuble bati est au 213, un
-- terrain au 211, tous deux sous le 21 et donc au 271 ; un immeuble en
-- cours est au 221, donc au 272. La nature ne suffit pas, le poste de
-- bilan tranche. Le moteur portait un dictionnaire Python qui appariait
-- par nature, avec un vocabulaire qui n'etait pas celui de
-- dbo.ref_nature_actif : ce script fait de la base la source unique.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : la fonction de derivation -----------------------------------
CREATE   FUNCTION dbo.fn_compte_difference_estimation
    (@poste_bilan VARCHAR (20))
RETURNS VARCHAR (20)
AS
BEGIN
    -- La classe 3 porte les depots et instruments financiers non
    -- immobiliers, modele de bilan de l'article 321-2.
    IF LEFT(@poste_bilan, 1) = '3' RETURN '37';
    -- La classe 2 porte les actifs a caractere immobilier : le compte de
    -- difference suit le rang du compte de l'actif.
    IF LEFT(@poste_bilan, 1) = '2'
       AND SUBSTRING(@poste_bilan, 2, 1) BETWEEN '1' AND '6'
        RETURN '27' + SUBSTRING(@poste_bilan, 2, 1);
    RETURN NULL;
END

GO

