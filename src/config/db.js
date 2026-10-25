// =========================================================================
// PETLY - LA YUNTA | Conexión Segura a la Base de Datos MySQL (Pool)
// =========================================================================

const mysql = require('mysql2/promise');
require('dotenv').config();

// Creamos un Pool de conexiones para manejar múltiples solicitudes de forma eficiente y segura
const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME || 'petly_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Función para verificar que la base de datos responde al encender el servidor
async function verificarConexionBD() {
    try {
        const conexion = await pool.getConnection();
        console.log('✅ Conexión exitosa a la base de datos MySQL (petly_db)');
        conexion.release();
    } catch (error) {
        console.error('❌ Error al conectar con MySQL. Verifica tu clave en el archivo .env:', error.message);
    }
}

module.exports = {
    pool,
    verificarConexionBD
};