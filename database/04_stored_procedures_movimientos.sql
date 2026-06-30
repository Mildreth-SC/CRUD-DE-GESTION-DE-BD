-- Procedimientos almacenados - Movimiento de Ventas
USE AdventureWorks2025;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Venta_Listar
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @CustomerID INT = NULL,
    @SalesPersonID INT = NULL,
    @IncluirAnuladas BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        h.SalesOrderID,
        h.SalesOrderNumber,
        h.OrderDate,
        h.CustomerID,
        Sales.fn_NombreCliente(h.CustomerID) AS Cliente,
        h.SalesPersonID,
        Sales.fn_NombreVendedor(h.SalesPersonID) AS Vendedor,
        h.TerritoryID,
        t.Name AS Territorio,
        h.SubTotal,
        h.TaxAmt,
        h.Freight,
        h.TotalDue,
        COALESCE(h.Anulado, 0) AS Anulado,
        h.FechaAnulacion,
        h.Status
    FROM Sales.SalesOrderHeader h
    LEFT JOIN Sales.SalesTerritory t ON h.TerritoryID = t.TerritoryID
    WHERE (@FechaInicio IS NULL OR CAST(h.OrderDate AS DATE) >= @FechaInicio)
      AND (@FechaFin IS NULL OR CAST(h.OrderDate AS DATE) <= @FechaFin)
      AND (@CustomerID IS NULL OR h.CustomerID = @CustomerID)
      AND (@SalesPersonID IS NULL OR h.SalesPersonID = @SalesPersonID)
      AND (@IncluirAnuladas = 1 OR COALESCE(h.Anulado, 0) = 0)
    ORDER BY h.OrderDate DESC, h.SalesOrderID DESC;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Venta_Obtener
    @SalesOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        h.SalesOrderID,
        h.SalesOrderNumber,
        h.OrderDate,
        h.DueDate,
        h.CustomerID,
        Sales.fn_NombreCliente(h.CustomerID) AS Cliente,
        h.SalesPersonID,
        Sales.fn_NombreVendedor(h.SalesPersonID) AS Vendedor,
        h.TerritoryID,
        t.Name AS Territorio,
        h.SubTotal,
        h.TaxAmt,
        h.Freight,
        h.TotalDue,
        COALESCE(h.Anulado, 0) AS Anulado,
        h.FechaAnulacion,
        h.Comment
    FROM Sales.SalesOrderHeader h
    LEFT JOIN Sales.SalesTerritory t ON h.TerritoryID = t.TerritoryID
    WHERE h.SalesOrderID = @SalesOrderID;

    SELECT
        d.SalesOrderDetailID,
        d.SalesOrderID,
        d.ProductID,
        p.Name AS Producto,
        p.ProductNumber,
        d.OrderQty,
        d.UnitPrice,
        d.UnitPriceDiscount,
        d.LineTotal
    FROM Sales.SalesOrderDetail d
    INNER JOIN Production.Product p ON d.ProductID = p.ProductID
    WHERE d.SalesOrderID = @SalesOrderID
    ORDER BY d.SalesOrderDetailID;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Venta_Crear
    @CustomerID INT,
    @SalesPersonID INT = NULL,
    @TerritoryID INT = NULL,
    @Comment NVARCHAR(128) = NULL,
    @SalesOrderID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET ANSI_NULLS ON;
    SET QUOTED_IDENTIFIER ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @BillToAddressID INT;
        DECLARE @ShipToAddressID INT;
        DECLARE @ShipMethodID INT = 1;
        DECLARE @BusinessEntityID INT;

        IF @TerritoryID IS NULL
            SELECT @TerritoryID = TerritoryID FROM Sales.Customer WHERE CustomerID = @CustomerID;

        SELECT @BusinessEntityID = COALESCE(PersonID, StoreID)
        FROM Sales.Customer
        WHERE CustomerID = @CustomerID;

        SELECT TOP 1 @BillToAddressID = AddressID
        FROM Person.BusinessEntityAddress
        WHERE BusinessEntityID = @BusinessEntityID
        ORDER BY AddressID;

        IF @BillToAddressID IS NULL
            SELECT TOP 1
                @BillToAddressID = BillToAddressID,
                @ShipToAddressID = ShipToAddressID,
                @ShipMethodID = ShipMethodID
            FROM Sales.SalesOrderHeader
            WHERE CustomerID = @CustomerID
            ORDER BY SalesOrderID DESC;

        IF @BillToAddressID IS NULL
            SELECT TOP 1
                @BillToAddressID = BillToAddressID,
                @ShipToAddressID = ShipToAddressID,
                @ShipMethodID = ShipMethodID
            FROM Sales.SalesOrderHeader
            ORDER BY SalesOrderID;

        SET @ShipToAddressID = COALESCE(@ShipToAddressID, @BillToAddressID);

        IF @BillToAddressID IS NULL
            THROW 50020, N'No se encontró dirección de facturación para el cliente.', 1;

        INSERT INTO Sales.SalesOrderHeader (
            RevisionNumber, OrderDate, DueDate, Status, OnlineOrderFlag,
            CustomerID, SalesPersonID, TerritoryID,
            BillToAddressID, ShipToAddressID, ShipMethodID,
            SubTotal, TaxAmt, Freight, Comment, ModifiedDate, Anulado
        )
        VALUES (
            1, SYSDATETIME(), DATEADD(day, 7, SYSDATETIME()), 1, 0,
            @CustomerID, @SalesPersonID, @TerritoryID,
            @BillToAddressID, @ShipToAddressID, @ShipMethodID,
            0, 0, 0, @Comment, SYSDATETIME(), 0
        );
        SET @SalesOrderID = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Venta_ActualizarEncabezado
    @SalesOrderID INT,
    @CustomerID INT,
    @SalesPersonID INT = NULL,
    @TerritoryID INT = NULL,
    @Comment NVARCHAR(128) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET ANSI_NULLS ON;
    SET QUOTED_IDENTIFIER ON;
    IF Sales.fn_OrdenAnulada(@SalesOrderID) = 1
        THROW 50010, N'No se puede modificar una venta anulada.', 1;

    UPDATE Sales.SalesOrderHeader
    SET CustomerID = @CustomerID,
        SalesPersonID = @SalesPersonID,
        TerritoryID = @TerritoryID,
        Comment = @Comment,
        ModifiedDate = SYSDATETIME()
    WHERE SalesOrderID = @SalesOrderID;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Venta_AgregarDetalle
    @SalesOrderID INT,
    @ProductID INT,
    @OrderQty SMALLINT,
    @UnitPrice MONEY,
    @UnitPriceDiscount MONEY = 0,
    @SalesOrderDetailID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET ANSI_NULLS ON;
    SET QUOTED_IDENTIFIER ON;
    IF Sales.fn_OrdenAnulada(@SalesOrderID) = 1
        THROW 50011, N'No se puede agregar ítems a una venta anulada.', 1;

    DECLARE @SpecialOfferID INT;

    SELECT TOP 1 @SpecialOfferID = SpecialOfferID
    FROM Sales.SpecialOfferProduct
    WHERE ProductID = @ProductID;

    -- Oferta 1 = "No Discount"; si el producto no tiene oferta, registrar el par en el catálogo
    IF @SpecialOfferID IS NULL
    BEGIN
        SET @SpecialOfferID = 1;

        IF NOT EXISTS (
            SELECT 1 FROM Sales.SpecialOfferProduct
            WHERE SpecialOfferID = @SpecialOfferID AND ProductID = @ProductID
        )
            INSERT INTO Sales.SpecialOfferProduct (SpecialOfferID, ProductID)
            VALUES (@SpecialOfferID, @ProductID);
    END

    INSERT INTO Sales.SalesOrderDetail (
        SalesOrderID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID,
        UnitPrice, UnitPriceDiscount, ModifiedDate
    )
    VALUES (
        @SalesOrderID, NULL, @OrderQty, @ProductID, @SpecialOfferID,
        @UnitPrice, @UnitPriceDiscount, SYSDATETIME()
    );
    SET @SalesOrderDetailID = SCOPE_IDENTITY();

    EXEC Sales.usp_Venta_RecalcularTotales @SalesOrderID;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Venta_ActualizarDetalle
    @SalesOrderDetailID INT,
    @OrderQty SMALLINT,
    @UnitPrice MONEY,
    @UnitPriceDiscount MONEY = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET ANSI_NULLS ON;
    SET QUOTED_IDENTIFIER ON;
    DECLARE @SalesOrderID INT;
    SELECT @SalesOrderID = SalesOrderID FROM Sales.SalesOrderDetail WHERE SalesOrderDetailID = @SalesOrderDetailID;

    IF Sales.fn_OrdenAnulada(@SalesOrderID) = 1
        THROW 50012, N'No se puede modificar ítems de una venta anulada.', 1;

    UPDATE Sales.SalesOrderDetail
    SET OrderQty = @OrderQty,
        UnitPrice = @UnitPrice,
        UnitPriceDiscount = @UnitPriceDiscount,
        ModifiedDate = SYSDATETIME()
    WHERE SalesOrderDetailID = @SalesOrderDetailID;

    EXEC Sales.usp_Venta_RecalcularTotales @SalesOrderID;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Venta_EliminarDetalle
    @SalesOrderDetailID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET ANSI_NULLS ON;
    SET QUOTED_IDENTIFIER ON;
    DECLARE @SalesOrderID INT;
    SELECT @SalesOrderID = SalesOrderID FROM Sales.SalesOrderDetail WHERE SalesOrderDetailID = @SalesOrderDetailID;

    IF Sales.fn_OrdenAnulada(@SalesOrderID) = 1
        THROW 50013, N'No se puede eliminar ítems de una venta anulada.', 1;

    DELETE FROM Sales.SalesOrderDetail WHERE SalesOrderDetailID = @SalesOrderDetailID;
    EXEC Sales.usp_Venta_RecalcularTotales @SalesOrderID;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Venta_RecalcularTotales
    @SalesOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET ANSI_NULLS ON;
    SET QUOTED_IDENTIFIER ON;
    DECLARE @SubTotal MONEY = Sales.fn_TotalOrden(@SalesOrderID);
    DECLARE @TaxAmt MONEY = @SubTotal * 0.08;
    DECLARE @Freight MONEY = CASE WHEN @SubTotal > 0 THEN 15.00 ELSE 0 END;

    UPDATE Sales.SalesOrderHeader
    SET SubTotal = @SubTotal,
        TaxAmt = @TaxAmt,
        Freight = @Freight,
        ModifiedDate = SYSDATETIME()
    WHERE SalesOrderID = @SalesOrderID;
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Venta_Anular
    @SalesOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET ANSI_NULLS ON;
    SET QUOTED_IDENTIFIER ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        IF Sales.fn_OrdenAnulada(@SalesOrderID) = 1
            THROW 50014, N'La venta ya está anulada.', 1;

        DECLARE @SalesPersonID INT, @TerritoryID INT, @Total MONEY;
        SELECT @SalesPersonID = SalesPersonID, @TerritoryID = TerritoryID, @Total = TotalDue
        FROM Sales.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID;

        UPDATE Sales.SalesOrderHeader
        SET Anulado = 1,
            FechaAnulacion = SYSDATETIME(),
            Status = 5,
            ModifiedDate = SYSDATETIME()
        WHERE SalesOrderID = @SalesOrderID;

        IF @SalesPersonID IS NOT NULL
            UPDATE Sales.SalesPerson
            SET SalesYTD = SalesYTD - @Total, ModifiedDate = SYSDATETIME()
            WHERE BusinessEntityID = @SalesPersonID;

        IF @TerritoryID IS NOT NULL
            UPDATE Sales.SalesTerritory
            SET SalesYTD = SalesYTD - @Total, ModifiedDate = SYSDATETIME()
            WHERE TerritoryID = @TerritoryID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE Sales.usp_Venta_Confirmar
    @SalesOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET ANSI_NULLS ON;
    SET QUOTED_IDENTIFIER ON;
    IF Sales.fn_OrdenAnulada(@SalesOrderID) = 1
        THROW 50015, N'No se puede confirmar una venta anulada.', 1;

    DECLARE @SalesPersonID INT, @TerritoryID INT, @Total MONEY, @Status TINYINT;
    SELECT @SalesPersonID = SalesPersonID, @TerritoryID = TerritoryID, @Total = TotalDue, @Status = Status
    FROM Sales.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID;

    IF @Status = 5
        THROW 50016, N'La venta está cancelada.', 1;

    IF @SalesPersonID IS NOT NULL
        UPDATE Sales.SalesPerson
        SET SalesYTD = SalesYTD + @Total, ModifiedDate = SYSDATETIME()
        WHERE BusinessEntityID = @SalesPersonID;

    IF @TerritoryID IS NOT NULL
        UPDATE Sales.SalesTerritory
        SET SalesYTD = SalesYTD + @Total, ModifiedDate = SYSDATETIME()
        WHERE TerritoryID = @TerritoryID;

    UPDATE Sales.SalesOrderHeader
    SET Status = 3, ModifiedDate = SYSDATETIME()
    WHERE SalesOrderID = @SalesOrderID;
END;
GO
