# Lógica de negocio para ventas: registro, cálculo de totales, validaciones, etc.

from datetime import datetime

class VentasLogic:
    def __init__(self):
        # Aquí podrías inicializar conexiones a la base de datos si es necesario
        pass

    def calcular_total(self, productos):
        """
        Calcula el total de la venta.
        productos: lista de diccionarios con claves 'precio' y 'cantidad'
        """
        total = 0
        for prod in productos:
            total += prod['precio'] * prod['cantidad']
        return round(total, 2)

    def validar_stock(self, productos, obtener_stock_func):
        """
        Valida que haya stock suficiente para cada producto.
        obtener_stock_func: función que recibe un id_producto y retorna el stock actual.
        """
        for prod in productos:
            stock_actual = obtener_stock_func(prod['id'])
            if prod['cantidad'] > stock_actual:
                return False, f"Stock insuficiente para el producto {prod['nombre']}"
        return True, ""

    def registrar_venta(self, cliente, productos, registrar_func, obtener_stock_func, descontar_stock_func):
        """
        Registra una venta si hay stock suficiente.
        - cliente: dict con info del cliente
        - productos: lista de dicts con 'id', 'nombre', 'precio', 'cantidad'
        - registrar_func: función para registrar la venta en la BD
        - obtener_stock_func: función para consultar stock actual
        - descontar_stock_func: función para descontar stock en la BD
        """
        es_valido, mensaje = self.validar_stock(productos, obtener_stock_func)
        if not es_valido:
            return False, mensaje

        total = self.calcular_total(productos)
        venta = {
            'cliente_id': cliente['id'],
            'fecha': datetime.now(),
            'total': total,
            'productos': productos
        }

        venta_id = registrar_func(venta)
        for prod in productos:
            descontar_stock_func(prod['id'], prod['cantidad'])

        return True, f"Venta registrada exitosamente con ID {venta_id}"

# Ejemplo de uso (las funciones reales deben implementarse en la capa de datos):

# def registrar_func(venta): ...
# def obtener_stock_func(id_producto): ...
# def descontar_stock_func(id_producto, cantidad): ...
# ventas_logic = VentasLogic()
# resultado, mensaje = ventas_logic.registrar_venta(cliente, productos, registrar_func, obtener_stock_func, descontar_stock_func)
