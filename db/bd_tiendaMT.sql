-- ===========================================
-- Script de creación de la base de datos tienda_mariat
-- ===========================================

-- Crear la base de datos (ejecutar solo una vez)
CREATE DATABASE IF NOT EXISTS tienda_mariat;

-- Conectarse a la base de datos
\c tienda_mariat

-- ===========================================
-- Crear tablas
-- ===========================================

BEGIN;

CREATE TABLE IF NOT EXISTS Producto (
    pk_idProducto INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio >= 0),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0)
);

CREATE TABLE IF NOT EXISTS Cliente (
    pk_idCliente INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS Venta (
    pk_idVenta INT PRIMARY KEY,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
    fk_idCliente INT NOT NULL,
    CONSTRAINT fk_venta_cliente FOREIGN KEY (fk_idCliente)
        REFERENCES Cliente(pk_idCliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Detalle_venta (
    pk_idDetalle_venta INT PRIMARY KEY,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
    fk_idVenta INT NOT NULL,
    fk_idProducto INT NOT NULL,
    CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (fk_idVenta)
        REFERENCES Venta(pk_idVenta)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (fk_idProducto)
        REFERENCES Producto(pk_idProducto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Credito (
    pk_idCredito INT PRIMARY KEY,
    estado VARCHAR(20) NOT NULL DEFAULT 'por pagar' CHECK (estado IN ('pagado', 'por pagar')),
    fk_idCliente INT NOT NULL,
    fk_idVenta INT NOT NULL,
    CONSTRAINT fk_credito_cliente FOREIGN KEY (fk_idCliente)
        REFERENCES Cliente(pk_idCliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_credito_venta FOREIGN KEY (fk_idVenta)
        REFERENCES Venta(pk_idVenta)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Proveedor (
    pk_idProveedor INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(15)
);

CREATE TABLE IF NOT EXISTS Compra (
    pk_idCompra INT PRIMARY KEY,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
    fk_idProveedor INT NOT NULL,
    CONSTRAINT fk_compra_proveedor FOREIGN KEY (fk_idProveedor)
        REFERENCES Proveedor(pk_idProveedor)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Detalle_compra (
    pk_idDetalle_compra INT PRIMARY KEY,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
    costo_unitario DECIMAL(10,2) NOT NULL CHECK (costo_unitario >= 0),
    fk_idCompra INT NOT NULL,
    fk_idProducto INT NOT NULL,
    CONSTRAINT fk_detalle_compra_compra FOREIGN KEY (fk_idCompra)
        REFERENCES Compra(pk_idCompra)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_detalle_compra_producto FOREIGN KEY (fk_idProducto)
        REFERENCES Producto(pk_idProducto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Usuario (
    pk_idUsuario INT PRIMARY KEY,
    usuario VARCHAR(50) UNIQUE NOT NULL,
    contrasena VARCHAR(100) NOT NULL,
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('administrador', 'vendedor'))
);

CREATE TABLE IF NOT EXISTS Movimiento_inventario (
    pk_idMovimiento INT PRIMARY KEY,
    tipo_movimiento VARCHAR(20) NOT NULL CHECK (tipo_movimiento IN ('entrada','salida')),
    cantidad INT NOT NULL CHECK (cantidad > 0),
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    motivo TEXT,
    fk_idProducto INT NOT NULL,
    fk_idUsuario INT NOT NULL,
    CONSTRAINT fk_movimiento_producto FOREIGN KEY (fk_idProducto)
        REFERENCES Producto(pk_idProducto)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_movimiento_usuario FOREIGN KEY (fk_idUsuario)
        REFERENCES Usuario(pk_idUsuario)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ===========================================
-- Secuencias para los PK
-- ===========================================

CREATE SEQUENCE IF NOT EXISTS seq_producto START 1;
CREATE SEQUENCE IF NOT EXISTS seq_cliente START 1;
CREATE SEQUENCE IF NOT EXISTS seq_venta START 1;
CREATE SEQUENCE IF NOT EXISTS seq_detalle_venta START 1;
CREATE SEQUENCE IF NOT EXISTS seq_credito START 1;
CREATE SEQUENCE IF NOT EXISTS seq_proveedor START 1;
CREATE SEQUENCE IF NOT EXISTS seq_compra START 1;
CREATE SEQUENCE IF NOT EXISTS seq_detalle_compra START 1;
CREATE SEQUENCE IF NOT EXISTS seq_usuario START 1;
CREATE SEQUENCE IF NOT EXISTS seq_movimiento_inventario START 1;

-- ===========================================
-- Triggers para asignar los PK automáticamente
-- ===========================================

CREATE OR REPLACE FUNCTION set_pk(tabla TEXT, campo TEXT, secuencia TEXT)
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.(campo) IS NULL THEN
        EXECUTE format('SELECT nextval(%L)', secuencia) INTO NEW.(campo);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Por limitaciones de PL/pgSQL, se mantiene un trigger por tabla:

CREATE OR REPLACE FUNCTION set_producto_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pk_idProducto IS NULL THEN
        NEW.pk_idProducto := nextval('seq_producto');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_producto_pk
BEFORE INSERT ON Producto
FOR EACH ROW
EXECUTE FUNCTION set_producto_pk();

CREATE OR REPLACE FUNCTION set_cliente_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pk_idCliente IS NULL THEN
        NEW.pk_idCliente := nextval('seq_cliente');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_cliente_pk
BEFORE INSERT ON Cliente
FOR EACH ROW
EXECUTE FUNCTION set_cliente_pk();

CREATE OR REPLACE FUNCTION set_venta_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pk_idVenta IS NULL THEN
        NEW.pk_idVenta := nextval('seq_venta');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_venta_pk
BEFORE INSERT ON Venta
FOR EACH ROW
EXECUTE FUNCTION set_venta_pk();

CREATE OR REPLACE FUNCTION set_detalle_venta_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pk_idDetalle_venta IS NULL THEN
        NEW.pk_idDetalle_venta := nextval('seq_detalle_venta');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_detalle_venta_pk
BEFORE INSERT ON Detalle_venta
FOR EACH ROW
EXECUTE FUNCTION set_detalle_venta_pk();

CREATE OR REPLACE FUNCTION set_credito_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pk_idCredito IS NULL THEN
        NEW.pk_idCredito := nextval('seq_credito');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_credito_pk
BEFORE INSERT ON Credito
FOR EACH ROW
EXECUTE FUNCTION set_credito_pk();

CREATE OR REPLACE FUNCTION set_proveedor_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pk_idProveedor IS NULL THEN
        NEW.pk_idProveedor := nextval('seq_proveedor');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_proveedor_pk
BEFORE INSERT ON Proveedor
FOR EACH ROW
EXECUTE FUNCTION set_proveedor_pk();

CREATE OR REPLACE FUNCTION set_compra_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pk_idCompra IS NULL THEN
        NEW.pk_idCompra := nextval('seq_compra');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_compra_pk
BEFORE INSERT ON Compra
FOR EACH ROW
EXECUTE FUNCTION set_compra_pk();

CREATE OR REPLACE FUNCTION set_detalle_compra_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pk_idDetalle_compra IS NULL THEN
        NEW.pk_idDetalle_compra := nextval('seq_detalle_compra');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_detalle_compra_pk
BEFORE INSERT ON Detalle_compra
FOR EACH ROW
EXECUTE FUNCTION set_detalle_compra_pk();

CREATE OR REPLACE FUNCTION set_usuario_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pk_idUsuario IS NULL THEN
        NEW.pk_idUsuario := nextval('seq_usuario');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_usuario_pk
BEFORE INSERT ON Usuario
FOR EACH ROW
EXECUTE FUNCTION set_usuario_pk();

CREATE OR REPLACE FUNCTION set_movimiento_inventario_pk()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pk_idMovimiento IS NULL THEN
        NEW.pk_idMovimiento := nextval('seq_movimiento_inventario');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_movimiento_inventario_pk
BEFORE INSERT ON Movimiento_inventario
FOR EACH ROW
EXECUTE FUNCTION set_movimiento_inventario_pk();

-- ===========================================
-- Triggers para control y seguridad de información
-- ===========================================

-- 1. Descontar stock al registrar una venta
CREATE OR REPLACE FUNCTION descontar_stock_venta()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Producto
    SET stock = stock - NEW.cantidad
    WHERE pk_idProducto = NEW.fk_idProducto;

    IF (SELECT stock FROM Producto WHERE pk_idProducto = NEW.fk_idProducto) < 0 THEN
        RAISE EXCEPTION 'Stock insuficiente para el producto %', NEW.fk_idProducto;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_descontar_stock_venta
AFTER INSERT ON Detalle_venta
FOR EACH ROW
EXECUTE FUNCTION descontar_stock_venta();

-- 2. Devolver stock si se elimina un detalle de venta
CREATE OR REPLACE FUNCTION devolver_stock_venta()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Producto
    SET stock = stock + OLD.cantidad
    WHERE pk_idProducto = OLD.fk_idProducto;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_devolver_stock_venta
AFTER DELETE ON Detalle_venta
FOR EACH ROW
EXECUTE FUNCTION devolver_stock_venta();

-- 3. Aumentar stock al registrar una compra
CREATE OR REPLACE FUNCTION aumentar_stock_compra()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Producto
    SET stock = stock + NEW.cantidad
    WHERE pk_idProducto = NEW.fk_idProducto;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_aumentar_stock_compra
AFTER INSERT ON Detalle_compra
FOR EACH ROW
EXECUTE FUNCTION aumentar_stock_compra();

-- 4. Revertir stock si se elimina un detalle de compra
CREATE OR REPLACE FUNCTION revertir_stock_compra()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Producto
    SET stock = stock - OLD.cantidad
    WHERE pk_idProducto = OLD.fk_idProducto;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_revertir_stock_compra
AFTER DELETE ON Detalle_compra
FOR EACH ROW
EXECUTE FUNCTION revertir_stock_compra();

-- 5. Validar que el stock no sea negativo en cualquier actualización directa
CREATE OR REPLACE FUNCTION validar_stock_no_negativo()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stock < 0 THEN
        RAISE EXCEPTION 'El stock no puede ser negativo para el producto %', NEW.pk_idProducto;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_stock_no_negativo
BEFORE UPDATE OF stock ON Producto
FOR EACH ROW
EXECUTE FUNCTION validar_stock_no_negativo();

-- 6. Auditoría de cambios en la tabla Usuario (por ejemplo, cambios de contraseña)
CREATE TABLE IF NOT EXISTS Auditoria_usuario (
    id SERIAL PRIMARY KEY,
    pk_idUsuario INT NOT NULL,
    usuario VARCHAR(50) NOT NULL,
    accion VARCHAR(20) NOT NULL,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION auditar_usuario()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.contrasena <> OLD.contrasena THEN
        INSERT INTO Auditoria_usuario(pk_idUsuario, usuario, accion)
        VALUES (NEW.pk_idUsuario, NEW.usuario, 'Cambio de contraseña');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditar_usuario
AFTER UPDATE ON Usuario
FOR EACH ROW
EXECUTE FUNCTION auditar_usuario();

COMMIT;

-- ===========================================
-- Insertar datos iniciales (opcional)
-- ===========================================

-- INSERT INTO Usuario (usuario, contrasena, rol) VALUES
-- ('admin', 'admin123', 'administrador'),
-- ('vendedor1', 'vend123', 'vendedor');

-- INSERT INTO Proveedor (nombre, telefono) VALUES
-- ('Proveedor A', '1234567890'),
-- ('Proveedor B', '0987654321');

-- INSERT INTO Producto (nombre, precio, stock) VALUES
-- ('Producto 1', 10.00, 100),
-- ('Producto 2', 20.00, 50);

-- INSERT INTO Cliente (nombre) VALUES
-- ('Cliente 1'),
-- ('Cliente 2');

-- Fin del script