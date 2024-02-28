CREATE DATABASE FirstSqlPractice;
GO

USE FirstSqlPractice;
GO

------------------------------------ПРЕДВАРИТЕЛЬНЫЕ ПАРАМЕТРЫ ДЛЯ НОРМАЛЬНОГО ВЫВОДА В CSV----------------------------------------------
EXEC sp_configure 'show advanced option', 1
GO

RECONFIGURE
GO

EXEC sp_configure 'xp_cmdshell', 1
GO

RECONFIGURE
GO

EXEC xp_cmdshell 'mkdir C:\Users\Public\Documents\kiriloy_lybit_datagrip'
GO
----------------------------------------------------------------------------------------------------------------------------------------


------------------------------------КОПИНИЯ БД ИЗ ПРЕДЫДУЩИХ ПРАКТОСОВ----------------------------------------------
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

CREATE TABLE wages(
    ID_wages INT PRIMARY KEY IDENTITY(1,1),
    wage int,
    salary_ID int,
    FOREIGN KEY (salary_ID) REFERENCES salary(ID_salary),
    bonus_ID int,
    FOREIGN KEY (bonus_ID) REFERENCES bonus(ID_bonus),
    fine_ID int UNIQUE,
    FOREIGN KEY (fine_ID) REFERENCES fine(ID_fine)

);
GO

CREATE TABLE accounting(
    ID_accounting INT PRIMARY KEY IDENTITY(1,1),
    wages_payment_date date NOT NULL,
    name varchar(30) NOT NULL,
    surname varchar(30) NOT NULL,
    middle_name varchar(30),
    wages_ID int UNIQUE,
    FOREIGN KEY (wages_ID) REFERENCES wages(ID_wages)
);
GO
--------------------------------------------------------------------------------------------------------------------


--------------------------------------------Оклад-----------------------------------
INSERT INTO salary (salary, post)
VALUES
    (150000, 'ген. дир.'),
    (50000, 'мастер IOS'),
    (40000, 'мастер Android'),
    (15000, 'Уборщик')
GO
------------------------------------------------------------------------------------


--------------------------------------------Премия----------------------------------
INSERT INTO bonus (bonus, KPI)
VALUES
    (70000, 150),
    (0, 12),
    (10000, 50),
    (15000, 115),
    (15000, 100),
    (15000, 112)
GO
------------------------------------------------------------------------------------


--------------------------------------------Штраф-----------------------------------
INSERT INTO fine (fine, no_show, late, behind_schedule)
VALUES
    (500, 1, 0, 0),
    (2300, 4, 0, 1),
    (13000, 15, 25, 10),
    (5200, 8, 3, 3),
    (1100, 2, 1, 0),
    (0, 0, 0, 0)
GO
------------------------------------------------------------------------------------


--------------------------------------------ЗП--------------------------------------
INSERT INTO wages (wage, salary_ID, bonus_ID, fine_ID)
VALUES
    (0, 1, 1, 1),
    (0, 2, 2, 2),
    (0, 3, 3, 3),
    (0, 3, 4, 4),
    (0, 3, 5, 5),
    (0, 4, 6, 6)
GO
------------------------------------------------------------------------------------

--------------------------------------бухгалтерия-----------------------------------
INSERT INTO accounting (wages_payment_date, name, surname, middle_name, wages_ID)
VALUES
    ('2023-11-19', 'Андрей', 'Андрев', 'Андреевич', 1),
    ('2023-11-20', 'Иван ', 'Иванов ', 'Иванович', 2),
    ('2023-11-19', 'Роман ', 'Романов ', 'Романович', 3),
    ('2023-11-03', 'Александ ', 'Александров ', N'Александрович', 4),
    ('2023-11-19', 'Степан ', 'Степанов ', 'Степанович', 5),
    ('2023-11-07', 'Дарья ', 'Дарьева ', 'Дарьевна', 6)
GO
------------------------------------------------------------------------------------

------------------------------ПЕРВОЕ ПРЕДСТАВЛЕНИЕ----------------------------------
CREATE VIEW HowManyFines_VIEW AS --TODO ПОРАВИТЬ CONCATЫ ВЕЗДЕ
SELECT
    CONCAT(accounting.surname, ' ', LEFT(accounting.name, 1), '.', LEFT(accounting.middle_name, 1), '.') AS "Фамилия и инициалы сотрудника",
    CONCAT(CAST(SUM(wages.wage + fine.fine) AS VARCHAR(10)), ' - ', CAST(SUM(fine.fine) AS VARCHAR(10)), ' = ', CAST(SUM(wages.wage) AS VARCHAR(10))) AS "Вычет штрафа"
FROM
    accounting
INNER JOIN
    wages ON accounting.wages_ID = wages.ID_wages
INNER JOIN
    fine ON wages.fine_ID = fine.ID_fine
GROUP BY
    accounting.surname, accounting.name, accounting.middle_name;
GO

SELECT * FROM HowManyFines_VIEW;
GO
------------------------------------------------------------------------------------

------------------------------ВТОРОЕ ПРЕДСТАВЛЕНИЕ----------------------------------
CREATE VIEW GetFullInfo_VIEW AS
SELECT
    CONCAT(accounting.surname, ' ', LEFT(accounting.name, 1), '.', LEFT(accounting.middle_name, 1), '.') AS "Фамилия и инициалы сотрудника",
    'Должность:' + ' ' + salary.post AS "Должность",
    'Оклад:' + ' ' + CONVERT(VARCHAR(50), salary.salary) AS "Оклад",
    'Премия:' + ' ' + CONVERT(VARCHAR(50), bonus.bonus) AS "Премия"
FROM
    accounting
JOIN
    wages on accounting.wages_ID = wages.ID_wages
JOIN
    bonus on wages.bonus_ID = bonus.ID_bonus
JOIN
    salary on wages.salary_ID = salary.ID_salary;
GO

SELECT * FROM GetFullInfo_VIEW;
GO
------------------------------------------------------------------------------------

------------------------------ТРЕТЬЕ ПРЕДСТАВЛЕНИЕ----------------------------------
CREATE VIEW GetWages_VIEW AS
SELECT
    CONVERT(VARCHAR(50), accounting.wages_payment_date) AS "Дата выдачи ЗП",
    CONCAT(accounting.surname, ' ', LEFT(accounting.name, 1), '.', LEFT(accounting.middle_name, 1), '.') AS "Фамилия и инициалы сотрудника",
    'След. ЗП:' + ' ' + CONVERT(VARCHAR(50), wages.wage) AS "След. ЗП"
FROM accounting
JOIN wages on accounting.wages_ID = wages.ID_wages;
GO

SELECT * FROM GetWages_VIEW;
GO
------------------------------------------------------------------------------------

----------------------------------ПЕРВАЯ ПРОЦЕДУРА----------------------------------
CREATE PROCEDURE NewEmploy_PROCEDURE
    @NAME VARCHAR(100),
    @SURNAME VARCHAR(100),
    @MIDDLENAME VARCHAR(100),
    @POST INT,
    @WAGE_DATE DATE
AS
    BEGIN
        BEGIN TRANSACTION;

        DECLARE @NEW_FINE_ID INT;
        DECLARE @NEW_BONUS_ID INT;
        DECLARE @NEW_WAGES_ID INT;
        DECLARE @NEW_EMPLOY_WAGE INT;

        IF @POST = 1
        BEGIN
            SET @NEW_EMPLOY_WAGE = 150000;
        END
        ELSE IF @POST = 2
        BEGIN
            SET @NEW_EMPLOY_WAGE = 50000;
        END
        ELSE IF @POST = 3
        BEGIN
            SET @NEW_EMPLOY_WAGE = 40000;
        END
        ELSE IF @POST = 4
        BEGIN
            SET @NEW_EMPLOY_WAGE = 15000;
        END

        INSERT INTO fine (fine, no_show, late, behind_schedule) VALUES (0, 0, 0, 0);
        SET @NEW_FINE_ID = SCOPE_IDENTITY();

        INSERT INTO bonus (bonus, KPI) VALUES (0, 0);
        SET @NEW_BONUS_ID = SCOPE_IDENTITY();

        INSERT wages (wage, salary_ID, bonus_ID, fine_ID) VALUES (@NEW_EMPLOY_WAGE, @POST, @NEW_BONUS_ID, @NEW_FINE_ID);
        SET @NEW_WAGES_ID = SCOPE_IDENTITY();

        INSERT INTO accounting (wages_payment_date, name, surname, middle_name, wages_ID)
        VALUES (@WAGE_DATE, @NAME, @SURNAME, @MIDDLENAME, @NEW_WAGES_ID);

        COMMIT TRANSACTION;
    END
GO

EXEC NewEmploy_PROCEDURE
    @NAME = 'TEST',
    @SURNAME = 'TEST',
    @MIDDLENAME = 'TEST',
    @POST = 1,
    @WAGE_DATE = '2022-04-15'
GO
------------------------------------------------------------------------------------

----------------------------------ВТОРАЯ ПРОЦЕДУРА----------------------------------
CREATE PROCEDURE NewFine_PROCEDURE
    @EMPLOYE_ID INT,
    @NO_SHOW INT,
    @LATE INT,
    @BEHIND_SCHEDULE INT
AS
    BEGIN
        UPDATE fine
        SET no_show = @NO_SHOW, late = @LATE, behind_schedule = @BEHIND_SCHEDULE
        WHERE ID_fine = @EMPLOYE_ID;
    END;
GO

EXEC NewFine_PROCEDURE
    @EMPLOYE_ID = 7,
    @NO_SHOW  = 7,
    @LATE  = 7,
    @BEHIND_SCHEDULE  = 7
GO
------------------------------------------------------------------------------------

----------------------------------ТРЕТЬЯ ПРОЦЕДУРА----------------------------------
CREATE PROCEDURE NewKPI_PROCEDURE
    @EMPLOYE_ID INT,
    @KPI INT
AS
    BEGIN
        DECLARE @BONUS INT;

        IF @KPI >= 50 AND @KPI < 100
        BEGIN
            SET @BONUS = 10000;
        END
        ELSE IF @KPI >= 100 AND @KPI < 150
        BEGIN
            SET @BONUS = 15000;
        END
        ELSE IF @KPI >= 150
        BEGIN
            SET @BONUS = 70000;
        END
        ELSE
        BEGIN
            SET @BONUS = 0;
        END

        UPDATE bonus
        SET KPI = @KPI, bonus = @BONUS
        WHERE ID_bonus = @EMPLOYE_ID;
    END;
GO

EXEC NewKPI_PROCEDURE
    @EMPLOYE_ID = 7,
    @KPI = 100
GO
------------------------------------------------------------------------------------

---------------------------------ПЕРВАЯ ФУНКЦИЯ-------------------------------------
CREATE FUNCTION GetSummFines_FUNCTION(@EMPLOYE_ID INT)
RETURNS INT
AS
    BEGIN
        DECLARE @SUMM INT;
        SELECT @SUMM = SUM(fine)
        FROM fine
        WHERE ID_fine = @EMPLOYE_ID
        RETURN @SUMM
    END;
GO

PRINT 'SYMMA VSEH SHTRAFOV Y CHELA POD NOMEROM 6: ' + CONVERT(VARCHAR(50), dbo.GetSummFines_FUNCTION(6));
GO
------------------------------------------------------------------------------------

---------------------------------ВТОРАЯ ФУНКЦИЯ-------------------------------------
CREATE FUNCTION PreSalary_FUNCTION(
    @KPI INT,
    @NO_SHOW INT,
    @LATE INT,
    @BEHIND_SCHEDULE INT,
    @POST INT
)
RETURNS INT
AS
    BEGIN
        DECLARE @SALARY INT;
        DECLARE @BONUS INT;
        DECLARE @WAGE INT;

        IF @KPI >= 50 AND @KPI < 100
        BEGIN
            SET @BONUS = 10000;
        END
        ELSE IF @KPI >= 100 AND @KPI < 150
        BEGIN
            SET @BONUS = 15000;
        END
        ELSE IF @KPI >= 150
        BEGIN
            SET @BONUS = 70000;
        END
        ELSE
        BEGIN
            SET @BONUS = 0;
        END

        IF @POST = 1
        BEGIN
            SET @WAGE = 150000;
        END
        ELSE IF @POST = 2
        BEGIN
            SET @WAGE = 50000;
        END
        ELSE IF @POST = 3
        BEGIN
            SET @WAGE = 40000;
        END
        ELSE IF @POST = 4
        BEGIN
            SET @WAGE = 15000;
        END

        SET @SALARY = (@WAGE + @BONUS + (@NO_SHOW * 500) + (@LATE * 100) + (@BEHIND_SCHEDULE * 300));

        RETURN @SALARY
    END;
GO

PRINT 'ПРЕДВАРИТЕЛЬНАЯ ЗП РАВНА: ' + CONVERT(VARCHAR(50), dbo.PreSalary_FUNCTION(100, 1, 0, 0, 1));
GO
------------------------------------------------------------------------------------

---------------------------------ТРЕТЬЯ ФУНКЦИЯ-------------------------------------
CREATE FUNCTION GetSalaryOnPost(@POST VARCHAR(25))
RETURNS INT
AS
    BEGIN
        DECLARE @SALARY_POST INT;

        SELECT @SALARY_POST = salary.salary
        FROM salary
        WHERE salary.post = @POST;

        RETURN @SALARY_POST;
    END;
GO

PRINT 'зарплата ген. дира: ' + CONVERT(VARCHAR(50), dbo.GetSalaryOnPost ('ген. дир.'));
GO
------------------------------------------------------------------------------------

---------------------------------ПЕРВЫЙ ТРИГГЕР-------------------------------------
CREATE TRIGGER UpdateFine_TRIGGER
ON fine
AFTER UPDATE
AS
BEGIN
    IF UPDATE(no_show) OR UPDATE(late) OR UPDATE(behind_schedule)
    BEGIN
        DECLARE @INSERTED_EMPLOY_ID INT;
        DECLARE @FINE INT;
        DECLARE @WAGE INT;

        SELECT @INSERTED_EMPLOY_ID =  fine.ID_fine, @FINE = (inserted.no_show * 500) + (inserted.late * 100) + (inserted.behind_schedule * 300)
        FROM inserted
        INNER JOIN fine ON inserted.ID_fine = fine.ID_fine;

        UPDATE fine
        SET fine = @FINE
        WHERE ID_fine = @INSERTED_EMPLOY_ID;

        SELECT @WAGE = salary.salary
        FROM wages
        INNER JOIN salary ON wages.salary_ID = salary.ID_salary
        WHERE wages.ID_wages = @INSERTED_EMPLOY_ID;

        SELECT @WAGE = @WAGE + bonus.bonus
        FROM wages
        INNER JOIN bonus ON wages.ID_wages = bonus.ID_bonus
        WHERE wages.ID_wages = @INSERTED_EMPLOY_ID;

        UPDATE wages
        SET wage = @WAGE - @FINE
        WHERE ID_wages = @INSERTED_EMPLOY_ID;
    END;
END;
GO

UPDATE fine
    SET no_show = 10
WHERE ID_fine = 6;
GO
------------------------------------------------------------------------------------

---------------------------------ВТОРОЙ ТРИГГЕР-------------------------------------
CREATE TRIGGER MakeCopyAccounting_TRIGGER
ON accounting
AFTER UPDATE
AS
    COMMIT TRANSACTION;
       BACKUP DATABASE FirstSqlPractice TO DISK = 'C:\Users\Public\Documents\kiriloy_lybit_datagrip\Kiriloy_lybit_datagrip.bak';
    BEGIN TRANSACTION;
GO

UPDATE accounting
SET wages_payment_date = '1990-01-01'
WHERE ID_accounting = 7;
GO
------------------------------------------------------------------------------------

---------------------------------ТРЕТИЙ ТРИГГЕР-------------------------------------
CREATE TRIGGER PROSTO_TRIGGER_KOTORII_YA_NE_HOTEL_DELAT
ON salary
AFTER INSERT
AS
    BEGIN
       PRINT 'YOU SPIN ME RIGHT ROUND, BABY RIGHT ROUND, LIKE A RECOD BABY RIGHT ROUND RIGHT ROUND'
    END;
GO

INSERT INTO salary (salary, post) VALUES (999999999, 'КАНИ ИСТ')
GO
------------------------------------------------------------------------------------

------------------------------СОЗДАНИЕ ПОЛЬЗОВАТЕЛЕЙ--------------------------------

CREATE LOGIN User_1_Login WITH PASSWORD = '123';
GO
CREATE LOGIN User_2_Login WITH PASSWORD = '123';
GO

CREATE USER User_1 FOR LOGIN User_1_Login;
GO
CREATE USER User_2 FOR LOGIN User_2_Login;
GO

CREATE ROLE ROLE_TEST;
GO
------------------------------------------------------------------------------------

------------------------------ДОБАВЛЕНИЕ ИХ В ГРУППУ--------------------------------
ALTER ROLE ROLE_TEST ADD MEMBER User_1;
GO
ALTER ROLE ROLE_TEST ADD MEMBER User_2;
GO

GRANT SELECT ON salary TO User_1;
GO
GRANT SELECT ON bonus TO User_1;
GO
GRANT SELECT ON fine TO User_1;
GO
GRANT SELECT ON wages TO User_1;
GO
GRANT SELECT ON accounting TO User_1;
GO

GRANT SELECT, INSERT ON salary TO User_2;
GO
GRANT SELECT, INSERT ON bonus TO User_2;
GO
GRANT SELECT, INSERT ON fine TO User_2;
GO
GRANT SELECT, INSERT ON wages TO User_2;
GO
GRANT SELECT, INSERT ON accounting TO User_2;
GO

------------------------------------------------------------------------------------

--------------------------------------LIKE------------------------------------------
SELECT * FROM accounting WHERE accounting.name LIKE 'А%'; -- Вывел всех кто начинается на "А"
SELECT * FROM accounting WHERE accounting.name LIKE '%ва%'; -- вывел всё, где хоть как-то встречаетя "ва"
SELECT * FROM accounting WHERE accounting.name LIKE '_л%'; -- вывел людей у которых вторая буква в имени это "л". Поставил % в конце, чтоб он мог жальше бежать по содержимому
SELECT * FROM accounting WHERE accounting.name LIKE '%\_%' ESCAPE '\'; -- ну это эксейп, он нужен чтоб экранировать спец. символы
GO
------------------------------------------------------------------------------------

----------------------------------ИМПОРТ/ЭКСПОРТ------------------------------------
EXEC xp_cmdshell 'bcp FirstSqlPractice.dbo.accounting out "C:\Users\Public\Documents\kiriloy_lybit_datagrip\Export_accounting.csv" -w -t, -T -S DESKTOP-8MM2714\SQLEXPRESS';
GO

SELECT * FROM accounting;
GO

--EXEC xp_cmdshell 'bcp FirstSqlPractice.dbo.accounting in "C:\Users\Public\Documents\Export_accounting.csv" -w -t, -T -S DESKTOP-8MM2714\SQLEXPRESS';
--GO
------------------------------------------------------------------------------------

--------------------------------------БЭКАП-----------------------------------------
BACKUP DATABASE FirstSqlPractice TO DISK = 'C:\Users\Public\Documents\kiriloy_lybit_datagrip\Kiriloy_lybit_datagrip.bak';
GO

-- USE master;
-- GO

--DROP DATABASE FirstSqlPractice;
--GO;

--CREATE DATABASE FirstSqlPractice;
--GO;

--RESTORE DATABASE FirstSqlPractice FROM DISK = 'KIRILOY.BAK';
--GO;
------------------------------------------------------------------------------------