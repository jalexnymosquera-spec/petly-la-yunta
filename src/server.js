// =========================================================================
// PETLY - LA YUNTA | Servidor Principal (Backend con Node.js y Express)
// =========================================================================

const express = require('express');
const path = require('path');
const session = require('express-session');
require('dotenv').config();

const { pool, verificarConexionBD } = require('./config/db');

const app = express();
const PORT = process.env.PORT || 3000;

// 1. Middlewares para procesar datos JSON y formularios
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 2. Configuración segura de sesiones
app.use(session({
    secret: process.env.SESSION_SECRET || 'clave_respaldo_petly',
    resave: false,
    saveUninitialized: false,
    cookie: {
        httpOnly: true, // Protege la sesión contra accesos maliciosos desde el navegador
        maxAge: 1000 * 60 * 60 * 4 // Duración de 4 horas
    }
}));

// 3. Servir los archivos visuales de la carpeta "public"
app.use(express.static(path.join(__dirname, '../public')));

// 4. RUTA DE PRUEBA Y CATÁLOGO REAL DESDE MYSQL
app.get('/api/productos', async (req, res) => {
    try {
        const [filas] = await pool.execute(
            `SELECT p.id_producto, p.id_categoria, c.nombre_categoria, p.nombre_producto,
                    p.descripcion, p.precio, p.precio_promocion, p.en_promocion,
                    p.stock, p.stock_minimo, p.imagen_url
             FROM productos p
             INNER JOIN categorias c ON p.id_categoria = c.id_categoria
             WHERE p.activo = TRUE
             ORDER BY p.id_producto ASC`
        );
        res.json({ ok: true, productos: filas });
    } catch (error) {
        console.error('Error al consultar productos:', error.message);
        res.status(500).json({ ok: false, mensaje: 'Error al obtener el catálogo de productos' });
    }
});

// 5. RUTA PARA OBTENER LOS SERVICIOS DE PELUQUERÍA Y VETERINARIA DESDE MYSQL
app.get('/api/servicios', async (req, res) => {
    try {
        const [filas] = await pool.execute(
            `SELECT id_servicio, nombre_servicio, tipo_servicio, descripcion, precio_base, duracion_minutos
             FROM servicios
             WHERE activo = TRUE
             ORDER BY id_servicio ASC`
        );
        res.json({ ok: true, servicios: filas });
    } catch (error) {
        console.error('Error al consultar servicios:', error.message);
        res.status(500).json({ ok: false, mensaje: 'Error al obtener los servicios' });
    }
});

// 6. Iniciar el servidor y probar la conexión a MySQL
app.listen(PORT, async () => {
    console.log('==========================================================');
    console.log(`🐾 Servidor de PETLY (La Yunta) activo en: http://localhost:${PORT}`);
    await verificarConexionBD();
    console.log('==========================================================');
});