# Ejecuta procedimientos almacenados y funciones en AdventureWorks2025
# Usar cuando la base de datos YA existe (no restaura .bak)
# Uso: .\configurar_bd.ps1
#      .\configurar_bd.ps1 -Server "localhost\SQLEXPRESS"

param(
    [string]$Server = "localhost",
    [string]$Database = "AdventureWorks2025"
)

$ErrorActionPreference = "Stop"
$DatabaseFolder = $PSScriptRoot

Write-Host "Configurando $Database en $Server ..." -ForegroundColor Cyan

# -I activa QUOTED_IDENTIFIER ON (requerido por tablas/triggers de AdventureWorks)
sqlcmd -S $Server -C -E -I -Q "SELECT 1" -h -1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] No se pudo conectar a SQL Server ($Server)" -ForegroundColor Red
    exit 1
}

$scripts = @(
    "01_schema_extensions.sql",
    "02_functions.sql",
    "03_stored_procedures_catalogos.sql",
    "04_stored_procedures_movimientos.sql",
    "05_stored_procedures_reportes.sql"
)

foreach ($script in $scripts) {
    $path = Join-Path $DatabaseFolder $script
    Write-Host "  -> $script" -ForegroundColor Gray
    sqlcmd -S $Server -C -E -I -d $Database -i $path
    if ($LASTEXITCODE -ne 0) { exit 1 }
}

$count = sqlcmd -S $Server -C -E -I -d $Database -Q "SELECT COUNT(*) FROM Sales.Customer" -h -1 -W
Write-Host "[OK] Listo. Clientes en BD: $count" -ForegroundColor Green
