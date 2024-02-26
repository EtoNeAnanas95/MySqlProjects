CREATE DATABASE SixthPractice;
GO

USE SixthPractice;
GO

-------------------------копия бд из пятого практоса-----------------------------
CREATE TABLE salary (
                        ID_salary SERIAL PRIMARY KEY,
                        salary INT NOT NULL,
                        post VARCHAR(25) NOT NULL
);
GO

CREATE TABLE bonus (
                       ID_bonus SERIAL PRIMARY KEY,
                       bonus INT,
                       KPI INT NOT NULL
);
GO


CREATE TABLE fine (
                      ID_fine SERIAL PRIMARY KEY,
                      fine INT,
                      no_show INT,
                      late INT,
                      behind_schedule INT
);
GO


CREATE TABLE wages (
                       ID_wages SERIAL PRIMARY KEY,
                       wage INT,
                       salary_ID INT,
                       bonus_ID INT,
                       fine_ID INT UNIQUE,
                       FOREIGN KEY (salary_ID) REFERENCES salary(ID_salary),
                       FOREIGN KEY (bonus_ID) REFERENCES bonus(ID_bonus),
                       FOREIGN KEY (fine_ID) REFERENCES fine(ID_fine)
);
GO


CREATE TABLE accounting (
                            ID_accounting SERIAL PRIMARY KEY,
                            wages_payment_date DATE NOT NULL,
                            name VARCHAR(30) NOT NULL,
                            surname VARCHAR(30) NOT NULL,
                            middle_name VARCHAR(30),
                            wages_ID INT UNIQUE,
                            FOREIGN KEY (wages_ID) REFERENCES wages(ID_wages)
);
GO

---------------------------------------------------------------------------------


---------------------------------------Оклад-------------------------------------
INSERT INTO salary (salary, post) VALUES (150000, 'ген. дир.');
INSERT INTO salary (salary, post) VALUES (50000, 'мастер IOS');
INSERT INTO salary (salary, post) VALUES (40000, 'мастер Android');
INSERT INTO salary (salary, post) VALUES (15000, 'Уборщик');
GO

UPDATE salary
SET salary = 0, post = 'NY TIPA DOLZHNOST'
WHERE post = 'Уборщик';
GO

DELETE FROM salary WHERE ID_salary = 4;
GO

INSERT INTO salary (salary, post) VALUES (15000, 'Уборщик');
GO

-- Премия
INSERT INTO bonus (bonus, KPI) VALUES (70000, 150);
INSERT INTO bonus (bonus, KPI) VALUES (0, 12);
INSERT INTO bonus (bonus, KPI) VALUES (10000, 50);
INSERT INTO bonus (bonus, KPI) VALUES (15000, 115);
INSERT INTO bonus (bonus, KPI) VALUES (15000, 100);
GO

UPDATE bonus
SET bonus = null, KPI = 0
WHERE KPI = 112;
GO

DELETE FROM bonus WHERE ID_bonus = 6;
GO

INSERT INTO bonus (bonus, KPI) VALUES (15000, 112);
GO

---------------------------------------------------------------------------------

---------------------------------------Штраф-------------------------------------
INSERT INTO fine (fine, no_show, late, behind_schedule) VALUES (null, null, null, null);
INSERT INTO fine (fine, no_show, late, behind_schedule) VALUES (null, null, null, null);
INSERT INTO fine (fine, no_show, late, behind_schedule) VALUES (null, null, null, null);
INSERT INTO fine (fine, no_show, late, behind_schedule) VALUES (null, null, null, null);
INSERT INTO fine (fine, no_show, late, behind_schedule) VALUES (null, null, null, null);
INSERT INTO fine (fine, no_show, late, behind_schedule) VALUES (null, null, null, null);
INSERT INTO fine (fine, no_show, late, behind_schedule) VALUES (null, null, null, null);
GO

UPDATE fine
SET fine = 500, no_show = 1, late = 0, behind_schedule = 0
WHERE ID_fine = 1;
GO

UPDATE fine
SET fine = 2300, no_show = 4, late = 0, behind_schedule = 1
WHERE ID_fine = 2;
GO

UPDATE fine
SET fine = 13000, no_show = 15, late = 25, behind_schedule = 10
WHERE ID_fine = 3;
GO

UPDATE fine
SET fine = 5200, no_show = 8, late = 3, behind_schedule = 3
WHERE ID_fine = 4;
GO

UPDATE fine
SET fine = 1100, no_show = 2, late = 1, behind_schedule = 0
WHERE ID_fine = 5;
GO

UPDATE fine
SET fine = 0, no_show = 0, late = 0, behind_schedule = 0
WHERE ID_fine = 6;
GO

DELETE FROM fine WHERE ID_fine = 7;
GO

---------------------------------------------------------------------------------


---------------------------------------зп----------------------------------------
INSERT INTO wages (wage, salary_ID, bonus_ID, fine_ID) VALUES (NULL, NULL, NULL, 1);
INSERT INTO wages (wage, salary_ID, bonus_ID, fine_ID) VALUES (NULL, NULL, NULL, 2);
INSERT INTO wages (wage, salary_ID, bonus_ID, fine_ID) VALUES (NULL, NULL, NULL, 3);
INSERT INTO wages (wage, salary_ID, bonus_ID, fine_ID) VALUES (NULL, NULL, NULL, 4);
INSERT INTO wages (wage, salary_ID, bonus_ID, fine_ID) VALUES (NULL, NULL, NULL, 5);
INSERT INTO wages (wage, salary_ID, bonus_ID, fine_ID) VALUES (NULL, NULL, NULL, 6);
GO

INSERT INTO fine (fine, no_show, late, behind_schedule) VALUES (NULL, NULL, NULL, NULL);
GO

INSERT INTO wages (wage, salary_ID, bonus_ID, fine_ID) VALUES (NULL, NULL, NULL, 8);
GO

UPDATE wages
SET salary_ID = 1, bonus_ID = 1, wage = 219500
WHERE ID_wages = 1;
GO

UPDATE wages
SET salary_ID = 2, bonus_ID = 2, wage = 47700
WHERE ID_wages = 2;
GO

UPDATE wages
SET salary_ID = 3, bonus_ID = 3, wage = 37000
WHERE ID_wages = 3;
GO

UPDATE wages
SET salary_ID = 3, bonus_ID = 4, wage = 49800
WHERE ID_wages = 4;
GO

UPDATE wages
SET salary_ID = 3, bonus_ID = 5, wage = 53900
WHERE ID_wages = 5;
GO

UPDATE wages
SET salary_ID = 5, bonus_ID = 6, wage = 30000
WHERE ID_wages = 6;
GO

DELETE FROM wages WHERE ID_wages = 7;
GO

---------------------------------------------------------------------------------


-----------------------------------Бухгалтерия-----------------------------------
INSERT INTO accounting (wages_payment_date, name, surname, middle_name, wages_ID) VALUES ('2023-11-19', 'Андрей', 'Андрев', 'Андреевич', 1);
INSERT INTO accounting (wages_payment_date, name, surname, middle_name, wages_ID) VALUES ('2023-11-20', 'Иван ', 'Иванов ', 'Иванович', 2);
INSERT INTO accounting (wages_payment_date, name, surname, middle_name, wages_ID) VALUES ('2023-11-19', 'Роман ', 'Романов ', 'Романович', 3);
INSERT INTO accounting (wages_payment_date, name, surname, middle_name, wages_ID) VALUES ('2023-11-03', 'Александ ', 'Александров ', N'Александрович', 4);
INSERT INTO accounting (wages_payment_date, name, surname, middle_name, wages_ID) VALUES ('2023-11-19', 'Степан ', 'Степанов ', 'Степанович', 5);
INSERT INTO accounting (wages_payment_date, name, surname, middle_name, wages_ID) VALUES ('2023-11-07', 'Дарья ', 'Дарьева ', 'Дарьевна', 6);
INSERT INTO accounting (wages_payment_date, name, surname, middle_name, wages_ID) VALUES ('9999-11-07', 'жопа ', 'жопа ', 'жопа', NULL);
GO

UPDATE accounting
SET name = 'big zhopa'
WHERE surname = 'жопа ';
GO

DELETE FROM accounting WHERE surname = 'жопа ';
GO

-------------------------------------------------------------------------------



--------------------------Примеры SELECT запросов------------------------------
SELECT name, surname, middle_name FROM accounting;
SELECT * FROM accounting;
SELECT * FROM accounting WHERE ID_accounting = 1;
GO

SELECT *
FROM accounting
         FULL JOIN wages ON accounting.ID_accounting = wages.ID_wages;
GO

SELECT *
FROM accounting
         LEFT JOIN wages ON accounting.ID_accounting = wages.ID_wages;
GO

SELECT *
FROM accounting
         RIGHT JOIN wages ON accounting.ID_accounting = wages.ID_wages;
GO

SELECT *
FROM accounting
         INNER JOIN wages ON accounting.ID_accounting = wages.ID_wages;
GO
-------------------------------------------------------------------------------