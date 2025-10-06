import sqlite3

class Database:
    def __init__(self, nombre_db="tienda.db"):
        self.conexion = sqlite3.connect(nombre_db)
        self.cursor = self.conexion.cursor()

    def ejecutar(self, query, params=()):
        self.cursor.execute(query, params)
        self.conexion.commit()

    def consultar(self, query, params=()):
        self.cursor.execute(query, params)
        return self.cursor.fetchall()

    def cerrar(self):
        self.conexion.close()
