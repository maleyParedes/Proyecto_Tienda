from db.db import Database

class ProductoModel:
    def __init__(self):
        self.db = Database()

    def crear_tabla(self):
        query = """
        CREATE TABLE IF NOT EXISTS producto (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            precio REAL NOT NULL,
            fecha_vencimiento DATE,
            estado TEXT CHECK(estado IN ('disponible','vencido')) DEFAULT 'disponible'
        );
        """
        self.db.ejecutar(query)

    def agregar(self, nombre, precio, fecha_vencimiento, estado="disponible"):
        query = "INSERT INTO producto (nombre, precio, fecha_vencimiento, estado) VALUES (?, ?, ?, ?)"
        self.db.ejecutar(query, (nombre, precio, fecha_vencimiento, estado))

    def listar(self):
        return self.db.consultar("SELECT * FROM producto")

    def eliminar(self, id_producto):
        self.db.ejecutar("DELETE FROM producto WHERE id = ?", (id_producto,))
