namespace AdventureWorks.SalesApp.Models;

public class ReporteDetalleVentaDto
{
    public int SalesOrderID { get; set; }
    public string SalesOrderNumber { get; set; } = string.Empty;
    public DateTime OrderDate { get; set; }
    public string? Cliente { get; set; }
    public string? Vendedor { get; set; }
    public string? Producto { get; set; }
    public short OrderQty { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal LineTotal { get; set; }
    public bool Anulado { get; set; }
}

public class ReporteResumenVentaDto
{
    public string? Cliente { get; set; }
    public string? Vendedor { get; set; }
    public int CantidadOrdenes { get; set; }
    public decimal SubTotal { get; set; }
    public decimal Impuestos { get; set; }
    public decimal Flete { get; set; }
    public decimal TotalVentas { get; set; }
}

public class ReporteProductoDto
{
    public int ProductID { get; set; }
    public string? Producto { get; set; }
    public string? ProductNumber { get; set; }
    public DateTime? OrderDate { get; set; }
    public string? SalesOrderNumber { get; set; }
    public short? OrderQty { get; set; }
    public decimal? UnitPrice { get; set; }
    public decimal? LineTotal { get; set; }
    public int? CantidadVendida { get; set; }
    public decimal? TotalVentas { get; set; }
}

public class ReporteCategoriaDto
{
    public int? ProductCategoryID { get; set; }
    public string? Categoria { get; set; }
    public string? Producto { get; set; }
    public DateTime? OrderDate { get; set; }
    public string? SalesOrderNumber { get; set; }
    public short? OrderQty { get; set; }
    public decimal? LineTotal { get; set; }
    public int? CantidadVendida { get; set; }
    public decimal? TotalVentas { get; set; }
}

public class ReporteTerritorioDto
{
    public int? TerritoryID { get; set; }
    public string? Territorio { get; set; }
    public string? Categoria { get; set; }
    public string? Producto { get; set; }
    public DateTime? OrderDate { get; set; }
    public string? SalesOrderNumber { get; set; }
    public short? OrderQty { get; set; }
    public decimal? LineTotal { get; set; }
    public int? CantidadVendida { get; set; }
    public decimal? TotalVentas { get; set; }
}

public class FiltroReporteVentas
{
    public DateTime FechaInicio { get; set; } = new DateTime(2025, 1, 1);
    public DateTime FechaFin { get; set; } = new DateTime(2025, 6, 29);
    public int? CustomerID { get; set; }
    public int? SalesPersonID { get; set; }
    public int? ProductID { get; set; }
    public int? ProductCategoryID { get; set; }
    public int? TerritoryID { get; set; }
}
