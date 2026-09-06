CREATE TABLE [b0026fd3-dfdb-4602-bcf8-a36976552cee].[visual_di_7_f1627db1072db7149b413bd04916fc67] (
    [id]                         BIGINT           IDENTITY (1, 1) NOT NULL,
    [rowId]                      NVARCHAR (255)   NOT NULL,
    [colId]                      NVARCHAR (255)   NOT NULL,
    [scenarioId]                 INT              NULL,
    [filterContextHash]          NVARCHAR (255)   NULL,
    [updatedAt]                  INT              NOT NULL,
    [updatedBy]                  NVARCHAR (128)   NOT NULL,
    [dim_ecritureecriture_date]  NVARCHAR (255)   NULL,
    [dim_ecriturecompte_origine] NVARCHAR (255)   NULL,
    [dim_ecriturecompte_lib]     NVARCHAR (255)   NULL,
    [dim_ecriturecomp_aux_num]   NVARCHAR (255)   NULL,
    [dim_ecriturecomp_aux_lib]   NVARCHAR (255)   NULL,
    [dim_ecriturejournal_code]   NVARCHAR (255)   NULL,
    [dim_ecriturejournal_lib]    NVARCHAR (255)   NULL,
    [dim_ecritureecriture_num]   NVARCHAR (255)   NULL,
    [dim_ecriturepiece_date]     NVARCHAR (255)   NULL,
    [dim_ecritureecriture_lib]   NVARCHAR (255)   NULL,
    [measure_1]                  DECIMAL (30, 10) NULL,
    [measure_2]                  DECIMAL (30, 10) NULL,
    [measure_1_meta]             NVARCHAR (255)   NULL,
    [measure_2_meta]             NVARCHAR (255)   NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    UNIQUE NONCLUSTERED ([rowId] ASC, [colId] ASC, [scenarioId] ASC, [filterContextHash] ASC)
);


GO

