using System.Data;
using AdventureWorks.SalesApp.Models;
using Dapper;

namespace AdventureWorks.SalesApp.Services;

public interface IReporteService
{
    Task<IEnumerable<ReporteDetalleVentaDto>> DetalleVentasAsync(FiltroReporteVentas filtro);
    Task<IEnumerable<ReporteResumenVentaDto>> ResumenVentasAsync(FiltroReporteVentas filtro);
    Task<IEnumerable<ReporteProductoDto>> DetallePorProductoAsync(FiltroReporteVentas filtro);
    Task<IEnumerable<ReporteProductoDto>> ResumenPorProductoAsync(FiltroReporteVentas filtro);
    Task<IEnumerable<ReporteCategoriaDto>> DetallePorCategoriaAsync(FiltroReporteVentas filtro);
    Task<IEnumerable<ReporteCategoriaDto>> ResumenPorCategoriaAsync(FiltroReporteVentas filtro);
    Task<IEnumerable<ReporteTerritorioDto>> DetallePorTerritorioAsync(FiltroReporteVentas filtro);
    Task<IEnumerable<ReporteTerritorioDto>> ResumenPorTerritorioAsync(FiltroReporteVentas filtro);
}

public class ReporteService : IReporteService
{
    private readonly ISqlConnectionFactory _connectionFactory;

    public ReporteService(ISqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IEnumerable<ReporteDetalleVentaDto>> DetalleVentasAsync(FiltroReporteVentas filtro)
    {
        using var conn = _connectionFactory.CreateConnection();
        return await conn.QueryAsync<ReporteDetalleVentaDto>("Sales.usp_Reporte_DetalleVentas", new
        {
            FechaInicio = filtro.FechaInicio.Date,
            FechaFin = filtro.FechaFin.Date,
            filtro.CustomerID,
            filtro.SalesPersonID
        }, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<ReporteResumenVentaDto>> ResumenVentasAsync(FiltroReporteVentas filtro)
    {
        using var conn = _connectionFactory.CreateConnection();
        return await conn.QueryAsync<ReporteResumenVentaDto>("Sales.usp_Reporte_ResumenVentas", new
        {
            FechaInicio = filtro.FechaInicio.Date,
            FechaFin = filtro.FechaFin.Date,
            filtro.CustomerID,
            filtro.SalesPersonID
        }, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<ReporteProductoDto>> DetallePorProductoAsync(FiltroReporteVentas filtro)
    {
        using var conn = _connectionFactory.CreateConnection();
        return await conn.QueryAsync<ReporteProductoDto>("Sales.usp_Reporte_DetallePorProducto", new
        {
            FechaInicio = filtro.FechaInicio.Date,
            FechaFin = filtro.FechaFin.Date,
            filtro.ProductID
        }, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<ReporteProductoDto>> ResumenPorProductoAsync(FiltroReporteVentas filtro)
    {
        using var conn = _connectionFactory.CreateConnection();
        return await conn.QueryAsync<ReporteProductoDto>("Sales.usp_Reporte_ResumenPorProducto", new
        {
            FechaInicio = filtro.FechaInicio.Date,
            FechaFin = filtro.FechaFin.Date,
            filtro.ProductID
        }, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<ReporteCategoriaDto>> DetallePorCategoriaAsync(FiltroReporteVentas filtro)
    {
        using var conn = _connectionFactory.CreateConnection();
        return await conn.QueryAsync<ReporteCategoriaDto>("Sales.usp_Reporte_DetallePorCategoria", new
        {
            FechaInicio = filtro.FechaInicio.Date,
            FechaFin = filtro.FechaFin.Date,
            filtro.ProductCategoryID
        }, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<ReporteCategoriaDto>> ResumenPorCategoriaAsync(FiltroReporteVentas filtro)
    {
        using var conn = _connectionFactory.CreateConnection();
        return await conn.QueryAsync<ReporteCategoriaDto>("Sales.usp_Reporte_ResumenPorCategoria", new
        {
            FechaInicio = filtro.FechaInicio.Date,
            FechaFin = filtro.FechaFin.Date,
            filtro.ProductCategoryID
        }, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<ReporteTerritorioDto>> DetallePorTerritorioAsync(FiltroReporteVentas filtro)
    {
        using var conn = _connectionFactory.CreateConnection();
        return await conn.QueryAsync<ReporteTerritorioDto>("Sales.usp_Reporte_DetallePorTerritorio", new
        {
            FechaInicio = filtro.FechaInicio.Date,
            FechaFin = filtro.FechaFin.Date,
            filtro.TerritoryID,
            filtro.ProductCategoryID,
            filtro.ProductID
        }, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<ReporteTerritorioDto>> ResumenPorTerritorioAsync(FiltroReporteVentas filtro)
    {
        using var conn = _connectionFactory.CreateConnection();
        return await conn.QueryAsync<ReporteTerritorioDto>("Sales.usp_Reporte_ResumenPorTerritorio", new
        {
            FechaInicio = filtro.FechaInicio.Date,
            FechaFin = filtro.FechaFin.Date,
            filtro.TerritoryID,
            filtro.ProductCategoryID,
            filtro.ProductID
        }, commandType: CommandType.StoredProcedure);
    }
}
