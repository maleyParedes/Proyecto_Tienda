-- ============================
-- CREACIÓN DE BASE DE DATOS
-- ============================
CREATE DATABASE tienda_mariat;

-- Conectarse a la BD (en psql usar: \c tienda_mariat)


-- ============================
-- ============================
-- ============================
-- TABLAS
-- ============================
-- ============================
-- ============================

-- ============================
-- TABLA PRODUCTOS
-- ============================
CREATE TABLE Producto (
    idProducto SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio NUMERIC(10,2) NOT NULL,
    stock INT DEFAULT 0,
    codigo_barras VARCHAR(50) UNIQUE
);

-- ============================
-- TABLA CLIENTES
-- ============================
CREATE TABLE Cliente (
    idCliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

-- ============================
-- TABLA VENTAS
-- ============================
CREATE TABLE Venta (
    idVenta SERIAL PRIMARY KEY,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total NUMERIC(10,2) NOT NULL,
    idCliente INT,
    CONSTRAINT fk_cliente FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- ============================
-- TABLA DETALLE DE VENTAS
-- ============================
CREATE TABLE Detalle_venta (
    idDetalle_venta SERIAL PRIMARY KEY,
    idVenta INT,
    idProducto INT,
    cantidad INT NOT NULL,
    subtotal NUMERIC(10,2) NOT NULL,
    CONSTRAINT fk_venta FOREIGN KEY (idVenta) REFERENCES Venta(idVenta)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_producto FOREIGN KEY (idProducto) REFERENCES Producto(idProducto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ============================
-- TABLA CRÉDITOS
-- ============================
CREATE TABLE Credito (
    idCredito SERIAL PRIMARY KEY,
    idCliente INT,
    idVenta INT,
    estado VARCHAR(20) DEFAULT 'pendiente',
    CONSTRAINT fk_cliente_credito FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_venta_credito FOREIGN KEY (idVenta) REFERENCES Venta(idVenta)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ============================
-- TABLA PROVEEDORES
-- ============================
CREATE TABLE Proveedor (
    idProveedor SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20)
);

-- ============================
-- TABLA COMPRAS
-- ============================
CREATE TABLE Compra (
    idCompra SERIAL PRIMARY KEY,
    fecha_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total NUMERIC(10,2) NOT NULL,
    idProveedor INT,
    CONSTRAINT fk_proveedor FOREIGN KEY (idProveedor) REFERENCES Proveedor(idProveedor)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- ============================
-- TABLA DETALLE DE COMPRAS
-- ============================
CREATE TABLE Detalle_compra (
    idDetalle_compra SERIAL PRIMARY KEY,
    idProducto INT,
    idCompra INT,
    cantidad INT NOT NULL,
    costo_unitario NUMERIC(10,2) NOT NULL,
    CONSTRAINT fk_producto_compra FOREIGN KEY (idProducto) REFERENCES Producto(idProducto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_compra FOREIGN KEY (idCompra) REFERENCES Compra(idCompra)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ============================
-- TABLA USUARIOS DEL SISTEMA
-- ============================
CREATE TABLE Usuario_sistema (
    idUsuario SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('admin','cajero'))
);

-- ============================
-- TABLA INVENTARIO (movimientos)
-- ============================
CREATE TABLE Inventario (
    idInventario SERIAL PRIMARY KEY,
    tipo_movimiento VARCHAR(20) NOT NULL CHECK (tipo_movimiento IN ('entrada','salida')),
    cantidad INT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo TEXT,
    idProducto INT,
    idUsuario INT,
    CONSTRAINT fk_producto_inv FOREIGN KEY (idProducto) REFERENCES Producto(idProducto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_usuario_inv FOREIGN KEY (idUsuario) REFERENCES Usuario_sistema(idUsuario)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);


-- ============================
-- ============================
-- ============================
-- FUNCIONES - TRIGGERS
-- ============================
-- ============================
-- ============================

-- ============================
-- TRIGGER Mantener stock al vender
-- ============================
-- Función
CREATE OR REPLACE FUNCTION fn_restar_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Producto
    SET stock = stock - NEW.cantidad
    WHERE idProducto = NEW.idProducto;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger
CREATE TRIGGER trg_restar_stock
AFTER INSERT ON Detalle_venta
FOR EACH ROW
EXECUTE FUNCTION fn_restar_stock();


-- ============================
-- TRIGGER Mantener stock al comprar
-- ============================
CREATE OR REPLACE FUNCTION fn_aumentar_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Producto
    SET stock = stock + NEW.cantidad
    WHERE idProducto = NEW.idProducto;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_aumentar_stock
AFTER INSERT ON Detalle_compra
FOR EACH ROW
EXECUTE FUNCTION fn_aumentar_stock();


-- ============================
-- TRIGGER Calcular subtotal en el detalle de ventas
-- ============================
CREATE OR REPLACE FUNCTION fn_calcular_subtotal()
RETURNS TRIGGER AS $$
BEGIN
    NEW.subtotal := NEW.cantidad * (SELECT precio FROM Producto WHERE idProducto = NEW.idProducto);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calcular_subtotal
BEFORE INSERT ON Detalle_venta
FOR EACH ROW
EXECUTE FUNCTION fn_calcular_subtotal();


-- ============================
-- TRIGGER Calcular el total de la venta
-- ============================
CREATE OR REPLACE FUNCTION fn_actualizar_total_venta()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Venta
    SET total = (SELECT COALESCE(SUM(subtotal),0) FROM Detalle_venta WHERE idVenta = NEW.idVenta)
    WHERE idVenta = NEW.idVenta;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_total_venta
AFTER INSERT OR UPDATE OR DELETE ON Detalle_venta
FOR EACH ROW
EXECUTE FUNCTION fn_actualizar_total_venta();


-- ============================
-- TRIGGER Registro automático en inventario
-- ============================
CREATE OR REPLACE FUNCTION fn_inventario_venta()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Inventario(tipo_movimiento, cantidad, fecha, motivo, idProducto, idUsuario)
    VALUES ('salida', NEW.cantidad, CURRENT_TIMESTAMP, 'Venta registrada', NEW.idProducto, NULL);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_inventario_venta
AFTER INSERT ON Detalle_venta
FOR EACH ROW
EXECUTE FUNCTION fn_inventario_venta();


-- ============================
-- TRIGGER Evitar stock negativo
-- ============================
CREATE OR REPLACE FUNCTION fn_validar_stock()
RETURNS TRIGGER AS $$
DECLARE
    stock_actual INT;
BEGIN
    SELECT stock INTO stock_actual FROM Producto WHERE idProducto = NEW.idProducto;

    IF stock_actual < NEW.cantidad THEN
        RAISE EXCEPTION 'No hay suficiente stock para el producto %', NEW.idProducto;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_stock
BEFORE INSERT ON Detalle_venta
FOR EACH ROW
EXECUTE FUNCTION fn_validar_stock();


-- ============================
-- TRIGGER REGISTRO AUTOMÁTICO EN INVENTARIO (COMPRAS)
-- ============================
CREATE OR REPLACE FUNCTION fn_inventario_compra()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Inventario(tipo_movimiento, cantidad, fecha, motivo, idProducto, idUsuario)
    VALUES ('entrada', NEW.cantidad, CURRENT_TIMESTAMP, 'Compra registrada', NEW.idProducto, NULL);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_inventario_compra
AFTER INSERT ON Detalle_compra
FOR EACH ROW
EXECUTE FUNCTION fn_inventario_compra();
