--- Crear la BD tienda_mariat
-- ============================

CREATE DATABASE tienda_mariat;
-- Conectarse a la BD (en psql usar: \c tienda_mariat)
\c tienda_mariat

-- ============================
-- Crear las tablas
-- ============================

CREATE TABLE Producto (
    pk_idProducto INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    estado VARCHAR(20) DEFAULT 'disponible' NOT NULL CHECK (estado IN ('disponible', 'vencido')),
    codigo_barras VARCHAR(50)
);

CREATE TABLE Cliente (
    pk_idCliente INT NOT NULL,
    nombre VARCHAR(100)
);

CREATE TABLE Venta (
    pk_idVenta INT NOT NULL,
    fecha TIMESTAMP,
    total DECIMAL(10,2),
    fk_idCliente INT
);

CREATE TABLE Detalle_venta (
    pk_idDetalle_venta INT NOT NULL,
    cantidad INT,
    subtotal DECIMAL(10,2),
    fk_idVenta INT,
    fk_idProducto INT
);

CREATE TABLE Credito (
    pk_idCredito INT NOT NULL,
    estado VARCHAR(20) DEFAULT 'por pagar' NOT NULL CHECK (estado IN ('pagado', 'por pagar')),
    fk_idCliente INT,
    fk_idVenta INT
);

CREATE TABLE Proveedor (
    pk_idProveedor INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(15)
);

CREATE TABLE Compra (
    pk_idCompra INT NOT NULL,
    fecha TIMESTAMP,
    total DECIMAL(10,2),
    fk_idProveedor INT
);

CREATE TABLE Detalle_compra (
    pk_idDetalle_compra INT NOT NULL,
    cantidad INT NOT NULL,
    subtotal DECIMAL(10,2),
    costo_unitario DECIMAL(10,2) NOT NULL,
    fk_idCompra INT,
    fk_idProducto INT
);

CREATE TABLE Usuario(
    pk_idUsuario INT NOT NULL,
    usuario VARCHAR(50) UNIQUE,
    contrasena VARCHAR(50),
    rol VARCHAR(20) CHECK (rol IN ('administrador', 'vendedor'))
);

CREATE TABLE Movimiento_inventario (
    pk_idMovimiento INT NOT NULL,          -- Identificador único del movimiento
    tipo_movimiento VARCHAR(20) NOT NULL CHECK (tipo_movimiento IN ('entrada','salida')),
    cantidad INT NOT NULL,                       -- Cantidad que entra o sale
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,   -- Momento del movimiento
    motivo TEXT,                                 -- Descripción del movimiento (venta, compra, ajuste, devolución, etc.)
    fk_idProducto INT NOT NULL,                  -- Relacionado con el producto
    fk_idUsuario INT NOT NULL                          -- Usuario que realizó la acción
);


-- ============================
-- Agregar las PK
-- ============================

ALTER TABLE Producto
ADD CONSTRAINT pk_producto PRIMARY KEY (pk_idProducto);

ALTER TABLE Cliente
ADD CONSTRAINT pk_cliente PRIMARY KEY (pk_idCliente);

ALTER TABLE Venta
ADD CONSTRAINT pk_Venta PRIMARY KEY (pk_idVenta);

ALTER TABLE Detalle_venta
ADD CONSTRAINT pk_detalle_venta PRIMARY KEY (pk_idDetalle_venta);

ALTER TABLE Credito
ADD CONSTRAINT pk_credito PRIMARY KEY (pk_idCredito);

ALTER TABLE Proveedor
ADD CONSTRAINT pk_proveedor PRIMARY KEY (pk_idProveedor);

ALTER TABLE Compra
ADD CONSTRAINT pk_compra PRIMARY KEY (pk_idCompra);

ALTER TABLE Detalle_compra
ADD CONSTRAINT pk_detalle_compra PRIMARY KEY (pk_idDetalle_compra);

ALTER TABLE Usuario
ADD CONSTRAINT pk_usuario PRIMARY KEY (pk_idUsuario);

ALTER TABLE Movimiento_inventario
ADD CONSTRAINT pk_movimiento_inventario PRIMARY KEY (pk_idMovimiento);

-- ============================
-- Agregar las FK
-- ============================

ALTER TABLE Venta
ADD CONSTRAINT fk_venta_cliente
FOREIGN KEY (fk_idCliente)
REFERENCES Cliente(pk_idCliente)
ON UPDATE CASCADE
ON DELETE RESTRICT;

ALTER TABLE Detalle_venta
ADD CONSTRAINT fk_detalle_venta_venta
FOREIGN KEY (fk_idVenta)
REFERENCES Venta(pk_idVenta)
ON UPDATE CASCADE
ON DELETE RESTRICT;

ALTER TABLE Detalle_venta
ADD CONSTRAINT fk_detalle_venta_producto
FOREIGN KEY (fk_idProducto)
REFERENCES Producto(pk_idProducto)
ON UPDATE CASCADE
ON DELETE RESTRICT;

ALTER TABLE Credito
ADD CONSTRAINT fk_credito_cliente
FOREIGN KEY (fk_idCliente)
REFERENCES Cliente(pk_idCliente)
ON UPDATE CASCADE
ON DELETE RESTRICT;

ALTER TABLE Credito
ADD CONSTRAINT fk_credito_venta
FOREIGN KEY (fk_idVenta)
REFERENCES Venta(pk_idVenta)
ON UPDATE CASCADE
ON DELETE RESTRICT;

ALTER TABLE Compra
ADD CONSTRAINT fk_compra_proveedor
FOREIGN KEY (fk_idProveedor)
REFERENCES Proveedor(pk_idProveedor)
ON UPDATE CASCADE
ON DELETE RESTRICT;

ALTER TABLE Detalle_compra
ADD CONSTRAINT fk_detalle_compra_compra
FOREIGN KEY (fk_idCompra)
REFERENCES Compra(pk_idCompra)
ON UPDATE CASCADE
ON DELETE RESTRICT;

ALTER TABLE Detalle_compra
ADD CONSTRAINT fk_detalle_compra_producto
FOREIGN KEY (fk_idProducto)
REFERENCES Producto(pk_idProducto)
ON UPDATE CASCADE
ON DELETE RESTRICT;

ALTER TABLE Movimiento_inventario
ADD CONSTRAINT fk_movimiento_producto
FOREIGN KEY (fk_idProducto)
REFERENCES Producto(pk_idProducto)
ON UPDATE CASCADE
ON DELETE RESTRICT;

ALTER TABLE Movimiento_inventario
ADD CONSTRAINT fk_movimiento_usuario
FOREIGN KEY (fk_idUsuario)
REFERENCES Usuario(pk_idUsuario)
ON UPDATE CASCADE
ON DELETE SET NULL;

-- ============================
-- Secuencias para los PK
-- ============================

CREATE SEQUENCE seq_producto START 1;
CREATE SEQUENCE seq_cliente START 1;
CREATE SEQUENCE seq_venta START 1;
CREATE SEQUENCE seq_detalle_venta START 1;
CREATE SEQUENCE seq_credito START 1;
CREATE SEQUENCE seq_proveedor START 1;
CREATE SEQUENCE seq_compra START 1;
CREATE SEQUENCE seq_detalle_compra START 1;
CREATE SEQUENCE seq_usuario START 1;
CREATE SEQUENCE seq_movimiento_inventario START 1;

-- ============================
-- Triggers para asignar los PK
-- ============================

--- Trigger para Producto

CREATE OR REPLACE FUNCTION set_producto_pk()
RETURNS TRIGGER 
AS $$
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

--- Trigger para Cliente

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

--- Trigger para Venta

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

--- Trigger para Detalle_venta

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

--- Trigger para Credito

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

--- Trigger para Proveedor

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

--- Trigger para Compra

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

--- Trigger para Detalle_compra

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

--- Trigger para Usuario

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

--- Trigger para Movimiento_inventario

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

-- ============================
-- Triggers para control y seguridad de información
-- ============================

-- 1. Trigger para mantener el stock al registrar una venta (resta stock)
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

-- 2. Trigger para revertir stock si se elimina un detalle de venta (devuelve stock)
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

-- 3. Trigger para aumentar stock al registrar una compra
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

-- 4. Trigger para revertir stock si se elimina un detalle de compra
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

-- 5. Trigger para evitar que el stock sea negativo en cualquier actualización directa
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

-- 6. Trigger para auditar cambios en la tabla Usuario (por ejemplo, cambios de contraseña)
CREATE TABLE Auditoria_usuario (
    id SERIAL PRIMARY KEY,
    pk_idUsuario INT,
    usuario VARCHAR(50),
    accion VARCHAR(20),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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

-- ============================
-- Insertar datos iniciales (opcional)
-- ============================

INSERT INTO Usuario (usuario, contrasena, rol) VALUES
('admin', 'admin123', 'administrador'),
('vendedor1', 'vend123', 'vendedor');

INSERT INTO Proveedor (nombre, telefono) VALUES
('Proveedor A', '1234567890'),
('Proveedor B', '0987654321');

INSERT INTO Producto (nombre, precio, stock, codigo_barras) VALUES
('Producto 1', 10.00, 100, '1234567890123'),
('Producto 2', 20.00, 50, '9876543210987');

INSERT INTO Cliente (nombre) VALUES
('Cliente 1'),
('Cliente 2');

-- Fin del script