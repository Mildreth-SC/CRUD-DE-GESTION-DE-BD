# CRUD-DE-GESTION-DE-BD

Sistema de gestión AdventureWorks2025 (esquema Sales) — Blazor, EF Core, Python, SQL Server.

## Requisitos
- .NET 8 SDK
- SQL Server con base `AdventureWorks2025`
- Python 3 (opcional, módulo `python/`)

## Configuración BD (una vez)
```powershell
cd database
.\configurar_bd.ps1
```

## Ejecutar aplicación
```powershell
cd src\AdventureWorks.SalesApp
dotnet run
```

## Credenciales iniciales
- Email: `admin@adventureworks.local`
- Contraseña: `Admin123!`
