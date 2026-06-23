namespace AdventureWorks.SalesApp.Models;

public class VentaEncabezadoDto
{
    public int SalesOrderID { get; set; }
    public string SalesOrderNumber { get; set; } = string.Empty;
    public DateTime OrderDate { get; set; }
    public DateTime? DueDate { get; set; }
    public int CustomerID { get; set; }
    public string? Cliente { get; set; }
    public int? SalesPersonID { get; set; }
    public string? Vendedor { get; set; }
    public int? TerritoryID { get; set; }
    public string? Territorio { get; set; }
    public decimal SubTotal { get; set; }
    public decimal TaxAmt { get; set; }
    public decimal Freight { get; set; }
    public decimal TotalDue { get; set; }
    public bool Anulado { get; set; }
    public DateTime? FechaAnulacion { get; set; }
    public byte Status { get; set; }
    public string? Comment { get; set; }
}

public class VentaDetalleDto
{
    public int SalesOrderDetailID { get; set; }
    public int SalesOrderID { get; set; }
    public int ProductID { get; set; }
    public string? Producto { get; set; }
    public string? ProductNumber { get; set; }
    public short OrderQty { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal UnitPriceDiscount { get; set; }
    public decimal LineTotal { get; set; }
}

public class VentaCompletaDto
{
    public VentaEncabezadoDto Encabezado { get; set; } = new();
    public List<VentaDetalleDto> Detalles { get; set; } = [];
}
