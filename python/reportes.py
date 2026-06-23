"""
Módulo Python - AdventureWorks2025 Sales
Utilidades para reportes y conexión a BD mediante procedimientos almacenados.
"""

import pyodbc
from datetime import date
from dataclasses import dataclass
from typing import Optional


@dataclass
class DbConfig:
    server: str = "localhost"
    database: str = "AdventureWorks2025"
    driver: str = "ODBC Driver 17 for SQL Server"
    trusted_connection: bool = True

    def connection_string(self) -> str:
        auth = "Trusted_Connection=yes;" if self.trusted_connection else ""
        return (
            f"DRIVER={{{self.driver}}};SERVER={self.server};"
            f"DATABASE={self.database};{auth}TrustServerCertificate=yes;"
        )


def get_connection(config: Optional[DbConfig] = None) -> pyodbc.Connection:
    cfg = config or DbConfig()
    return pyodbc.connect(cfg.connection_string())


def ejecutar_reporte_resumen_ventas(
    fecha_inicio: date,
    fecha_fin: date,
    customer_id: Optional[int] = None,
    sales_person_id: Optional[int] = None,
    config: Optional[DbConfig] = None,
) -> list[dict]:
    """Ejecuta Sales.usp_Reporte_ResumenVentas y retorna filas como diccionarios."""
    conn = get_connection(config)
    try:
        cursor = conn.cursor()
        cursor.execute(
            "EXEC Sales.usp_Reporte_ResumenVentas ?, ?, ?, ?",
            fecha_inicio,
            fecha_fin,
            customer_id,
            sales_person_id,
        )
        columns = [col[0] for col in cursor.description]
        return [dict(zip(columns, row)) for row in cursor.fetchall()]
    finally:
        conn.close()


def ejecutar_reporte_detalle_por_producto(
    fecha_inicio: date,
    fecha_fin: date,
    product_id: Optional[int] = None,
    config: Optional[DbConfig] = None,
) -> list[dict]:
    conn = get_connection(config)
    try:
        cursor = conn.cursor()
        cursor.execute(
            "EXEC Sales.usp_Reporte_DetallePorProducto ?, ?, ?",
            fecha_inicio,
            fecha_fin,
            product_id,
        )
        columns = [col[0] for col in cursor.description]
        return [dict(zip(columns, row)) for row in cursor.fetchall()]
    finally:
        conn.close()


def imprimir_reporte_consola(filas: list[dict], titulo: str) -> None:
    print(f"\n=== {titulo} ===")
    if not filas:
        print("Sin resultados.")
        return
    for fila in filas:
        print(" | ".join(f"{k}: {v}" for k, v in fila.items()))


if __name__ == "__main__":
    cfg = DbConfig()
    inicio = date(2025, 1, 1)
    fin = date(2025, 6, 29)
    resumen = ejecutar_reporte_resumen_ventas(inicio, fin, config=cfg)
    imprimir_reporte_consola(resumen, "Resumen de Ventas (Python)")
    detalle = ejecutar_reporte_detalle_por_producto(inicio, fin, config=cfg)
    imprimir_reporte_consola(detalle[:10], "Detalle por Producto (primeras 10 filas)")
