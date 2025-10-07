from PySide6.QtWidgets import QWidget, QVBoxLayout, QLabel, QPushButton, QLineEdit, QTableWidget, QTableWidgetItem, QMessageBox, QHBoxLayout
from logic.ventas_logic import VentasLogic

class VentasWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.logic = VentasLogic()
        self.init_ui()

    def init_ui(self):
        layout = QVBoxLayout(self)
        layout.addWidget(QLabel("Módulo de Ventas"))

        # Formulario para datos del cliente y producto
        form = QHBoxLayout()
        self.input_cliente = QLineEdit()
        self.input_cliente.setPlaceholderText("ID Cliente")
        self.input_producto = QLineEdit()
        self.input_producto.setPlaceholderText("ID Producto")
        self.input_cantidad = QLineEdit()
        self.input_cantidad.setPlaceholderText("Cantidad")
        boton_agregar = QPushButton("Agregar a la venta")
        boton_agregar.clicked.connect(self.agregar_producto_a_venta)
        form.addWidget(self.input_cliente)
        form.addWidget(self.input_producto)
        form.addWidget(self.input_cantidad)
        form.addWidget(boton_agregar)
        layout.addLayout(form)

        # Tabla de productos en la venta
        self.tabla = QTableWidget(0, 3)
        self.tabla.setHorizontalHeaderLabels(["ID Producto", "Cantidad", "Precio"])
        layout.addWidget(self.tabla)

        # Botón para registrar la venta
        boton_registrar = QPushButton("Registrar Venta")
        boton_registrar.clicked.connect(self.registrar_venta)
        layout.addWidget(boton_registrar)

        self.productos_en_venta = []

    def agregar_producto_a_venta(self):
        id_producto = self.input_producto.text()
        cantidad = self.input_cantidad.text()
        if not id_producto or not cantidad:
            QMessageBox.warning(self, "Error", "Ingrese ID de producto y cantidad")
            return
        try:
            id_producto = int(id_producto)
            cantidad = int(cantidad)
            # Aquí deberías obtener el precio real del producto desde la base de datos
            # Por ahora, se usa un precio ficticio para el ejemplo
            precio = 10.0
            self.productos_en_venta.append({
                'id': id_producto,
                'nombre': f"Producto {id_producto}",
                'precio': precio,
                'cantidad': cantidad
            })
            self.actualizar_tabla()
            self.input_producto.clear()
            self.input_cantidad.clear()
        except ValueError:
            QMessageBox.warning(self, "Error", "ID de producto y cantidad deben ser numéricos")

    def actualizar_tabla(self):
        self.tabla.setRowCount(len(self.productos_en_venta))
        for i, prod in enumerate(self.productos_en_venta):
            self.tabla.setItem(i, 0, QTableWidgetItem(str(prod['id'])))
            self.tabla.setItem(i, 1, QTableWidgetItem(str(prod['cantidad'])))
            self.tabla.setItem(i, 2, QTableWidgetItem(str(prod['precio'])))

    def registrar_venta(self):
        id_cliente = self.input_cliente.text()
        if not id_cliente:
            QMessageBox.warning(self, "Error", "Ingrese el ID del cliente")
            return
        if not self.productos_en_venta:
            QMessageBox.warning(self, "Error", "Agregue al menos un producto a la venta")
            return
        try:
            cliente = {'id': int(id_cliente)}
            # Las funciones de acceso a datos reales deben implementarse en la capa de datos
            def registrar_func(venta): return 1  # Simulación: retorna ID de venta
            def obtener_stock_func(id_producto): return 100  # Simulación: stock suficiente
            def descontar_stock_func(id_producto, cantidad): pass  # Simulación: no hace nada

            resultado, mensaje = self.logic.registrar_venta(
                cliente,
                self.productos_en_venta,
                registrar_func,
                obtener_stock_func,
                descontar_stock_func
            )
            if resultado:
                QMessageBox.information(self, "Éxito", mensaje)
                self.productos_en_venta = []
                self.actualizar_tabla()
                self.input_cliente.clear()
            else:
                QMessageBox.warning(self, "Error", mensaje)
        except ValueError:
            QMessageBox.warning(self, "Error", "ID de cliente inválido")
