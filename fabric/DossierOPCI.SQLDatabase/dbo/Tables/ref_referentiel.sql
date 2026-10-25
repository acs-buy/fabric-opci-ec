CREATE TABLE [dbo].[ref_referentiel] (
    [table_nom]           VARCHAR (120)  NOT NULL,
    [libelle]             NVARCHAR (160) NOT NULL,
    [ecran_lu]            NVARCHAR (200) NOT NULL,
    [qui_tient]           VARCHAR (20)   NOT NULL,
    [ordre]               INT            NOT NULL,
    [domaine]             NVARCHAR (60)  NULL,
    [domaine_ordre]       TINYINT        NULL,
    [categorie]           NVARCHAR (60)  NULL,
    [categorie_ordre]     TINYINT        NULL,
    [rang_categorie]      TINYINT        NULL,
    [mode_tenue]          VARCHAR (5)    CONSTRAINT [df_ref_referentiel_mode_tenue] DEFAULT ('TENU') NOT NULL,
    [du_cabinet]          BIT            CONSTRAINT [df_ref_referentiel_du_cabinet] DEFAULT ((1)) NOT NULL,
    [colonne_designation] VARCHAR (128)  NULL,
    [actions_de_ligne]    TINYINT        CONSTRAINT [df_ref_referentiel_actions_de_ligne] DEFAULT ((1)) NOT NULL,
    [action_propre]       NVARCHAR (60)  NULL,
    CONSTRAINT [pk_ref_referentiel] PRIMARY KEY CLUSTERED ([table_nom] ASC),
    CONSTRAINT [ck_ref_referentiel_actions_de_ligne] CHECK ([actions_de_ligne]=(3) OR [actions_de_ligne]=(2) OR [actions_de_ligne]=(1) OR [actions_de_ligne]=(0)),
    CONSTRAINT [ck_ref_referentiel_mode_tenue] CHECK ([mode_tenue]='TEXTE' OR [mode_tenue]='TENU'),
    CONSTRAINT [ck_ref_referentiel_tient] CHECK ([qui_tient]='BASE' OR [qui_tient]='REVISEUR' OR [qui_tient]='ASSOCIE'),
    CONSTRAINT [uq_ref_referentiel_ordre] UNIQUE NONCLUSTERED ([ordre] ASC)
);


GO

