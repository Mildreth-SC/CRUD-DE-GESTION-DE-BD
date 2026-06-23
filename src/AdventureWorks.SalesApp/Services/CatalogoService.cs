using System.Data;
using AdventureWorks.SalesApp.Models;
using Dapper;

namespace AdventureWorks.SalesApp.Services;

public interface ICatalogoService
{
    Task<IEnumerable<ClienteDto>> ListarClientesAsync(string? busqueda = null);
    Task<ClienteDto?> ObtenerClienteAsync(int id);
    Task<int> GuardarClienteAsync(ClienteDto cliente);
    Task EliminarClienteAsync(int id);

    Task<IEnumerable<VendedorDto>> ListarVendedoresAsync(string? busqueda = null);
    Task<VendedorDto?> ObtenerVendedorAsync(int id);
    Task GuardarVendedorAsync(VendedorDto vendedor);
    Task EliminarVendedorAsync(int id);

    Task<IEnumerable<ProductoDto>> ListarProductosAsync(string? busqueda = null);
    Task<ProductoDto?> ObtenerProductoAsync(int id);
    Task<int> GuardarProductoAsync(ProductoDto producto);
    Task EliminarProductoAsync(int id);

    Task<IEnumerable<SubcategoriaDto>> ListarSubcategoriasAsync();
    Task<int> GuardarSubcategoriaAsync(SubcategoriaDto subcategoria);
    Task EliminarSubcategoriaAsync(int id);

    Task<IEnumerable<CategoriaDto>> ListarCategoriasAsync();
    Task<int> GuardarCategoriaAsync(CategoriaDto categoria);
    Task EliminarCategoriaAsync(int id);

    Task<IEnumerable<TerritorioDto>> ListarTerritoriosAsync();
    Task<int> GuardarTerritorioAsync(TerritorioDto territorio);
    Task EliminarTerritorioAsync(int id);
}

public class CatalogoService : ICatalogoService
{
    private readonly ISqlConnectionFactory _connectionFactory;

    public CatalogoService(ISqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IEnumerable<ClienteDto>> ListarClientesAsync(string? busqueda = null)
    {
        using var conn = _connectionFactory.CreateConnection();
        return await conn.QueryAsync<ClienteDto>("Sales.usp_Cliente_Listar",
            new { Busqueda = busqueda }, commandType: CommandType.StoredProcedure);
    }

    public async Task<ClienteDto?> ObtenerClienteAsync(int id)
    {
        using var conn = _connectionFactory.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<ClienteDto>("Sales.usp_Cliente_Obtener",
            new { CustomerID = id }, commandType: CommandType.StoredProcedure);
    }

    public async Task<int> GuardarClienteAsync(ClienteDto cliente)
    {
        using var conn = _connectionFactory.CreateConnection();
        var p = new DynamicParameters();
        p.Add("@CustomerID", cliente.CustomerID == 0 ? null : cliente.CustomerID, DbType.Int32, ParameterDirection.InputOutput);
        p.Add("@AccountNumber", cliente.AccountNumber);
        p.Add("@TerritoryID", cliente.TerritoryID);
        p.Add("@PersonID", cliente.PersonID);
        p.Add("@StoreID", cliente.StoreID);
        await conn.ExecuteAsync("Sales.usp_Cliente_Guardar", p, commandType: CommandType.StoredProcedure);
        return p.Get<int>("@CustomerID");
    }

    public async Task EliminarClienteAsync(int id)
    {
        using var conn = _connectionFactory.CreateConnection();
        await conn.ExecuteAsync("Sales.usp_Cliente_Eliminar", new { CustomerID = id }, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<VendedorDto>> ListarVendedoresAsync(string? busqueda = null)
    {
        using var conn = _connectionFactory.CreateConnection();
        return await conn.QueryAsync<VendedorDto>("Sales.usp_Vendedor_Listar",
            new { Busqueda = busqueda }, commandType: CommandType.StoredProcedure);
    }

    public async Task<VendedorDto?> ObtenerVendedorAsync(int id)
    {
        using var conn = _connectionFactory.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<VendedorDto>("Sales.usp_Vendedor_Obtener",
            new { BusinessEntityID = id }, commandType: CommandType.StoredProcedure);
    }

    public async Task GuardarVendedorAsync(VendedorDto vendedor)
    {
        using var conn = _connectionFactory.CreateConnection();
        await conn.ExecuteAsync("Sales.usp_Vendedor_Guardar", new
        {
            vendedor.BusinessEntityID,
            vendedor.TerritoryID,
            vendedor.SalesQuota,
            vendedor.Bonus,
            vendedor.CommissionPct
        }, commandType: CommandType.StoredProcedure);
    }

    public async Task EliminarVendedorAsync(int id)
    {
        using var conn = _connectionFactory.CreateConnection();
        await conn.ExecuteAsync("Sales.usp_Vendedor_Eliminar", new { BusinessEntityID = id }, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<ProductoDto>> ListarProductosAsync(string? busqueda = null)
    {
        using var conn = _connectionFactory.CreateConnection();
        return await conn.QueryAsync<ProductoDto>("Sales.usp_Producto_Listar",
            new { Busqueda = busqueda }, commandType: CommandType.StoredProcedure);
    }

    public async Task<ProductoDto?> ObtenerProductoAsync(int id)
    {
        using var conn = _connectionFactory.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<ProductoDto>("Sales.usp_Producto_Obtener",
            new { ProductID = id }, commandType: CommandType.StoredProcedure);
    }

    public async Task<int> GuardarProductoAsync(ProductoDto producto)
    {
        using var conn = _connectionFactory.CreateConnection();
        var p = new DynamicParameters();
        p.Add("@ProductID", producto.ProductID == 0 ? null : producto.ProductID, DbType.Int32, ParameterDirection.InputOutput);
        p.Add("@Name", producto.Name);
        p.Add("@ProductNumber", producto.ProductNumber);
        p.Add("@ListPrice", producto.ListPrice);
        p.Add("@StandardCost", producto.StandardCost);
        p.Add("@Color", producto.Color);
        p.Add("@ProductSubcategoryID", producto.ProductSubcategoryID);
        await conn.ExecuteAsync("Sales.usp_Producto_Guardar", p, commandType: CommandType.StoredProcedure);
        return p.Get<int>("@ProductID");
    }

    public async Task EliminarProductoAsync(int id)
    {
        using var conn = _connectionFactory.CreateConnection();
        await conn.ExecuteAsync("Sales.usp_Producto_Eliminar", new { ProductID = id }, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<SubcategoriaDto>> ListarSubcategoriasAsync()
    {
        using var conn = _connectionFactory.CreateConnection();
        return await conn.QueryAsync<SubcategoriaDto>("Sales.usp_Subcategoria_Listar", commandType: CommandType.StoredProcedure);
    }

    public async Task<int> GuardarSubcategoriaAsync(SubcategoriaDto subcategoria)
    {
        using var conn = _connectionFactory.CreateConnection();
        var p = new DynamicParameters();
        p.Add("@ProductSubcategoryID", subcategoria.ProductSubcategoryID == 0 ? null : subcategoria.ProductSubcategoryID, DbType.Int32, ParameterDirection.InputOutput);
        p.Add("@Name", subcategoria.Name);
        p.Add("@ProductCategoryID", subcategoria.ProductCategoryID);
        await conn.ExecuteAsync("Sales.usp_Subcategoria_Guardar", p, commandType: CommandType.StoredProcedure);
        return p.Get<int>("@ProductSubcategoryID");
    }

    public async Task EliminarSubcategoriaAsync(int id)
    {
        using var conn = _connectionFactory.CreateConnection();
        await conn.ExecuteAsync("Sales.usp_Subcategoria_Eliminar", new { ProductSubcategoryID = id }, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<CategoriaDto>> ListarCategoriasAsync()
    {
        using var conn = _connectionFactory.CreateConnection();
        return await conn.QueryAsync<CategoriaDto>("Sales.usp_Categoria_Listar", commandType: CommandType.StoredProcedure);
    }

    public async Task<int> GuardarCategoriaAsync(CategoriaDto categoria)
    {
        using var conn = _connectionFactory.CreateConnection();
        var p = new DynamicParameters();
        p.Add("@ProductCategoryID", categoria.ProductCategoryID == 0 ? null : categoria.ProductCategoryID, DbType.Int32, ParameterDirection.InputOutput);
        p.Add("@Name", categoria.Name);
        await conn.ExecuteAsync("Sales.usp_Categoria_Guardar", p, commandType: CommandType.StoredProcedure);
        return p.Get<int>("@ProductCategoryID");
    }

    public async Task EliminarCategoriaAsync(int id)
    {
        using var conn = _connectionFactory.CreateConnection();
        await conn.ExecuteAsync("Sales.usp_Categoria_Eliminar", new { ProductCategoryID = id }, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<TerritorioDto>> ListarTerritoriosAsync()
    {
        using var conn = _connectionFactory.CreateConnection();
        return await conn.QueryAsync<TerritorioDto>("Sales.usp_Territorio_Listar", commandType: CommandType.StoredProcedure);
    }

    public async Task<int> GuardarTerritorioAsync(TerritorioDto territorio)
    {
        using var conn = _connectionFactory.CreateConnection();
        var p = new DynamicParameters();
        p.Add("@TerritoryID", territorio.TerritoryID == 0 ? null : territorio.TerritoryID, DbType.Int32, ParameterDirection.InputOutput);
        p.Add("@Name", territorio.Name);
        p.Add("@CountryRegionCode", territorio.CountryRegionCode);
        p.Add("@Group", territorio.Group);
        await conn.ExecuteAsync("Sales.usp_Territorio_Guardar", p, commandType: CommandType.StoredProcedure);
        return p.Get<int>("@TerritoryID");
    }

    public async Task EliminarTerritorioAsync(int id)
    {
        using var conn = _connectionFactory.CreateConnection();
        await conn.ExecuteAsync("Sales.usp_Territorio_Eliminar", new { TerritoryID = id }, commandType: CommandType.StoredProcedure);
    }
}
