from PySide6.QtWidgets import QWidget, QVBoxLayout, QLabel, QPushButton, QLineEdit, QTableWidget, QTableWidgetItem, QMessageBox, QHBoxLayout
from logic.productos_logic import ProductosLogic

class ProductosWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.logic = ProductosLogic()
        self.init_ui()

    def init_ui(self):
        layout = QVBoxLayout(self)

        layout.addWidget(QLabel("Gestión de Productos"))

        form = QHBoxLayout()
        self.input_nombre = QLineEdit()
        self.input_nombre.setPlaceholderText("Nombre del producto")
        self.input_precio = QLineEdit()
        self.input_precio.setPlaceholderText("Precio")
        self.input_stock = QLineEdit()
        self.input_stock.setPlaceholderText("Stock inicial (opcional)")

        boton_agregar = QPushButton("Agregar")
        boton_agregar.clicked.connect(self.agregar_producto)

        form.addWidget(self.input_nombre)
        form.addWidget(self.input_precio)
        form.addWidget(self.input_stock)
        form.addWidget(boton_agregar)

        layout.addLayout(form)

        # Tabla
        self.tabla = QTableWidget(0, 4)
        self.tabla.setHorizontalHeaderLabels(["ID", "Nombre", "Precio", "Stock"])
        layout.addWidget(self.tabla)

        boton_eliminar = QPushButton("Eliminar Producto")
        boton_eliminar.clicked.connect(self.eliminar_producto)
        layout.addWidget(boton_eliminar)

        self.actualizar_tabla()

    def agregar_producto(self):
        nombre = self.input_nombre.text()
        precio = self.input_precio.text()
        stock = self.input_stock.text()

        if not nombre or not precio:
            QMessageBox.warning(self, "Error", "Debe ingresar nombre y precio")
            return

        try:
            precio = float(precio)
            stock = int(stock) if stock else 0
            self.logic.agregar_producto(nombre, precio, stock)
            self.actualizar_tabla()
            self.input_nombre.clear()
            self.input_precio.clear()
            self.input_stock.clear()
        except ValueError:
            QMessageBox.warning(self, "Error", "Precio o stock inválido")

    def actualizar_tabla(self):
        datos = self.logic.obtener_productos()
        self.tabla.setRowCount(len(datos))
        for i, fila in enumerate(datos):
            for j, valor in enumerate(fila[:4]):  # mostramos solo 4 columnas
                self.tabla.setItem(i, j, QTableWidgetItem(str(valor)))

    def eliminar_producto(self):
        fila = self.tabla.currentRow()
        if fila == -1:
            QMessageBox.warning(self, "Error", "Seleccione un producto para eliminar")
            return

        id_producto = self.tabla.item(fila, 0).text()
        self.logic.eliminar_producto(id_producto)
        self.actualizar_tabla()
