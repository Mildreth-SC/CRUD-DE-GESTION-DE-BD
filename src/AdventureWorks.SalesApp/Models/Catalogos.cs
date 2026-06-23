namespace AdventureWorks.SalesApp.Models;

public class ClienteDto
{
    public int CustomerID { get; set; }
    public string AccountNumber { get; set; } = string.Empty;
    public int? TerritoryID { get; set; }
    public string? Territorio { get; set; }
    public string? NombreCompleto { get; set; }
    public DateTime ModifiedDate { get; set; }
    public int? PersonID { get; set; }
    public int? StoreID { get; set; }
}

public class VendedorDto
{
    public int BusinessEntityID { get; set; }
    public string? NombreCompleto { get; set; }
    public int? TerritoryID { get; set; }
    public string? Territorio { get; set; }
    public decimal? SalesQuota { get; set; }
    public decimal Bonus { get; set; }
    public decimal CommissionPct { get; set; }
    public decimal SalesYTD { get; set; }
    public decimal SalesLastYear { get; set; }
    public DateTime ModifiedDate { get; set; }
}

public class ProductoDto
{
    public int ProductID { get; set; }
    public string Name { get; set; } = string.Empty;
    public string ProductNumber { get; set; } = string.Empty;
    public decimal ListPrice { get; set; }
    public decimal StandardCost { get; set; }
    public string? Color { get; set; }
    public int? ProductSubcategoryID { get; set; }
    public string? Subcategoria { get; set; }
    public int? ProductCategoryID { get; set; }
    public string? Categoria { get; set; }
    public DateTime? SellStartDate { get; set; }
    public DateTime? SellEndDate { get; set; }
    public DateTime ModifiedDate { get; set; }
}

public class SubcategoriaDto
{
    public int ProductSubcategoryID { get; set; }
    public string Name { get; set; } = string.Empty;
    public int ProductCategoryID { get; set; }
    public string? Categoria { get; set; }
    public DateTime ModifiedDate { get; set; }
}

public class CategoriaDto
{
    public int ProductCategoryID { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime ModifiedDate { get; set; }
}

public class TerritorioDto
{
    public int TerritoryID { get; set; }
    public string Name { get; set; } = string.Empty;
    public string CountryRegionCode { get; set; } = string.Empty;
    public string Group { get; set; } = string.Empty;
    public decimal SalesYTD { get; set; }
    public decimal SalesLastYear { get; set; }
    public DateTime ModifiedDate { get; set; }
}
