-- ============================
-- USUARIOS DEL SISTEMA
-- ============================
INSERT INTO Usuario_sistema (nombre, contrasena, rol) VALUES
('Administrador', 'admin123', 'admin'),
('Cajero 1', 'cajero123', 'cajero');

-- ============================
-- PROVEEDORES
-- ============================
INSERT INTO Proveedor (nombre, telefono) VALUES
('Distribuidora Central', '3201112233'),
('Alimentos Don Pepe', '3104445566'),
('Bebidas y Licores S.A.', '3157778899');

-- ============================
-- PRODUCTOS
-- ============================
INSERT INTO Producto (nombre, precio, stock, codigo_barras) VALUES
('Arroz Diana 1kg', 3500, 100, '7701001234567'),
('Aceite Premier 1L', 8500, 50, '7702009876543'),
('Gaseosa CocaCola 1.5L', 6000, 80, '7703001928374'),
('Galletas Festival', 2500, 200, '7704005647382'),
('Pan Bimbo Grande', 4500, 120, '7705009182736');

-- ============================
-- CLIENTES
-- ============================
INSERT INTO Cliente (nombre) VALUES
('Juan Pérez'),
('María Gómez'),
('Carlos Ruiz');

-- ============================
-- VENTAS
-- ============================
INSERT INTO Venta (fecha, total, idCliente) VALUES
('2025-09-20 10:30:00', 0, 1),
('2025-09-21 15:00:00', 0, 2),
('2025-09-22 18:45:00', 0, 3);

-- DETALLE DE VENTAS (se calcula el subtotal = cantidad * precio)
INSERT INTO Detalle_venta (idVenta, idProducto, cantidad, subtotal) VALUES
(1, 1, 2, 7000),   -- Juan compra 2 arroces
(1, 3, 1, 6000),   -- Juan compra 1 CocaCola
(2, 2, 1, 8500),   -- María compra 1 aceite
(2, 4, 3, 7500),   -- María compra 3 galletas
(3, 5, 2, 9000),   -- Carlos compra 2 panes
(3, 3, 2, 12000);  -- Carlos compra 2 CocaColas

-- ============================
-- CRÉDITOS (ejemplo: Carlos compró a crédito)
-- ============================
INSERT INTO Credito (idCliente, idVenta) VALUES
(3, 3);

-- ============================
-- COMPRAS (cuando la tienda se surte de proveedores)
-- ============================
INSERT INTO Compra (fecha_compra, total, idProveedor) VALUES
('2025-09-10 09:00:00', 200000, 1),
('2025-09-15 11:15:00', 150000, 2);

-- DETALLE DE COMPRAS
INSERT INTO Detalle_compra (idProducto, idCompra, cantidad, costo_unitario) VALUES
(1, 1, 50, 3000),   -- Se compran 50 sacos de arroz
(2, 1, 20, 7000),   -- Se compran 20 aceites
(4, 2, 100, 2000),  -- Se compran 100 paquetes de galletas
(5, 2, 60, 3500);   -- Se compran 60 panes

-- ============================
-- INVENTARIO (movimientos)
-- ============================
INSERT INTO Inventario (tipo_movimiento, cantidad, motivo, idProducto, idUsuario) VALUES
('entrada', 50, 'Compra a proveedor', 1, 6),
('entrada', 20, 'Compra a proveedor', 2, 6),
('entrada', 100, 'Compra a proveedor', 4, 6),
('salida', 2, 'Venta a cliente Juan Pérez', 1, 7),
('salida', 1, 'Venta a cliente Juan Pérez', 3, 7),
('salida', 1, 'Venta a cliente María Gómez', 2, 7),
('salida', 3, 'Venta a cliente María Gómez', 4, 7),
('salida', 2, 'Venta a cliente Carlos Ruiz', 5, 7),
('salida', 2, 'Venta a cliente Carlos Ruiz', 3, 7);

ALTER TABLE Credito ADD COLUMN estado VARCHAR(20) DEFAULT 'pendiente';
UPDATE credito SET estado = 'pagado' WHERE idCredito = 1;
