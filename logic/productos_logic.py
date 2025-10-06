from db.producto_model import ProductoModel

class ProductosLogic:
    def __init__(self):
        self.model = ProductoModel()
        self.model.crear_tabla()

    def obtener_productos(self):
        return self.model.listar()

    def agregar_producto(self, nombre, precio, fecha_vencimiento, estado="disponible"):
        self.model.agregar(nombre, precio, fecha_vencimiento, estado)

    def eliminar_producto(self, id_producto):
        self.model.eliminar(id_producto)
