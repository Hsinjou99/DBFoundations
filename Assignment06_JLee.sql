--*************************************************************************--
-- Title: Assignment06
-- Author: JLee
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2022-11-20,JLee,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_JLee')
	 Begin 
	  Alter Database [Assignment06DB_JLee] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_JLee;
	 End
	Create Database Assignment06DB_JLee;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_JLee;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

--Select CategoryID, CategoryName
--From Categories
Go

Create View [vCategories] With Schemabinding As
Select CategoryID, CategoryName
From dbo.Categories;
Go

Create View [vProducts] With Schemabinding As
Select ProductID, ProductName, CategoryID, UnitPrice
From dbo.Products;
Go

Create View [vEmployees] With Schemabinding As
Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
From dbo.Employees;
Go

Create View [vInventories] With Schemabinding As
Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
From dbo.Inventories;
Go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On Categories to Public;
Deny Select On Products to Public;
Deny Select On Employees to Public
Deny Select On Inventories to Public;

Grant Select On vCategories to Public;
Grant Select On vProducts to Public;
Grant Select On vEmployees to Public;
Grant Select On vInventories to Public;
Go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00

--Select CategoryName, ProductName, UnitPrice
--From Categories Join Products 
--  On Categories.CategoryID = Products.CategoryID
--Order By CategoryName, ProductName
Create View [vProductsByCategories] As
Select Top 100000 CategoryName, ProductName, UnitPrice
From Categories Join Products 
  On Categories.CategoryID = Products.CategoryID
Order By CategoryName, ProductName;
Go
-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33

--Select ProductName, InventoryDate, [Count]
--From Products Join Inventories
--  On Products.ProductID = Inventories.ProductID
--Order By ProductName, InventoryDate, [Count]

Create View [vInventoriesByProductsByDates] As
Select Top 100000 ProductName, InventoryDate, [Count]
From Products Join Inventories
  On Products.ProductID = Inventories.ProductID
Order By ProductName, InventoryDate, [Count]
Go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

--Select Distinct InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName As EmployeeName
--From Inventories Join Employees
--  On Inventories.EmployeeID = Employees.EmployeeID
--Order By InventoryDate

Create View [vInventoriesByEmployeesByDates] As
Select Distinct Top 100000 InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName As EmployeeName
From Inventories Join Employees
  On Inventories.EmployeeID = Employees.EmployeeID
Order By InventoryDate;
Go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37

--Select CategoryName, ProductName, InventoryDate, [Count]
--From Categories Join Products
--  On Categories.CategoryID = Products.CategoryID Join Inventories
--  On Products.ProductID = Inventories.ProductID
--Order By CategoryName, ProductName, InventoryDate, [Count]

Create View [vInventoriesByProductsByCategories] As
Select Top 100000 CategoryName, ProductName, InventoryDate, [Count]
From Categories Join Products
  On Categories.CategoryID = Products.CategoryID Join Inventories
  On Products.ProductID = Inventories.ProductID
Order By CategoryName, ProductName, InventoryDate, [Count];
Go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  Côte de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaraná Fantástica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalikööri	      2017-01-01	  57	  Steven Buchanan

--Select CategoryName, ProductName, InventoryDate, [Count], EmployeeFirstName + ' ' + EmployeeLastName As EmployeeName
--From Categories Join Products
--  On Categories.CategoryID = Products.CategoryID Join Inventories
--  On Products.ProductID = Inventories.ProductID Join Employees
--  On Inventories.EmployeeID = Employees.EmployeeID
--Order By InventoryDate, CategoryName, ProductName, [Count], EmployeeName

Create View [vInventoriesByProductsByEmployees] As
Select Top 100000 CategoryName, ProductName, InventoryDate, [Count], EmployeeFirstName + ' ' + EmployeeLastName As EmployeeName
From Categories Join Products
  On Categories.CategoryID = Products.CategoryID Join Inventories
  On Products.ProductID = Inventories.ProductID Join Employees
  On Inventories.EmployeeID = Employees.EmployeeID
Order By InventoryDate, CategoryName, ProductName, [Count], EmployeeName;
Go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth

--Select CategoryName, ProductName, InventoryDate, [Count], EmployeeFirstName + ' ' + EmployeeLastName As EmployeeName
--From Categories Join Products
--  On Categories.CategoryID = Products.CategoryID Join Inventories
--  On Products.ProductID = Inventories.ProductID Join Employees
--  On Inventories.EmployeeID = Employees.EmployeeID
--Where Products.ProductID In (Select Products.ProductID From Products Where ProductName In ('Chai', 'Chang'))

Create View [vInventoriesForChaiAndChangByEmployees] As
Select Top 100000 CategoryName, ProductName, InventoryDate, [Count], EmployeeFirstName + ' ' + EmployeeLastName As EmployeeName
From Categories Join Products
  On Categories.CategoryID = Products.CategoryID Join Inventories
  On Products.ProductID = Inventories.ProductID Join Employees
  On Inventories.EmployeeID = Employees.EmployeeID
Where Products.ProductID In (Select Products.ProductID From Products Where ProductName In ('Chai', 'Chang'))
Order By InventoryDate, CategoryName, ProductName, [Count], EmployeeName;
Go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King

--Select Man.EmployeeFirstName + ' ' + Man.EmployeeLastName As Manager, Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName As Employee
--From Employees As Emp Inner Join Employees As Man
--  On Emp.ManagerID = Man.EmployeeID

Create View [vEmployeesByManager] As
Select Top 100000 Man.EmployeeFirstName + ' ' + Man.EmployeeLastName As Manager, Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName As Employee
From Employees As Emp Inner Join Employees As Man
  On Emp.ManagerID = Man.EmployeeID
Order By Manager, Employee;
Go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01		 49		7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01		 59		 9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01		 27		 7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01		37		9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    24	        2017-01-01		20		5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    101	        2017-02-01		30		7	          Robert King
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    178	        2017-03-01		40		9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth

--Select Categories.CategoryID, CategoryName, Products.ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, [Count], Employees.EmployeeID, EmployeeFirstName + EmployeeLastName As Employee
--From Categories Join Products
--  On Categories.CategoryID = Products.CategoryID Join Inventories
--  On Products.ProductID = Inventories.ProductID Join Employees
--  On Inventories.EmployeeID = Employees.EmployeeID
--Order By CategoryName, ProductName, InventoryID, Employee
--Go

--Select [vCategories].CategoryID, CategoryName, [vProducts].ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, [Count], [vEmployees].EmployeeID, EmployeeFirstName + EmployeeLastName As Employee
--From [vCategories] Join [vProducts]
--  On [vCategories].CategoryID = [vProducts].CategoryID Join [vInventories]
--  On [vProducts].ProductID = [vInventories].ProductID Join [vEmployees]
--  On [vInventories].EmployeeID = [vEmployees].EmployeeID
--Order By CategoryName, ProductName, InventoryID, Employee
--Go

Create View [vInventoriesByProductsByCategoriesByEmployees] As
Select Top 100000 [vCategories].CategoryID, CategoryName, [vProducts].ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, [Count], [vEmployees].EmployeeID, EmployeeFirstName + EmployeeLastName As Employee
From [vCategories] Join [vProducts]
  On [vCategories].CategoryID = [vProducts].CategoryID Join [vInventories]
  On [vProducts].ProductID = [vInventories].ProductID Join [vEmployees]
  On [vInventories].EmployeeID = [vEmployees].EmployeeID
Order By CategoryName, ProductName, InventoryID, Employee
Go

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/