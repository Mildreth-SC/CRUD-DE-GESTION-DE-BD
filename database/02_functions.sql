-- Funciones de apoyo - AdventureWorks2025
USE AdventureWorks2025;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER FUNCTION Sales.fn_NombreCliente (@CustomerID INT)
RETURNS NVARCHAR(256)
AS
BEGIN
    DECLARE @Nombre NVARCHAR(256);
    SELECT @Nombre = COALESCE(
        p.FirstName + N' ' + p.LastName,
        c.AccountNumber,
        N'Sin nombre'
    )
    FROM Sales.Customer c
    LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
    WHERE c.CustomerID = @CustomerID;
    RETURN @Nombre;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER FUNCTION Sales.fn_NombreVendedor (@BusinessEntityID INT)
RETURNS NVARCHAR(256)
AS
BEGIN
    DECLARE @Nombre NVARCHAR(256);
    SELECT @Nombre = COALESCE(p.FirstName + N' ' + p.LastName, N'Sin vendedor')
    FROM Person.Person p
    WHERE p.BusinessEntityID = @BusinessEntityID;
    RETURN @Nombre;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER FUNCTION Sales.fn_TotalOrden (@SalesOrderID INT)
RETURNS MONEY
AS
BEGIN
    DECLARE @Total MONEY;
    SELECT @Total = COALESCE(SUM(LineTotal), 0)
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @SalesOrderID;
    RETURN @Total;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER FUNCTION Sales.fn_OrdenAnulada (@SalesOrderID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @Anulado BIT;
    SELECT @Anulado = COALESCE(Anulado, 0)
    FROM Sales.SalesOrderHeader
    WHERE SalesOrderID = @SalesOrderID;
    RETURN COALESCE(@Anulado, 0);
END;
GO
