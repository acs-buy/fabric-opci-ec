CREATE TABLE [dbo].[tmp_jeu_hist] (
    [arrete]        VARCHAR (20)   NOT NULL,
    [coef_loyer]    DECIMAL (9, 6) NOT NULL,
    [quotite_ecart] DECIMAL (9, 6) NOT NULL,
    [taux_bancaire] DECIMAL (9, 6) NOT NULL,
    PRIMARY KEY CLUSTERED ([arrete] ASC)
);


GO

