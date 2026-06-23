@echo off
title Configurar AdventureWorks2025
color 0A
cd /d "%~dp0"

echo ============================================
echo   CONFIGURAR BASE DE DATOS
echo   AdventureWorks2025
echo ============================================
echo.

where sqlcmd >nul 2>&1
if errorlevel 1 (
    echo [ERROR] No se encuentra sqlcmd.
    echo Instale SQL Server o las herramientas de linea de comandos.
    echo.
    pause
    exit /b 1
)

set SERVER=localhost
set DATABASE=AdventureWorks2025

echo Servidor: %SERVER%
echo Base de datos: %DATABASE%
echo.
echo Ejecutando scripts...
echo.

sqlcmd -S %SERVER% -C -E -I -d %DATABASE% -i "%~dp001_schema_extensions.sql"
if errorlevel 1 goto error

sqlcmd -S %SERVER% -C -E -I -d %DATABASE% -i "%~dp002_functions.sql"
if errorlevel 1 goto error

sqlcmd -S %SERVER% -C -E -I -d %DATABASE% -i "%~dp003_stored_procedures_catalogos.sql"
if errorlevel 1 goto error

sqlcmd -S %SERVER% -C -E -I -d %DATABASE% -i "%~dp004_stored_procedures_movimientos.sql"
if errorlevel 1 goto error

sqlcmd -S %SERVER% -C -E -I -d %DATABASE% -i "%~dp005_stored_procedures_reportes.sql"
if errorlevel 1 goto error

echo.
echo ============================================
echo   LISTO - Scripts ejecutados correctamente
echo ============================================
echo.
sqlcmd -S %SERVER% -C -E -I -d %DATABASE% -Q "SELECT COUNT(*) AS Clientes FROM Sales.Customer" -W
echo.
pause
exit /b 0

:error
echo.
echo [ERROR] Fallo al ejecutar un script. Revise el mensaje de arriba.
echo.
pause
exit /b 1
