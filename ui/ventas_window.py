from PySide6.QtWidgets import QWidget, QVBoxLayout, QLabel, QPushButton

class VentasWindow(QWidget):
    def __init__(self):
        super().__init__()
        layout = QVBoxLayout(self)
        layout.addWidget(QLabel("Módulo de Ventas"))
        layout.addWidget(QPushButton("Registrar Venta"))
