

-- --- 4 : les controles ----------------------------------------------
-- C68 : la difference d'estimation du tableau des filiales doit egaler
-- la soustraction que le modele definit, valeur actuelle moins cout de
-- revient frais exclus. Le modele l'ecrit lui-meme : (3) - (2).
CREATE   VIEW dbo.v_controle_inventaire_filiales AS
SELECT entite, arrete, entite_fille,
       cout_de_revient_frais_exclus, valeur_actuelle_titres,
       difference_estimation,
       valeur_actuelle_titres - COALESCE(cout_de_revient_frais_exclus, 0)
         - difference_estimation                AS ecart_a_la_formule,
       CASE WHEN cout_de_revient_frais_exclus IS NULL
            THEN N'le coût de revient n''est pas ventilé par filiale : le compte auxiliaire ne porte pas le code de la fille'
            ELSE N'la différence égale la soustraction que le modèle définit'
            END                                 AS lecture
FROM dbo.v_inventaire_filiales;

GO

