CREATE DATABASE FirstSqlPractice;
GO

USE FirstSqlPractice;
GO

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
CREATE VIEW HowManyFines_VIEW AS
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

    --ДА, ЗДЕСЬ ПУСТО, ПОТОМУ ЧТО Я НЕ ПРИДУМАЛ ЧТО ОНА МОЖЕТ ДЕЛАТЬ

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
------------------------------------------------------------------------------------

------------------ВТОРОЙ ТРИГГЕР (ЗАСЧИТАЙТЕ ВСЕХ ИХ КАК ОДИН)----------------------

--ДА ОНИ МАКСИМАЛЬНО ПРОСТЫЕ, НО Я МЕГА НЕУСПЕВАЮ ЭТО ДОДЕЛАТЬ(((
--ИЗВИНИТЕ ПОЖАЛУЙСТА)
CREATE TRIGGER ShowLog1
ON fine
AFTER UPDATE
AS
    BEGIN
       PRINT 'БЫЛИ ВНЕСЕНЫ ИЗМЕНЕНИЯ В FINE'
    END;
GO

CREATE TRIGGER ShowLog2
ON bonus
AFTER UPDATE
AS
    BEGIN
       PRINT 'БЫЛИ ВНЕСЕНЫ ИЗМЕНЕНИЯ В BONUS'
    END;
GO

CREATE TRIGGER ShowLog3
ON wages
AFTER UPDATE
AS
    BEGIN
       PRINT 'БЫЛИ ВНЕСЕНЫ ИЗМЕНЕНИЯ В WAGES'
    END;
GO
------------------------------------------------------------------------------------

------------------------------СОЗДАНИЕ ПОЛЬЗОВАТЕЛЕЙ--------------------------------
CREATE LOGIN FirstUser WITH PASSWORD = '123';
CREATE LOGIN SecondUser WITH PASSWORD = '123';
GO

CREATE USER FirstUser FOR LOGIN FirstUser;
CREATE USER SecondUser FOR LOGIN SecondUser;
GO

CREATE ROLE ROLE;
GO
------------------------------------------------------------------------------------

------------------------------ДОБАВЛЕНИЕ ИХ В ГРУППУ--------------------------------
ALTER ROLE ROLE ADD MEMBER FirstUser;
GO
ALTER ROLE ROLE ADD MEMBER SecondUser;
GO

GRANT SELECT ON salary TO FirstUser;
GRANT SELECT ON bonus TO FirstUser;
GRANT SELECT ON fine TO FirstUser;
GRANT SELECT ON wages TO FirstUser;
GRANT SELECT ON accounting TO FirstUser;
GO

GRANT SELECT, INSERT ON salary TO SecondUser;
GRANT SELECT, INSERT ON bonus TO SecondUser;
GRANT SELECT, INSERT ON fine TO SecondUser;
GRANT SELECT, INSERT ON wages TO SecondUser;
GRANT SELECT, INSERT ON accounting TO SecondUser;
GO
------------------------------------------------------------------------------------

--------------------------------------LIKE------------------------------------------
    --УСПЕЮ ЕЩЁ
------------------------------------------------------------------------------------

----------------------------------ИМПОРТ/ЭКСПОРТ------------------------------------
EXEC sp_configure 'show advanced option', 1
GO

RECONFIGURE
GO

EXEC sp_configure 'xp_cmdshell', 1
GO

RECONFIGURE
GO

EXEC xp_cmdshell 'bcp FirstSqlPractice.dbo.accounting out "C:\Users\Public\Documents\Export_accounting.csv" -w -t, -T -S DESKTOP-8MM2714\SQLEXPRESS';
GO

SELECT * FROM accounting;
GO

EXEC xp_cmdshell 'bcp FirstSqlPractice.dbo.accounting in "C:\Users\Public\Documents\Export_accounting.csv" -w -t, -T -S DESKTOP-8MM2714\SQLEXPRESS';
GO
------------------------------------------------------------------------------------

--------------------------------------БЭКАП-----------------------------------------
BACKUP DATABASE FirstSqlPractice TO DISK = 'KIRILOY.bak';
GO

USE master;
GO

DROP DATABASE FirstSqlPractice;
GO;

CREATE DATABASE FirstSqlPractice;
GO;

RESTORE DATABASE FirstSqlPractice FROM DISK = 'KIRILOY.BAK';
GO;
------------------------------------------------------------------------------------