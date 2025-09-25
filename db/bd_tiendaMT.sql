--- Crear la BD tienda_mariat
-- ============================

CREATE DATABASE tienda_mariat;
-- Conectarse a la BD (en psql usar: \c tienda_mariat)

-- ============================
-- Crear las tablas
-- ============================

CREATE TABLE Producto (
    pk_idProducto INT NOT NULL,
    nombre VARCHAR(100),
    precio DECIMAL(10,2),
    stock INT,
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
    fk_idUsuario INT,                            -- Usuario que realizó la acción
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