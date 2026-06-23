using AdventureWorks.SalesApp.Models;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace AdventureWorks.SalesApp.Services;

public interface IPdfService
{
    byte[] GenerarVentaPdf(VentaCompletaDto venta);
}

public class PdfService : IPdfService
{
    public byte[] GenerarVentaPdf(VentaCompletaDto venta)
    {
        QuestPDF.Settings.License = LicenseType.Community;
        var h = venta.Encabezado;

        return Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(40);
                page.DefaultTextStyle(x => x.FontSize(10));

                page.Header().Column(col =>
                {
                    col.Item().Text("AdventureWorks2025 - Orden de Venta").Bold().FontSize(16);
                    col.Item().Text($"N° {h.SalesOrderNumber}  |  Fecha: {h.OrderDate:dd/MM/yyyy}");
                    if (h.Anulado)
                        col.Item().Text($"ANULADA - {h.FechaAnulacion:dd/MM/yyyy HH:mm}").FontColor(Colors.Red.Medium);
                });

                page.Content().PaddingVertical(20).Column(col =>
                {
                    col.Item().Text($"Cliente: {h.Cliente}");
                    col.Item().Text($"Vendedor: {h.Vendedor ?? "N/A"}");
                    col.Item().Text($"Territorio: {h.Territorio ?? "N/A"}");
                    col.Item().PaddingTop(10).Table(table =>
                    {
                        table.ColumnsDefinition(c =>
                        {
                            c.RelativeColumn(3);
                            c.RelativeColumn(1);
                            c.RelativeColumn(1);
                            c.RelativeColumn(1);
                            c.RelativeColumn(1);
                        });
                        table.Header(header =>
                        {
                            header.Cell().Background(Colors.Grey.Lighten2).Text("Producto").Bold();
                            header.Cell().Background(Colors.Grey.Lighten2).Text("Cant.").Bold();
                            header.Cell().Background(Colors.Grey.Lighten2).Text("Precio").Bold();
                            header.Cell().Background(Colors.Grey.Lighten2).Text("Desc.").Bold();
                            header.Cell().Background(Colors.Grey.Lighten2).Text("Total").Bold();
                        });
                        foreach (var d in venta.Detalles)
                        {
                            table.Cell().Text(d.Producto);
                            table.Cell().Text(d.OrderQty.ToString());
                            table.Cell().Text(d.UnitPrice.ToString("C"));
                            table.Cell().Text(d.UnitPriceDiscount.ToString("P"));
                            table.Cell().Text(d.LineTotal.ToString("C"));
                        }
                    });
                    col.Item().AlignRight().PaddingTop(15).Column(totals =>
                    {
                        totals.Item().Text($"Subtotal: {h.SubTotal:C}");
                        totals.Item().Text($"Impuestos: {h.TaxAmt:C}");
                        totals.Item().Text($"Flete: {h.Freight:C}");
                        totals.Item().Text($"Total: {h.TotalDue:C}").Bold().FontSize(12);
                    });
                });

                page.Footer().AlignCenter().Text($"Generado: {DateTime.Now:dd/MM/yyyy HH:mm}");
            });
        }).GeneratePdf();
    }
}
