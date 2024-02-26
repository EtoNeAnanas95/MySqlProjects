CREATE DATABASE thrid_sql_practo;
GO

USE thrid_sql_practo;
GO

CREATE TABLE wages(
    ID_wages INT PRIMARY KEY IDENTITY(1,1),
    wage int,
    salary_ID int,
    bonus_ID int
);
GO

CREATE TABLE accounting(
	ID_accounting INT PRIMARY KEY IDENTITY(1,1),
	wages_payment_date date NOT NULL,
	name varchar(30) NOT NULL,
	surname varchar(30) NOT NULL,
	middle_name varchar(30),
    FOREIGN KEY (ID_accounting) REFERENCES wages(ID_wages)
);
GO

CREATE TABLE salary(
	ID_salary INT PRIMARY KEY IDENTITY(1,1),
	salary int NOT NULL,
	post varchar(25) NOT NULL
);
GO

CREATE TABLE bonus(
	ID_bonus INT PRIMARY KEY IDENTITY(1,1),
	bonus int,
	KPI int NOT NULL
);
GO

CREATE TABLE fine(
	ID_fine INT PRIMARY KEY IDENTITY(1,1),
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
ADD FOREIGN KEY (ID_wages) REFERENCES fine(ID_fine);
GO

ALTER TABLE wages
ADD fine_ID NUMERIC;
GO

ALTER TABLE wages
ALTER COLUMN fine_ID INT;
GO

ALTER TABLE wages
DROP COLUMN fine_ID;
GO