-- Procedimientos almacenados - Reportes
USE AdventureWorks2025;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Reporte_DetalleVentas
    @FechaInicio DATE,
    @FechaFin DATE,
    @CustomerID INT = NULL,
    @SalesPersonID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        h.SalesOrderID,
        h.SalesOrderNumber,
        h.OrderDate,
        Sales.fn_NombreCliente(h.CustomerID) AS Cliente,
        Sales.fn_NombreVendedor(h.SalesPersonID) AS Vendedor,
        p.Name AS Producto,
        d.OrderQty,
        d.UnitPrice,
        d.LineTotal,
        COALESCE(h.Anulado, 0) AS Anulado
    FROM Sales.SalesOrderHeader h
    INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID = d.SalesOrderID
    INNER JOIN Production.Product p ON d.ProductID = p.ProductID
    WHERE CAST(h.OrderDate AS DATE) BETWEEN @FechaInicio AND @FechaFin
      AND COALESCE(h.Anulado, 0) = 0
      AND (@CustomerID IS NULL OR h.CustomerID = @CustomerID)
      AND (@SalesPersonID IS NULL OR h.SalesPersonID = @SalesPersonID)
    ORDER BY h.OrderDate, h.SalesOrderID, d.SalesOrderDetailID;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Reporte_ResumenVentas
    @FechaInicio DATE,
    @FechaFin DATE,
    @CustomerID INT = NULL,
    @SalesPersonID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        Sales.fn_NombreCliente(h.CustomerID) AS Cliente,
        Sales.fn_NombreVendedor(h.SalesPersonID) AS Vendedor,
        COUNT(DISTINCT h.SalesOrderID) AS CantidadOrdenes,
        SUM(h.SubTotal) AS SubTotal,
        SUM(h.TaxAmt) AS Impuestos,
        SUM(h.Freight) AS Flete,
        SUM(h.TotalDue) AS TotalVentas
    FROM Sales.SalesOrderHeader h
    WHERE CAST(h.OrderDate AS DATE) BETWEEN @FechaInicio AND @FechaFin
      AND COALESCE(h.Anulado, 0) = 0
      AND (@CustomerID IS NULL OR h.CustomerID = @CustomerID)
      AND (@SalesPersonID IS NULL OR h.SalesPersonID = @SalesPersonID)
    GROUP BY h.CustomerID, h.SalesPersonID
    ORDER BY TotalVentas DESC;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Reporte_DetallePorProducto
    @FechaInicio DATE,
    @FechaFin DATE,
    @ProductID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.ProductID,
        p.Name AS Producto,
        p.ProductNumber,
        h.OrderDate,
        h.SalesOrderNumber,
        d.OrderQty,
        d.UnitPrice,
        d.LineTotal
    FROM Sales.SalesOrderHeader h
    INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID = d.SalesOrderID
    INNER JOIN Production.Product p ON d.ProductID = p.ProductID
    WHERE CAST(h.OrderDate AS DATE) BETWEEN @FechaInicio AND @FechaFin
      AND COALESCE(h.Anulado, 0) = 0
      AND (@ProductID IS NULL OR p.ProductID = @ProductID)
    ORDER BY p.Name, h.OrderDate;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Reporte_ResumenPorProducto
    @FechaInicio DATE,
    @FechaFin DATE,
    @ProductID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.ProductID,
        p.Name AS Producto,
        p.ProductNumber,
        SUM(d.OrderQty) AS CantidadVendida,
        SUM(d.LineTotal) AS TotalVentas
    FROM Sales.SalesOrderHeader h
    INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID = d.SalesOrderID
    INNER JOIN Production.Product p ON d.ProductID = p.ProductID
    WHERE CAST(h.OrderDate AS DATE) BETWEEN @FechaInicio AND @FechaFin
      AND COALESCE(h.Anulado, 0) = 0
      AND (@ProductID IS NULL OR p.ProductID = @ProductID)
    GROUP BY p.ProductID, p.Name, p.ProductNumber
    ORDER BY TotalVentas DESC;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Reporte_DetallePorCategoria
    @FechaInicio DATE,
    @FechaFin DATE,
    @ProductCategoryID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.ProductCategoryID,
        c.Name AS Categoria,
        p.Name AS Producto,
        h.OrderDate,
        h.SalesOrderNumber,
        d.OrderQty,
        d.LineTotal
    FROM Sales.SalesOrderHeader h
    INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID = d.SalesOrderID
    INNER JOIN Production.Product p ON d.ProductID = p.ProductID
    LEFT JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
    WHERE CAST(h.OrderDate AS DATE) BETWEEN @FechaInicio AND @FechaFin
      AND COALESCE(h.Anulado, 0) = 0
      AND (@ProductCategoryID IS NULL OR c.ProductCategoryID = @ProductCategoryID)
    ORDER BY c.Name, h.OrderDate;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Reporte_ResumenPorCategoria
    @FechaInicio DATE,
    @FechaFin DATE,
    @ProductCategoryID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.ProductCategoryID,
        c.Name AS Categoria,
        SUM(d.OrderQty) AS CantidadVendida,
        SUM(d.LineTotal) AS TotalVentas
    FROM Sales.SalesOrderHeader h
    INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID = d.SalesOrderID
    INNER JOIN Production.Product p ON d.ProductID = p.ProductID
    LEFT JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
    WHERE CAST(h.OrderDate AS DATE) BETWEEN @FechaInicio AND @FechaFin
      AND COALESCE(h.Anulado, 0) = 0
      AND (@ProductCategoryID IS NULL OR c.ProductCategoryID = @ProductCategoryID)
    GROUP BY c.ProductCategoryID, c.Name
    ORDER BY TotalVentas DESC;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Reporte_DetallePorTerritorio
    @FechaInicio DATE,
    @FechaFin DATE,
    @TerritoryID INT = NULL,
    @ProductCategoryID INT = NULL,
    @ProductID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        t.TerritoryID,
        t.Name AS Territorio,
        c.Name AS Categoria,
        p.Name AS Producto,
        h.OrderDate,
        h.SalesOrderNumber,
        d.OrderQty,
        d.LineTotal
    FROM Sales.SalesOrderHeader h
    INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID = d.SalesOrderID
    INNER JOIN Production.Product p ON d.ProductID = p.ProductID
    LEFT JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
    LEFT JOIN Sales.SalesTerritory t ON h.TerritoryID = t.TerritoryID
    WHERE CAST(h.OrderDate AS DATE) BETWEEN @FechaInicio AND @FechaFin
      AND COALESCE(h.Anulado, 0) = 0
      AND (@TerritoryID IS NULL OR h.TerritoryID = @TerritoryID)
      AND (@ProductCategoryID IS NULL OR c.ProductCategoryID = @ProductCategoryID)
      AND (@ProductID IS NULL OR p.ProductID = @ProductID)
    ORDER BY t.Name, c.Name, p.Name, h.OrderDate;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Reporte_ResumenPorTerritorio
    @FechaInicio DATE,
    @FechaFin DATE,
    @TerritoryID INT = NULL,
    @ProductCategoryID INT = NULL,
    @ProductID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        t.TerritoryID,
        t.Name AS Territorio,
        c.Name AS Categoria,
        p.Name AS Producto,
        SUM(d.OrderQty) AS CantidadVendida,
        SUM(d.LineTotal) AS TotalVentas
    FROM Sales.SalesOrderHeader h
    INNER JOIN Sales.SalesOrderDetail d ON h.SalesOrderID = d.SalesOrderID
    INNER JOIN Production.Product p ON d.ProductID = p.ProductID
    LEFT JOIN Production.ProductSubcategory sc ON p.ProductSubcategoryID = sc.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
    LEFT JOIN Sales.SalesTerritory t ON h.TerritoryID = t.TerritoryID
    WHERE CAST(h.OrderDate AS DATE) BETWEEN @FechaInicio AND @FechaFin
      AND COALESCE(h.Anulado, 0) = 0
      AND (@TerritoryID IS NULL OR h.TerritoryID = @TerritoryID)
      AND (@ProductCategoryID IS NULL OR c.ProductCategoryID = @ProductCategoryID)
      AND (@ProductID IS NULL OR p.ProductID = @ProductID)
    GROUP BY t.TerritoryID, t.Name, c.Name, p.Name
    ORDER BY TotalVentas DESC;
END;
GO
