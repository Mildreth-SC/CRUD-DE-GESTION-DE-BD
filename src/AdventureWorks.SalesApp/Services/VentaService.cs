using System.Data;
using AdventureWorks.SalesApp.Models;
using Dapper;

namespace AdventureWorks.SalesApp.Services;

public interface IVentaService
{
    Task<IEnumerable<VentaEncabezadoDto>> ListarVentasAsync(DateTime? inicio, DateTime? fin, int? customerId, int? salesPersonId, bool incluirAnuladas = true);
    Task<VentaCompletaDto?> ObtenerVentaAsync(int salesOrderId);
    Task<int> CrearVentaAsync(int customerId, int? salesPersonId, int? territoryId, string? comment);
    Task ActualizarEncabezadoAsync(int salesOrderId, int customerId, int? salesPersonId, int? territoryId, string? comment);
    Task<int> AgregarDetalleAsync(int salesOrderId, int productId, short qty, decimal unitPrice, decimal discount = 0);
    Task ActualizarDetalleAsync(int detailId, short qty, decimal unitPrice, decimal discount = 0);
    Task EliminarDetalleAsync(int detailId);
    Task AnularVentaAsync(int salesOrderId);
    Task ConfirmarVentaAsync(int salesOrderId);
}

public class VentaService : IVentaService
{
    private readonly ISqlConnectionFactory _connectionFactory;

    public VentaService(ISqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IEnumerable<VentaEncabezadoDto>> ListarVentasAsync(DateTime? inicio, DateTime? fin, int? customerId, int? salesPersonId, bool incluirAnuladas = true)
    {
        using var conn = _connectionFactory.CreateConnection();
        return await conn.QueryAsync<VentaEncabezadoDto>("Sales.usp_Venta_Listar", new
        {
            FechaInicio = inicio?.Date,
            FechaFin = fin?.Date,
            CustomerID = customerId,
            SalesPersonID = salesPersonId,
            IncluirAnuladas = incluirAnuladas
        }, commandType: CommandType.StoredProcedure);
    }

    public async Task<VentaCompletaDto?> ObtenerVentaAsync(int salesOrderId)
    {
        using var conn = _connectionFactory.CreateConnection();
        using var multi = await conn.QueryMultipleAsync("Sales.usp_Venta_Obtener",
            new { SalesOrderID = salesOrderId }, commandType: CommandType.StoredProcedure);

        var encabezado = await multi.ReadFirstOrDefaultAsync<VentaEncabezadoDto>();
        if (encabezado is null) return null;

        var detalles = (await multi.ReadAsync<VentaDetalleDto>()).ToList();
        return new VentaCompletaDto { Encabezado = encabezado, Detalles = detalles };
    }

    public async Task<int> CrearVentaAsync(int customerId, int? salesPersonId, int? territoryId, string? comment)
    {
        using var conn = _connectionFactory.CreateConnection();
        var p = new DynamicParameters();
        p.Add("@CustomerID", customerId);
        p.Add("@SalesPersonID", salesPersonId);
        p.Add("@TerritoryID", territoryId);
        p.Add("@Comment", comment);
        p.Add("@SalesOrderID", dbType: DbType.Int32, direction: ParameterDirection.Output);
        await conn.ExecuteAsync("Sales.usp_Venta_Crear", p, commandType: CommandType.StoredProcedure);
        return p.Get<int>("@SalesOrderID");
    }

    public async Task ActualizarEncabezadoAsync(int salesOrderId, int customerId, int? salesPersonId, int? territoryId, string? comment)
    {
        using var conn = _connectionFactory.CreateConnection();
        await conn.ExecuteAsync("Sales.usp_Venta_ActualizarEncabezado", new
        {
            SalesOrderID = salesOrderId,
            CustomerID = customerId,
            SalesPersonID = salesPersonId,
            TerritoryID = territoryId,
            Comment = comment
        }, commandType: CommandType.StoredProcedure);
    }

    public async Task<int> AgregarDetalleAsync(int salesOrderId, int productId, short qty, decimal unitPrice, decimal discount = 0)
    {
        using var conn = _connectionFactory.CreateConnection();
        var p = new DynamicParameters();
        p.Add("@SalesOrderID", salesOrderId);
        p.Add("@ProductID", productId);
        p.Add("@OrderQty", qty);
        p.Add("@UnitPrice", unitPrice);
        p.Add("@UnitPriceDiscount", discount);
        p.Add("@SalesOrderDetailID", dbType: DbType.Int32, direction: ParameterDirection.Output);
        await conn.ExecuteAsync("Sales.usp_Venta_AgregarDetalle", p, commandType: CommandType.StoredProcedure);
        return p.Get<int>("@SalesOrderDetailID");
    }

    public async Task ActualizarDetalleAsync(int detailId, short qty, decimal unitPrice, decimal discount = 0)
    {
        using var conn = _connectionFactory.CreateConnection();
        await conn.ExecuteAsync("Sales.usp_Venta_ActualizarDetalle", new
        {
            SalesOrderDetailID = detailId,
            OrderQty = qty,
            UnitPrice = unitPrice,
            UnitPriceDiscount = discount
        }, commandType: CommandType.StoredProcedure);
    }

    public async Task EliminarDetalleAsync(int detailId)
    {
        using var conn = _connectionFactory.CreateConnection();
        await conn.ExecuteAsync("Sales.usp_Venta_EliminarDetalle", new { SalesOrderDetailID = detailId }, commandType: CommandType.StoredProcedure);
    }

    public async Task AnularVentaAsync(int salesOrderId)
    {
        using var conn = _connectionFactory.CreateConnection();
        await conn.ExecuteAsync("Sales.usp_Venta_Anular", new { SalesOrderID = salesOrderId }, commandType: CommandType.StoredProcedure);
    }

    public async Task ConfirmarVentaAsync(int salesOrderId)
    {
        using var conn = _connectionFactory.CreateConnection();
        await conn.ExecuteAsync("Sales.usp_Venta_Confirmar", new { SalesOrderID = salesOrderId }, commandType: CommandType.StoredProcedure);
    }
}
