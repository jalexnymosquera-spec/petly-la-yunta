petly-la-yunta/database/schema.sql
-- =========================================================================
-- PROYECTO PETLY - TIENDA DE MASCOTAS LA YUNTA (TOLEDO, NORTE DE SANTANDER)
-- Script de Creación de Base de Datos Relacional (MySQL 8.0)
-- =========================================================================

CREATE DATABASE IF NOT EXISTS petly_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE petly_db;

-- 1. TABLA DE ROLES
CREATE TABLE IF NOT EXISTS roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(30) NOT NULL UNIQUE,
    descripcion VARCHAR(150) NOT NULL
) ENGINE=InnoDB;

-- 2. TABLA DE USUARIOS (Clientes y Administradores)
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_rol INT NOT NULL DEFAULT 2,
    nombre_completo VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    telefono VARCHAR(20) NOT NULL,
    direccion VARCHAR(200) DEFAULT NULL,
    password_hash VARCHAR(255) NOT NULL, -- Contraseña cifrada con bcrypt (nunca texto plano)
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_usuarios_rol FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 3. TABLA DE CATEGORÍAS DE PRODUCTOS
CREATE TABLE IF NOT EXISTS categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(80) NOT NULL UNIQUE,
    descripcion VARCHAR(200) DEFAULT NULL,
    activa BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

-- 4. TABLA DE PRODUCTOS
CREATE TABLE IF NOT EXISTS productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT NOT NULL,
    nombre_producto VARCHAR(120) NOT NULL,
    descripcion TEXT NOT NULL,
    precio DECIMAL(10, 2) NOT NULL CHECK (precio >= 0),
    precio_promocion DECIMAL(10, 2) DEFAULT NULL,
    en_promocion BOOLEAN NOT NULL DEFAULT FALSE,
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    stock_minimo INT NOT NULL DEFAULT 5 CHECK (stock_minimo >= 0),
    imagen_url VARCHAR(255) DEFAULT '/img/producto-default.png',
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_productos_categoria FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 5. TABLA DE MOVIMIENTOS DE INVENTARIO (Kardex básico)
CREATE TABLE IF NOT EXISTS movimientos_inventario (
    id_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    id_usuario INT NOT NULL,
    tipo_movimiento ENUM('entrada', 'salida', 'ajuste') NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    motivo VARCHAR(200) NOT NULL,
    fecha_movimiento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_movimientos_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 6. TABLA DE MASCOTAS (Datos básicos para atención; historial clínico lo porta el dueño)
CREATE TABLE IF NOT EXISTS mascotas (
    id_mascota INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    nombre_mascota VARCHAR(80) NOT NULL,
    especie ENUM('Perro', 'Gato', 'Ave', 'Otro') NOT NULL,
    raza VARCHAR(80) DEFAULT 'Mestizo / No especificada',
    tamano ENUM('Pequeno', 'Mediano', 'Grande') NOT NULL DEFAULT 'Mediano',
    observaciones VARCHAR(255) DEFAULT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mascotas_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7. TABLA DE SERVICIOS (Peluquería y Atención Veterinaria)
CREATE TABLE IF NOT EXISTS servicios (
    id_servicio INT AUTO_INCREMENT PRIMARY KEY,
    nombre_servicio VARCHAR(100) NOT NULL,
    tipo_servicio ENUM('Peluqueria', 'Veterinaria') NOT NULL,
    descripcion TEXT NOT NULL,
    precio_base DECIMAL(10, 2) NOT NULL CHECK (precio_base >= 0),
    duracion_minutos INT NOT NULL DEFAULT 60,
    activo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

-- 8. TABLA DE CITAS
CREATE TABLE IF NOT EXISTS citas (
    id_cita INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_mascota INT NOT NULL,
    id_servicio INT NOT NULL,
    fecha_cita DATE NOT NULL,
    hora_cita TIME NOT NULL,
    motivo_notas VARCHAR(255) DEFAULT NULL,
    estado_cita ENUM('pendiente', 'confirmada', 'atendida', 'cancelada') NOT NULL DEFAULT 'pendiente',
    fecha_solicitud DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_citas_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_citas_mascota FOREIGN KEY (id_mascota) REFERENCES mascotas(id_mascota)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_citas_servicio FOREIGN KEY (id_servicio) REFERENCES servicios(id_servicio)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Índice para agilizar la validación de horarios ocupados por fecha, hora y servicio
CREATE INDEX idx_citas_horario ON citas (fecha_cita, hora_cita, estado_cita);

-- 9. TABLA DE PEDIDOS
CREATE TABLE IF NOT EXISTS pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0),
    total DECIMAL(10, 2) NOT NULL CHECK (total >= 0),
    direccion_entrega VARCHAR(200) NOT NULL,
    telefono_contacto VARCHAR(20) NOT NULL,
    notas_pedido VARCHAR(255) DEFAULT NULL,
    estado_pedido ENUM('pendiente', 'confirmado', 'en_preparacion', 'enviado', 'entregado', 'cancelado') NOT NULL DEFAULT 'pendiente',
    fecha_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pedidos_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 10. TABLA DE DETALLES DEL PEDIDO
CREATE TABLE IF NOT EXISTS detalles_pedido (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10, 2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal_linea DECIMAL(10, 2) NOT NULL CHECK (subtotal_linea >= 0),
    CONSTRAINT fk_detalles_pedido FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_detalles_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 11. TABLA DE PAGOS (Sin almacenar datos sensibles de tarjetas ni CVV)
CREATE TABLE IF NOT EXISTS pagos (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL UNIQUE,
    metodo_pago ENUM('Transferencia_Nequi_Daviplata', 'Pago_Contraentrega', 'Efectivo_En_Tienda', 'Pasarela_Online') NOT NULL,
    referencia_transaccion VARCHAR(100) DEFAULT NULL,
    monto DECIMAL(10, 2) NOT NULL CHECK (monto >= 0),
    estado_pago ENUM('pendiente_verificacion', 'aprobado', 'rechazado') NOT NULL DEFAULT 'pendiente_verificacion',
    verificado_por INT DEFAULT NULL,
    fecha_pago DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_verificacion DATETIME DEFAULT NULL,
    CONSTRAINT fk_pagos_pedido FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_pagos_verificador FOREIGN KEY (verificado_por) REFERENCES usuarios(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =========================================================================
-- DATOS SEMILLA INICIALES (SEED DATA) PARA LA TIENDA LA YUNTA
-- =========================================================================

-- Insertar roles base
INSERT IGNORE INTO roles (id_rol, nombre_rol, descripcion) VALUES
(1, 'administrador', 'Acceso total al panel administrativo de La Yunta'),
(2, 'cliente', 'Cliente registrado en la tienda Petly');

-- Insertar categorías iniciales de La Yunta
INSERT IGNORE INTO categorias (id_categoria, nombre_categoria, descripcion) VALUES
(1, 'Alimentos y Concentrados', 'Concentrados, comida húmeda y snacks para perros, gatos y aves'),
(2, 'Higiene y Cuidado', 'Jabones, champús, antipulgas, cepillos y arena sanitaria'),
(3, 'Accesorios y Juguetes', 'Collares, correas, camas, comederos y juguetes interactivos'),
(4, 'Salud y Bienestar', 'Vitaminas, suplementos y productos básicos de cuidado animal');

-- Insertar productos reales de ejemplo para el catálogo inicial
INSERT IGNORE INTO productos (id_producto, id_categoria, nombre_producto, descripcion, precio, precio_promocion, en_promocion, stock, stock_minimo, imagen_url) VALUES
(1, 1, 'Concentrado Premium Adultos 10kg', 'Alimento balanceado rico en proteínas y vitaminas para perros adultos de todas las razas.', 98000.00, 89900.00, TRUE, 18, 5, '/img/concentrado-perro.png'),
(2, 1, 'Alimento Completo Gatos Salmón 3kg', 'Nutrición especial para el cuidado urinario y pelaje brillante en gatos adultos.', 46000.00, NULL, FALSE, 12, 4, '/img/alimento-gato.png'),
(3, 2, 'Champú Dermatológico y Brillo 500ml', 'Fórmula suave con avena y aloe vera ideal para el baño regular de perros y gatos.', 24500.00, 21000.00, TRUE, 25, 5, '/img/champu-mascota.png'),
(4, 3, 'Kit Collar + Correa Ajustable Reforzada', 'Collar ergonómico acolchado con correa de alta resistencia para paseos seguros.', 35000.00, NULL, FALSE, 4, 5, '/img/collar-correa.png'),
(5, 4, 'Suplemento Multivitamínico Mascotas 120ml', 'Refuerzo de defensas, calcio y energía para mascotas en crecimiento o recuperación.', 32000.00, NULL, FALSE, 15, 5, '/img/vitaminas.png');

-- Insertar servicios de peluquería y veterinaria de La Yunta
INSERT IGNORE INTO servicios (id_servicio, nombre_servicio, tipo_servicio, descripcion, precio_base, duracion_minutos) VALUES
(1, 'Baño General y Peluquería Canina', 'Peluqueria', 'Incluye baño con champú especializado, secado, corte de pelo según raza, limpieza de oídos y corte de uñas.', 40000.00, 60),
(2, 'Baño Especial y Cepillado Felino', 'Peluqueria', 'Atención cuidadosa libre de estrés con desenredado de pelaje, higiene de oídos y corte de puntas de uñas.', 38000.00, 60),
(3, 'Consulta Veterinaria General', 'Veterinaria', 'Valoración física general, control de peso y orientación de salud. (Recuerda traer el carnet físico de tu mascota).', 45000.00, 45),
(4, 'Jornada de Vacunación y Desparasitación', 'Veterinaria', 'Aplicación de esquema de vacunas o refuerzo antiparasitario interno y externo. (Traer carnet de vacunas).', 35000.00, 30);