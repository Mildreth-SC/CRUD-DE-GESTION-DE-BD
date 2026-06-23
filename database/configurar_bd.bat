@echo off
REM Ejecuta SPs y funciones (BD ya debe existir)
set SERVER=localhost
set DATABASE=AdventureWorks2025

echo Configurando %DATABASE% en %SERVER%...

sqlcmd -S %SERVER% -C -E -d %DATABASE% -i "%~dp001_schema_extensions.sql"
sqlcmd -S %SERVER% -C -E -d %DATABASE% -i "%~dp002_functions.sql"
sqlcmd -S %SERVER% -C -E -d %DATABASE% -i "%~dp003_stored_procedures_catalogos.sql"
sqlcmd -S %SERVER% -C -E -d %DATABASE% -i "%~dp004_stored_procedures_movimientos.sql"
sqlcmd -S %SERVER% -C -E -d %DATABASE% -i "%~dp005_stored_procedures_reportes.sql"

echo Listo.
pause
