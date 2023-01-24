--Basic SQL commands:

SELECT - used to select data from a database
INSERT - used to insert data into a table
UPDATE - used to update existing data in a table
DELETE - used to delete data from a table
CREATE - used to create a new table or database
ALTER - used to alter the structure of a table or database
DROP - used to delete an entire table or database
WHERE - used to filter results based on certain conditions
TOP - used to limit the number of results returned
ORDER BY - used to sort the results in a specific order
BEGIN TRANSACTION - used to start a transaction
COMMIT - used to save changes made during a transaction
ROLLBACK - used to undo changes made during a transaction
BACKUP DATABASE - used to create a backup of a database
RESTORE DATABASE - used to restore a database from a backup
SET IDENTITY_INSERT - used to enable or disable the ability to insert values into the IDENTITY column of a table.


------------------
--MS SQL table creation example
CREATE TABLE Customers
(
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    CompanyName NVARCHAR(40) NOT NULL,
    ContactName NVARCHAR(30),
    ContactTitle NVARCHAR(30),
    Address NVARCHAR(60),
    City NVARCHAR(15),
    Region NVARCHAR(15),
    PostalCode NVARCHAR(10),
    Country NVARCHAR(15),
    Phone NVARCHAR(24)

);

------------------------------------
CREATE TABLE Employees
(
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(40) NOT NULL,
    LastName NVARCHAR(40) NOT NULL,
    Title NVARCHAR(40),
    Address NVARCHAR(60),
    City NVARCHAR(15),
    Region NVARCHAR(15),
    PostalCode NVARCHAR(10),
    Country NVARCHAR(15),
    Phone NVARCHAR(24),
    Fax NVARCHAR(24),
    Email NVARCHAR(40),
	HireDate DATETIME,
    CustomerID INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-----------------
--Alter Table example
ALTER TABLE Employees
ADD Salary DECIMAL(18,2) NOT NULL;

ALTER TABLE Employees
ADD Status VARCHAR(15) NOT NULL DEFAULT 'Active';

--Insert into MS SQL example
INSERT INTO Customers (CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone)
VALUES ('Thalisson LTD', 'Thalisson', 'Sales Representative', 'fake Str. 200', 'Santos', 'NULL', '12209', 'Brazil', '030-0074321');


---Procedure example
CREATE PROCEDURE IncreaseSalaryBy100
    @employeeID INT,
    @customerID INT
AS
BEGIN
    DECLARE @currentSalary DECIMAL(18,2)
    DECLARE cursor_employee CURSOR FOR
        SELECT Salary FROM Employees WHERE EmployeeID = @employeeID AND CustomerID = @customerID

    OPEN cursor_employee
    FETCH NEXT FROM cursor_employee INTO @currentSalary

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @currentSalary = @currentSalary + 100
        UPDATE Employees SET Salary = @currentSalary WHERE CURRENT OF cursor_employee
        FETCH NEXT FROM cursor_employee INTO @currentSalary
    END

    CLOSE cursor_employee
    DEALLOCATE cursor_employee
END
------------
--Trigger example
CREATE TRIGGER IncreaseSalaryOnInsert
ON Employees
AFTER INSERT
AS
BEGIN
    UPDATE Employees
    SET Salary = Salary + 100
    WHERE EmployeeID IN (SELECT EmployeeID FROM inserted)
END

---  Join example
--This query returns only the rows that have matching values in both the Customers and Employees tables.
SELECT Customers.CustomerID, Customers.CompanyName, Employees.EmployeeID, Employees.FirstName, Employees.LastName, Employees.Salary
FROM Customers
INNER JOIN Employees
ON Customers.CustomerID = Employees.CustomerID

--This query returns all the rows from the Customers table along with the matching rows from the Employees table. If there is no match, the result will contain NULL values in the columns of the Employees table.
SELECT Customers.CustomerID, Customers.CompanyName, Employees.EmployeeID, Employees.FirstName, Employees.LastName, Employees.Salary
FROM Customers
LEFT JOIN Employees
ON Customers.CustomerID = Employees.CustomerID

--A RIGHT JOIN is similar to a LEFT JOIN, but it returns all the rows from the right table and the matching rows from the left table.
SELECT Customers.CustomerID, Customers.CompanyName, Employees.EmployeeID, Employees.FirstName, Employees.LastName, Employees.Salary
FROM Customers
RIGHT JOIN Employees
ON Customers.CustomerID = Employees.CustomerID

--A FULL JOIN combines the results of both a LEFT JOIN and a RIGHT JOIN, and returns all the rows from both tables, including any unmatched rows.
SELECT Customers.CustomerID, Customers.CompanyName, Employees.EmployeeID, Employees.FirstName, Employees.LastName, Employees.Salary
FROM Customers
FULL JOIN Employees
ON Customers.CustomerID = Employees.CustomerID


--The UNION operator combines the results of these two statements and returns a single result set with all the matching rows. 
--The columns in the result set must have the same number, data types and order as the columns in the first SELECT statement.
SELECT CustomerID, CompanyName, City FROM Customers
WHERE City = 'Santos'
UNION
SELECT EmployeeID, FirstName, LastName FROM Employees
WHERE City = 'Santos'


-- Count/ Group BY
SELECT Department, COUNT(EmployeeID) as 'Number of Employees'
FROM Employees
GROUP BY Department

-- HAVING
SELECT Customers.CompanyName, SUM(Employees.Salary) AS SalaryTotal  
FROM Employees  
INNER JOIN Customers 
ON Customers.CustomerID = Employees.CustomerID
GROUP BY Employees.CustomerID  
HAVING SUM(Salary) > 100000.00  
ORDER BY Employees.CustomerID ;  

--Example IF/ELSE/CASE
SELECT EmployeeID, FirstName, LastName, Salary,
CASE 
    WHEN Salary < 50000 THEN 'Low'
    WHEN Salary BETWEEN 50000 AND 100000 THEN 'Medium'
    ELSE 'High'
END AS SalaryRange,
IF (HireDate < '1/1/2022', 'Old Employee', 'New Employee') AS EmployeeType
FROM Employees

--In this example, the PIVOT operator is used to transform the rows from the "Employees" table into columns. 
--The SELECT statement first retrieves the "EmployeeID", "Department", "Salary" columns from the "Employees" table.
SELECT *
FROM
(
    SELECT EmployeeID, Department, Salary
    FROM Employees
) AS SourceTable
PIVOT
(
    SUM(Salary)
    FOR Department
    IN ([IT], [HR], [Accounting], [Marketing])
) AS PivotTable

--MAX, SUM, and AVG are commonly used aggregate functions that allow you to perform calculations on a set of values.
-- Other aggregate functions like MIN, COUNT, and GROUP BY can also be used to extract more information from the data.
SELECT MAX(Salary) as 'Highest Salary', SUM(Salary) as 'Total Salary', AVG(Salary) as 'Average Salary'
FROM Employees


-----In this example, a user-defined function named "DeleteDisabledEmployee" is created. 
--It takes one parameter as input, @employeeID, which represents the employee that needs to be deleted.
CREATE FUNCTION DeleteDisabledEmployee (@employeeID INT)
RETURNS INT
AS
BEGIN
    DECLARE @status INT
    SELECT @status = Status FROM Employees WHERE EmployeeID = @employeeID

    IF @status = 'Disabled'
    BEGIN
        DELETE FROM Employees WHERE EmployeeID = @employeeID
        RETURN 1
    END
    ELSE
    BEGIN
        RETURN 0
    END
END

------ example of a CREATE VIEW
CREATE VIEW EmployeeList AS
SELECT EmployeeID, FirstName, LastName, Salary
FROM Employees



--------- example of a BULK INSERT
BULK INSERT Employees
FROM 'C:\employees.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n'
)

--- Index Example
CREATE INDEX idx_LastName ON Employees(LastName)
DROP INDEX idx_LastName ON Employees

