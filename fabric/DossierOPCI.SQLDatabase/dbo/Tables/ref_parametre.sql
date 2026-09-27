CREATE TABLE [dbo].[ref_parametre] (
    [code]        VARCHAR (40)   NOT NULL,
    [valeur]      NVARCHAR (800) NULL,
    [description] NVARCHAR (400) NULL,
    [pose_par]    NVARCHAR (400) NULL,
    [pose_le]     DATETIME2 (3)  CONSTRAINT [df_param_le] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_ref_parametre] PRIMARY KEY CLUSTERED ([code] ASC)
);


GO

