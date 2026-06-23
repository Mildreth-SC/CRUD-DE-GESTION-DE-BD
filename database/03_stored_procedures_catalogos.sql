-- Procedimientos almacenados - Catálogos (Maestros)
USE AdventureWorks2025;
GO

-- ========== CLIENTES ==========
CREATE OR ALTER PROCEDURE Sales.usp_Cliente_Listar
    @Busqueda NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.CustomerID,
        c.AccountNumber,
        c.TerritoryID,
        t.Name AS Territorio,
        Sales.fn_NombreCliente(c.CustomerID) AS NombreCompleto,
        c.ModifiedDate
    FROM Sales.Customer c
    LEFT JOIN Sales.SalesTerritory t ON c.TerritoryID = t.TerritoryID
    WHERE @Busqueda IS NULL
       OR c.AccountNumber LIKE N'%' + @Busqueda + N'%'
       OR Sales.fn_NombreCliente(c.CustomerID) LIKE N'%' + @Busqueda + N'%'
    ORDER BY c.CustomerID;
END;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Cliente_Obtener
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.CustomerID,
        c.PersonID,
        c.StoreID,
        c.TerritoryID,
        c.AccountNumber,
        Sales.fn_NombreCliente(c.CustomerID) AS NombreCompleto,
        c.ModifiedDate
    FROM Sales.Customer c
    WHERE c.CustomerID = @CustomerID;
END;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Cliente_Guardar
    @CustomerID INT = NULL OUTPUT,
    @AccountNumber NVARCHAR(10) = NULL,
    @TerritoryID INT = NULL,
    @PersonID INT = NULL,
    @StoreID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @CustomerID IS NULL OR @CustomerID = 0
    BEGIN
        INSERT INTO Sales.Customer (PersonID, StoreID, TerritoryID, ModifiedDate)
        VALUES (@PersonID, @StoreID, @TerritoryID, SYSDATETIME());
        SET @CustomerID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE Sales.Customer
        SET PersonID = @PersonID,
            StoreID = @StoreID,
            TerritoryID = @TerritoryID,
            ModifiedDate = SYSDATETIME()
        WHERE CustomerID = @CustomerID;
    END
END;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Cliente_Eliminar
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM Sales.SalesOrderHeader WHERE CustomerID = @CustomerID)
        THROW 50001, N'No se puede eliminar: el cliente tiene ventas registradas.', 1;
    DELETE FROM Sales.Customer WHERE CustomerID = @CustomerID;
END;
GO

-- ========== VENDEDORES ==========
CREATE OR ALTER PROCEDURE Sales.usp_Vendedor_Listar
    @Busqueda NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        sp.BusinessEntityID,
        Sales.fn_NombreVendedor(sp.BusinessEntityID) AS NombreCompleto,
        sp.TerritoryID,
        t.Name AS Territorio,
        sp.SalesQuota,
        sp.CommissionPct,
        sp.SalesYTD,
        sp.ModifiedDate
    FROM Sales.SalesPerson sp
    LEFT JOIN Sales.SalesTerritory t ON sp.TerritoryID = t.TerritoryID
    WHERE @Busqueda IS NULL
       OR Sales.fn_NombreVendedor(sp.BusinessEntityID) LIKE N'%' + @Busqueda + N'%'
    ORDER BY sp.BusinessEntityID;
END;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Vendedor_Obtener
    @BusinessEntityID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        sp.BusinessEntityID,
        Sales.fn_NombreVendedor(sp.BusinessEntityID) AS NombreCompleto,
        sp.TerritoryID,
        sp.SalesQuota,
        sp.Bonus,
        sp.CommissionPct,
        sp.SalesYTD,
        sp.SalesLastYear,
        sp.ModifiedDate
    FROM Sales.SalesPerson sp
    WHERE sp.BusinessEntityID = @BusinessEntityID;
END;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Vendedor_Guardar
    @BusinessEntityID INT,
    @TerritoryID INT = NULL,
    @SalesQuota MONEY = NULL,
    @Bonus MONEY = 0,
    @CommissionPct SMALLMONEY = 0
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM Sales.SalesPerson WHERE BusinessEntityID = @BusinessEntityID)
    BEGIN
        INSERT INTO Sales.SalesPerson (BusinessEntityID, TerritoryID, SalesQuota, Bonus, CommissionPct, SalesYTD, SalesLastYear, ModifiedDate)
        VALUES (@BusinessEntityID, @TerritoryID, @SalesQuota, @Bonus, @CommissionPct, 0, 0, SYSDATETIME());
    END
    ELSE
    BEGIN
        UPDATE Sales.SalesPerson
        SET TerritoryID = @TerritoryID,
            SalesQuota = @SalesQuota,
            Bonus = @Bonus,
            CommissionPct = @CommissionPct,
            ModifiedDate = SYSDATETIME()
        WHERE BusinessEntityID = @BusinessEntityID;
    END
END;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Vendedor_Eliminar
    @BusinessEntityID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM Sales.SalesOrderHeader WHERE SalesPersonID = @BusinessEntityID)
        THROW 50002, N'No se puede eliminar: el vendedor tiene ventas registradas.', 1;
    DELETE FROM Sales.SalesPerson WHERE BusinessEntityID = @BusinessEntityID;
END;
GO

-- ========== PRODUCTOS ==========
CREATE OR ALTER PROCEDURE Sales.usp_Producto_Listar
    @Busqueda NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.ProductID,
        p.Name,
        p.ProductNumber,
        p.ListPrice,
        p.StandardCost,
        p.Color,
        p.ProductSubcategoryID,
        sc.Name AS Subcategoria,
        c.ProductCategoryID,
        c.Name AS Categoria,
        p.SellStartDate,
        p.SellEndDate,
        p.ModifiedDate
    FROM Production.Product p
    LEFT JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
    WHERE @Busqueda IS NULL
       OR p.Name LIKE N'%' + @Busqueda + N'%'
       OR p.ProductNumber LIKE N'%' + @Busqueda + N'%'
    ORDER BY p.ProductID;
END;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Producto_Obtener
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.ProductID, p.Name, p.ProductNumber, p.ListPrice, p.StandardCost,
        p.Color, p.ProductSubcategoryID, p.SellStartDate, p.SellEndDate, p.ModifiedDate
    FROM Production.Product p
    WHERE p.ProductID = @ProductID;
END;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Producto_Guardar
    @ProductID INT = NULL OUTPUT,
    @Name NVARCHAR(50),
    @ProductNumber NVARCHAR(25),
    @ListPrice MONEY,
    @StandardCost MONEY = 0,
    @Color NVARCHAR(15) = NULL,
    @ProductSubcategoryID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @ProductID IS NULL OR @ProductID = 0
    BEGIN
        INSERT INTO Production.Product (
            Name, ProductNumber, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint,
            StandardCost, ListPrice, DaysToManufacture, SellStartDate, ModifiedDate, ProductSubcategoryID
        )
        VALUES (
            @Name, @ProductNumber, 0, 1, 100, 50,
            @StandardCost, @ListPrice, 0, SYSDATETIME(), SYSDATETIME(), @ProductSubcategoryID
        );
        SET @ProductID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE Production.Product
        SET Name = @Name,
            ProductNumber = @ProductNumber,
            ListPrice = @ListPrice,
            StandardCost = @StandardCost,
            Color = @Color,
            ProductSubcategoryID = @ProductSubcategoryID,
            ModifiedDate = SYSDATETIME()
        WHERE ProductID = @ProductID;
    END
END;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Producto_Eliminar
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM Sales.SalesOrderDetail WHERE ProductID = @ProductID)
        THROW 50003, N'No se puede eliminar: el producto tiene ventas registradas.', 1;
    DELETE FROM Production.Product WHERE ProductID = @ProductID;
END;
GO

-- ========== SUBCATEGORÍAS ==========
CREATE OR ALTER PROCEDURE Sales.usp_Subcategoria_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT sc.ProductSubcategoryID, sc.Name, sc.ProductCategoryID, c.Name AS Categoria, sc.ModifiedDate
    FROM Production.ProductSubcategory sc
    INNER JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
    ORDER BY sc.ProductSubcategoryID;
END;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Subcategoria_Guardar
    @ProductSubcategoryID INT = NULL OUTPUT,
    @Name NVARCHAR(50),
    @ProductCategoryID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF @ProductSubcategoryID IS NULL OR @ProductSubcategoryID = 0
    BEGIN
        INSERT INTO Production.ProductSubcategory (Name, ProductCategoryID, ModifiedDate)
        VALUES (@Name, @ProductCategoryID, SYSDATETIME());
        SET @ProductSubcategoryID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE Production.ProductSubcategory
        SET Name = @Name, ProductCategoryID = @ProductCategoryID, ModifiedDate = SYSDATETIME()
        WHERE ProductSubcategoryID = @ProductSubcategoryID;
    END
END;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Subcategoria_Eliminar
    @ProductSubcategoryID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM Production.Product WHERE ProductSubcategoryID = @ProductSubcategoryID)
        THROW 50004, N'No se puede eliminar: existen productos con esta subcategoría.', 1;
    DELETE FROM Production.ProductSubcategory WHERE ProductSubcategoryID = @ProductSubcategoryID;
END;
GO

-- ========== CATEGORÍAS ==========
CREATE OR ALTER PROCEDURE Sales.usp_Categoria_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProductCategoryID, Name, ModifiedDate
    FROM Production.ProductCategory
    ORDER BY ProductCategoryID;
END;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Categoria_Guardar
    @ProductCategoryID INT = NULL OUTPUT,
    @Name NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    IF @ProductCategoryID IS NULL OR @ProductCategoryID = 0
    BEGIN
        INSERT INTO Production.ProductCategory (Name, ModifiedDate)
        VALUES (@Name, SYSDATETIME());
        SET @ProductCategoryID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE Production.ProductCategory
        SET Name = @Name, ModifiedDate = SYSDATETIME()
        WHERE ProductCategoryID = @ProductCategoryID;
    END
END;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Categoria_Eliminar
    @ProductCategoryID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM Production.ProductSubcategory WHERE ProductCategoryID = @ProductCategoryID)
        THROW 50005, N'No se puede eliminar: existen subcategorías asociadas.', 1;
    DELETE FROM Production.ProductCategory WHERE ProductCategoryID = @ProductCategoryID;
END;
GO

-- ========== TERRITORIOS ==========
CREATE OR ALTER PROCEDURE Sales.usp_Territorio_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TerritoryID, Name, CountryRegionCode, [Group], SalesYTD, SalesLastYear, ModifiedDate
    FROM Sales.SalesTerritory
    ORDER BY TerritoryID;
END;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Territorio_Guardar
    @TerritoryID INT = NULL OUTPUT,
    @Name NVARCHAR(50),
    @CountryRegionCode NVARCHAR(3),
    @Group NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    IF @TerritoryID IS NULL OR @TerritoryID = 0
    BEGIN
        INSERT INTO Sales.SalesTerritory (Name, CountryRegionCode, [Group], SalesYTD, SalesLastYear, CostYTD, CostLastYear, ModifiedDate)
        VALUES (@Name, @CountryRegionCode, @Group, 0, 0, 0, 0, SYSDATETIME());
        SET @TerritoryID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE Sales.SalesTerritory
        SET Name = @Name, CountryRegionCode = @CountryRegionCode, [Group] = @Group, ModifiedDate = SYSDATETIME()
        WHERE TerritoryID = @TerritoryID;
    END
END;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Territorio_Eliminar
    @TerritoryID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM Sales.Customer WHERE TerritoryID = @TerritoryID)
        OR EXISTS (SELECT 1 FROM Sales.SalesOrderHeader WHERE TerritoryID = @TerritoryID)
        THROW 50006, N'No se puede eliminar: el territorio está en uso.', 1;
    DELETE FROM Sales.SalesTerritory WHERE TerritoryID = @TerritoryID;
END;
GO
