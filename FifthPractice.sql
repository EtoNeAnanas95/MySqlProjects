CREATE DATABASE FifthPractice;
GO

USE FifthPractice;
GO

CREATE TABLE wages(
                      ID_wages SERIAL PRIMARY KEY,
                      salary_ID int,
                      bonus_ID int,
                      fine_ID int UNIQUE
);
GO



CREATE TABLE accounting(
                           ID_accounting SERIAL PRIMARY KEY,
                           wages_payment_date date NOT NULL,
                           name varchar(30) NOT NULL,
                           surname varchar(30) NOT NULL,
                           middle_name varchar(30),
                           wages_ID int UNIQUE,
                           FOREIGN KEY (wages_ID) REFERENCES wages(ID_wages)
);
GO


CREATE TABLE salary(
                       ID_salary SERIAL PRIMARY KEY,
                       salary int NOT NULL,
                       post varchar(25) NOT NULL
);
GO


CREATE TABLE bonus(
                      ID_bonus SERIAL PRIMARY KEY,
                      bonus int,
                      KPI int NOT NULL
);
GO


CREATE TABLE fine(
                     ID_fine SERIAL PRIMARY KEY,
                     fine int,
                     no_show int,
                     late int,
                     behind_schedule int
);
GO


ALTER TABLE wages
    ADD FOREIGN KEY (salary_ID) REFERENCES salary(ID_salary);
GO


ALTER TABLE wages
    ADD FOREIGN KEY (bonus_ID) REFERENCES bonus(ID_bonus);
GO


ALTER TABLE wages
    ADD fine_no_ydalu NUMERIC;
GO


ALTER TABLE wages
    ALTER COLUMN fine_no_ydalu TYPE INT;
GO


ALTER TABLE wages
    DROP COLUMN fine_no_ydalu;
GO


ALTER TABLE wages
    ADD FOREIGN KEY (fine_ID) REFERENCES fine(ID_fine)
GO

ALTER TABLE accounting
    ADD CONSTRAINT anti_nikita
        CHECK ( name != 'Никитос ёпт' )
GO
