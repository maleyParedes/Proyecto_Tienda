from PySide6.QtWidgets import QMainWindow, QWidget, QVBoxLayout, QPushButton, QStackedWidget, QHBoxLayout
from ui.productos_window import ProductosWindow
from ui.ventas_window import VentasWindow

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Sistema de Tienda - Inventario y Ventas")
        self.resize(900, 600)

        contenedor = QWidget()
        layout = QHBoxLayout(contenedor)

        # Menú lateral
        menu = QVBoxLayout()
        self.stack = QStackedWidget()

        # Instancias de ventanas para mantener el estado y facilitar la comparación de clases
        self.ventanas = {
            "Productos": ProductosWindow(),
            "Ventas": VentasWindow(),
        }

        for nombre, instancia in self.ventanas.items():
            boton = QPushButton(nombre)
            boton.clicked.connect(lambda _, c=type(instancia): self.cambiar_ventana(c))
            menu.addWidget(boton)
            self.stack.addWidget(instancia)

        menu.addStretch()
        layout.addLayout(menu, 1)
        layout.addWidget(self.stack, 4)

        self.setCentralWidget(contenedor)

    def cambiar_ventana(self, clase):
        for i in range(self.stack.count()):
            if isinstance(self.stack.widget(i), clase):
                self.stack.setCurrentIndex(i)
                break
