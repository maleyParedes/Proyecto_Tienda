--- Crear la BD tienda_mariat
-- ============================

CREATE DATABASE tienda_mariat;
-- Conectarse a la BD (en psql usar: \c tienda_mariat)

-- ============================
-- Crear las tablas
-- ============================

CREATE TABLE Producto (
    pk_idProducto INT,
    nombre VARCHAR(100),
    precio DECIMAL(10,2),
    stock INT,
    codigo_barras VARCHAR(50)
);

CREATE TABLE Cliente (
    pk_idCliente INT,
    nombre VARCHAR(100)
);

CREATE TABLE Venta (
    pk_idVenta INT,
    fecha TIMESTAMP,
    total DECIMAL(10,2),
    fk_idCliente INT
);

CREATE TABLE Detalle_venta (
    pk_idDetalle_venta INT,
    cantidad INT,
    subtotal DECIMAL(10,2),
    fk_idVenta INT,
    fk_idProducto INT
);

CREATE TABLE Credito (
    pk_idCredito INT,
    estado BOOLEAN,
    fk_idCliente INT,
    fk_idVenta INT
);

CREATE TABLE Proveedor (
    pk_idProveedor INT,
    nombre VARCHAR(100),
    telefono VARCHAR(15)
);

CREATE TABLE Compra (
    pk_idCompra INT,
    fecha TIMESTAMP,
    total DECIMAL(10,2),
    fk_idProveedor INT
);

CREATE TABLE Detalle_compra (
    pk_idDetalle_compra INT,
    cantidad INT,
    subtotal DECIMAL(10,2),
    costo_unitario DECIMAL(10,2),
    fk_idCompra INT,
    fk_idProducto INT
);

CREATE TABLE Usuario(
    pk_idUsuario INT,
    usuario VARCHAR(50) UNIQUE,
    contrasena VARCHAR(50),
    rol VARCHAR(20) CHECK (rol IN ('administrador', 'vendedor'))
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

-- ============================
-- Agregar las FK
-- ============================

ALTER TABLE Venta
ADD CONSTRAINT fk_venta_cliente
FOREIGN KEY (fk_idCliente)
REFERENCES Cliente(pk_idCliente);

ALTER TABLE Detalle_venta
ADD CONSTRAINT fk_detalle_venta_venta
FOREIGN KEY (fk_idVenta)
REFERENCES Venta(pk_idVenta);

ALTER TABLE Detalle_venta
ADD CONSTRAINT fk_detalle_venta_producto
FOREIGN KEY (fk_idProducto)
REFERENCES Producto(pk_idProducto);

ALTER TABLE Credito
ADD CONSTRAINT fk_credito_cliente
FOREIGN KEY (fk_idCliente)
REFERENCES Cliente(pk_idCliente);

ALTER TABLE Credito
ADD CONSTRAINT fk_credito_venta
FOREIGN KEY (fk_idVenta)
REFERENCES Venta(pk_idVenta);

ALTER TABLE Compra
ADD CONSTRAINT fk_compra_proveedor
FOREIGN KEY (fk_idProveedor)
REFERENCES Proveedor(pk_idProveedor);

ALTER TABLE Detalle_compra
ADD CONSTRAINT fk_detalle_compra_compra
FOREIGN KEY (fk_idCompra)
REFERENCES Compra(pk_idCompra);

ALTER TABLE Detalle_compra
ADD CONSTRAINT fk_detalle_compra_producto
FOREIGN KEY (fk_idProducto)
REFERENCES Producto(pk_idProducto);