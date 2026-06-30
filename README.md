# CRUD-DE-GESTION-DE-BD

Sistema de gestión AdventureWorks2025 (esquema Sales) — Blazor, EF Core, Python, SQL Server.

## Requisitos
- .NET 8 SDK
- SQL Server con base `AdventureWorks2025`
- Python 3 (opcional, módulo `python/`)

## Configuración BD (una vez)

**No abras los `.sql` ni el `.ps1` con doble clic** (se abren en Bloc de notas).

### Forma fácil
1. Entra a la carpeta `database`
2. **Doble clic en `EJECUTAR_SCRIPTS.bat`** (ventana negra, no Bloc de notas)

### Desde PowerShell
```powershell
cd database
.\configurar_bd.ps1
```

### Error al crear ventas (`QUOTED_IDENTIFIER`)
Si en **Movimiento de Ventas** falla el INSERT con ese mensaje, en la carpeta `database` ejecuta **`REPARAR_VENTAS.bat`** (o vuelve a correr `configurar_bd.ps1` / `EJECUTAR_SCRIPTS.bat`).

## Ejecutar aplicación
```powershell
cd src\AdventureWorks.SalesApp
dotnet run
```

## Credenciales iniciales
- Email: `admin@adventureworks.local`
- Contraseña: `Admin123!`
