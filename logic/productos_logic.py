from db.producto_model import ProductoModel

class ProductosLogic:
    def __init__(self):
        self.model = ProductoModel()
        self.model.crear_tabla()

    def obtener_productos(self):
        return self.model.listar()

    def agregar_producto(self, nombre, precio, stock=0):
        """
        Agrega un producto con nombre, precio y stock inicial.
        """
        self.model.agregar(nombre, precio, stock)

    def eliminar_producto(self, id_producto):
        self.model.eliminar(id_producto)

    def actualizar_stock(self, id_producto, cantidad):
        """
        Actualiza el stock de un producto.
        """
        self.model.actualizar_stock(id_producto, cantidad)
