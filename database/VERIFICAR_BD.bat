@echo off
title Verificar AdventureWorks2025
cd /d "%~dp0"

set SERVER=localhost
set DATABASE=AdventureWorks2025

echo ============================================
echo   VERIFICACION DE BASE DE DATOS
echo ============================================
echo.

where sqlcmd >nul 2>&1
if errorlevel 1 (
    echo [ERROR] sqlcmd no encontrado.
    pause
    exit /b 1
)

echo [1] Conexion a SQL Server...
sqlcmd -S %SERVER% -C -E -Q "SELECT @@VERSION" -h -1 -W
if errorlevel 1 goto error
echo.

echo [2] Base de datos AdventureWorks2025...
sqlcmd -S %SERVER% -C -E -Q "SELECT name FROM sys.databases WHERE name='%DATABASE%'" -h -1 -W
if errorlevel 1 goto error
echo.

echo [3] Registros en tablas principales...
sqlcmd -S %SERVER% -C -E -d %DATABASE% -Q "SELECT 'Clientes' AS Tabla, COUNT(*) AS Total FROM Sales.Customer UNION ALL SELECT 'Productos', COUNT(*) FROM Production.Product UNION ALL SELECT 'Ventas', COUNT(*) FROM Sales.SalesOrderHeader" -W
echo.

echo [4] Procedimientos almacenados del proyecto...
sqlcmd -S %SERVER% -C -E -d %DATABASE% -Q "SELECT COUNT(*) AS TotalSPs FROM sys.procedures WHERE schema_id=SCHEMA_ID('Sales') AND name LIKE 'usp_%'" -h -1 -W
echo.

echo [5] Funciones del proyecto...
sqlcmd -S %SERVER% -C -E -d %DATABASE% -Q "SELECT name FROM sys.objects WHERE schema_id=SCHEMA_ID('Sales') AND type IN ('FN','IF','TF') AND name LIKE 'fn_%'" -W
echo.

echo ============================================
echo   Si ve numeros arriba, la BD esta OK.
echo ============================================
pause
exit /b 0

:error
echo [ERROR] Revise que SQL Server este activo y exista AdventureWorks2025.
pause
exit /b 1
