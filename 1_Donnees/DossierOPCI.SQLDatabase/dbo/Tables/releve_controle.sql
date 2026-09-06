CREATE TABLE [dbo].[releve_controle] (
    [id]         INT            IDENTITY (1, 1) NOT NULL,
    [releve_le]  DATETIME2 (3)  DEFAULT (sysutcdatetime()) NOT NULL,
    [releve_par] NVARCHAR (400) DEFAULT (suser_sname()) NOT NULL,
    [vue]        VARCHAR (120)  NOT NULL,
    [lignes]     INT            NOT NULL,
    [anomalies]  INT            NOT NULL,
    [message]    NVARCHAR (400) NULL,
    CONSTRAINT [pk_releve_controle] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_releve_controle_vue] FOREIGN KEY ([vue]) REFERENCES [dbo].[ref_controle] ([vue])
);


GO

CREATE NONCLUSTERED INDEX [ix_releve_controle_date]
    ON [dbo].[releve_controle]([releve_le] DESC, [vue] ASC);


GO

