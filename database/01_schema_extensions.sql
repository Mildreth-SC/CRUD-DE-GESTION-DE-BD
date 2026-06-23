-- AdventureWorks2025 - Extensiones para Movimiento de Ventas y Administración
-- Ejecutar en la base de datos AdventureWorks2025

USE AdventureWorks2025;
GO

-- Bandera de anulación en órdenes de venta
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'Sales.SalesOrderHeader')
      AND name = N'Anulado'
)
BEGIN
    ALTER TABLE Sales.SalesOrderHeader
    ADD Anulado BIT NOT NULL CONSTRAINT DF_SalesOrderHeader_Anulado DEFAULT (0);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'Sales.SalesOrderHeader')
      AND name = N'FechaAnulacion'
)
BEGIN
    ALTER TABLE Sales.SalesOrderHeader
    ADD FechaAnulacion DATETIME2 NULL;
END
GO

-- Esquema de aplicación para roles extendidos
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'App')
    EXEC('CREATE SCHEMA App');
GO

IF OBJECT_ID(N'App.ModuloAcceso', N'U') IS NULL
BEGIN
    CREATE TABLE App.ModuloAcceso (
        ModuloAccesoId INT IDENTITY(1,1) PRIMARY KEY,
        UserId NVARCHAR(450) NOT NULL,
        Modulo NVARCHAR(100) NOT NULL,
        PuedeLeer BIT NOT NULL DEFAULT 1,
        PuedeEscribir BIT NOT NULL DEFAULT 0,
        CONSTRAINT UQ_ModuloAcceso_User_Modulo UNIQUE (UserId, Modulo)
    );
END
GO
