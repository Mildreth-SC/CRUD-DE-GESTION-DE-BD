@echo off
REM Corrige error QUOTED_IDENTIFIER en Movimiento de Ventas
REM Ejecutar si al crear ventas aparece: SET options have incorrect settings
set SERVER=localhost
set DATABASE=AdventureWorks2025

echo Reparando procedimientos de ventas en %DATABASE%...
sqlcmd -S %SERVER% -C -E -I -d %DATABASE% -i "%~dp004_stored_procedures_movimientos.sql"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Revisa que SQL Server este activo y que exista la base %DATABASE%.
    pause
    exit /b 1
)
echo [OK] Procedimientos de ventas actualizados. Reinicia la app y prueba de nuevo.
pause
