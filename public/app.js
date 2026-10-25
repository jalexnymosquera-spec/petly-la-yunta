
// =========================================================================
// PETLY - LA YUNTA | Lógica de Interfaz Pública (Catálogo, Buscador y Carrito)
// =========================================================================

// Catálogo inicial de respaldo (se sincronizará con la API de MySQL en la Fase 7)
let productosCatalogo = [
    {
        id_producto: 1,
        id_categoria: 1,
        nombre_producto: 'Concentrado Premium Adultos 10kg',
        descripcion: 'Alimento balanceado rico en proteínas y vitaminas para perros adultos de todas las razas.',
        precio: 98000,
        precio_promocion: 89900,
        en_promocion: true,
        stock: 18,
        icono: 'bi-Archive-fill'
    },
    {
        id_producto: 2,
        id_categoria: 1,
        nombre_producto: 'Alimento Completo Gatos Salmón 3kg',
        descripcion: 'Nutrición especial para el cuidado urinario y pelaje brillante en gatos adultos.',
        precio: 46000,
        precio_promocion: null,
        en_promocion: false,
        stock: 12,
        icono: 'bi-bag-heart-fill'
    },
    {
        id_producto: 3,
        id_categoria: 2,
        nombre_producto: 'Champú Dermatológico y Brillo 500ml',
        descripcion: 'Fórmula suave con avena y aloe vera ideal para el baño regular de perros y gatos.',
        precio: 24500,
        precio_promocion: 21000,
        en_promocion: true,
        stock: 25,
        icono: 'bi-droplet-half'
    },
    {
        id_producto: 4,
        id_categoria: 3,
        nombre_producto: 'Kit Collar + Correa Ajustable Reforzada',
        descripcion: 'Collar ergonómico acolchado con correa de alta resistencia para paseos seguros.',
        precio: 35000,
        precio_promocion: null,
        en_promocion: false,
        stock: 4,
        icono: 'bi-award-fill'
    },
    {
        id_producto: 5,
        id_categoria: 4,
        nombre_producto: 'Suplemento Multivitamínico Mascotas 120ml',
        descripcion: 'Refuerzo de defensas, calcio y energía para mascotas en crecimiento o recuperación.',
        precio: 32000,
        precio_promocion: null,
        en_promocion: false,
        stock: 15,
        icono: 'bi-capsule-pill'
    }
];

let carrito = JSON.parse(localStorage.getItem('petly_carrito')) || [];
let categoriaActual = 'todas';

// Formatear pesos colombianos (COP)
function formatearCOP(valor) {
    return '$' + Number(valor).toLocaleString('es-CO') + ' COP';
}

// Mostrar mensajes claros de confirmación o error
function mostrarAlerta(mensaje, tipo = 'success') {
    const contenedor = document.getElementById('contenedorAlertas');
    contenedor.innerHTML = `
        <div class="alert alert-${tipo} alert-dismissible fade show shadow-sm" role="alert">
            <i class="bi ${tipo === 'success' ? 'bi-check-circle-fill' : 'bi-exclamation-triangle-fill'} me-2"></i>
            ${mensaje}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `;
}

// Pintar tarjetas de productos en la página
function renderizarProductos(lista) {
    const contenedor = document.getElementById('contenedorProductos');
    if (!contenedor) return;

    if (lista.length === 0) {
        contenedor.innerHTML = `
            <div class="col-12 text-center py-5">
                <p class="text-muted fs-5">No encontramos productos que coincidan con tu búsqueda.</p>
            </div>
        `;
        return;
    }

    contenedor.innerHTML = lista.map(prod => {
        const precioFinal = prod.en_promocion && prod.precio_promocion ? prod.precio_promocion : prod.precio;
        return `
            <div class="col-sm-6 col-lg-4">
                <div class="product-card">
                    <div class="product-img-wrapper">
                        ${prod.en_promocion ? '<span class="badge-promo">🔥 OFERTA</span>' : ''}
                        <span class="badge-stock">Stock: ${prod.stock} disp.</span>
                        <i class="bi bi-box2-heart"></i>
                    </div>
                    <div class="p-3 d-flex flex-column flex-grow-1">
                        <h5 class="fw-bold mb-1">${prod.nombre_producto}</h5>
                        <p class="text-muted small flex-grow-1">${prod.descripcion}</p>
                        <div class="mb-3">
                            ${prod.en_promocion ? `<span class="price-old">${formatearCOP(prod.precio)}</span>` : ''}
                            <span class="price-current">${formatearCOP(precioFinal)}</span>
                        </div>
                        <div class="d-flex gap-2">
                            <button class="btn btn-outline-petly btn-sm w-50" onclick="verFichaProducto(${prod.id_producto})">
                                <i class="bi bi-eye me-1"></i>Ver ficha
                            </button>
                            <button class="btn btn-petly-green btn-sm w-50" onclick="agregarAlCarrito(${prod.id_producto})">
                                <i class="bi bi-cart-plus me-1"></i>Agregar
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }).join('');
}

// Ver ficha individual de un producto
window.verFichaProducto = function(idProducto) {
    const prod = productosCatalogo.find(p => p.id_producto === idProducto);
    if (!prod) return;
    const precioFinal = prod.en_promocion && prod.precio_promocion ? prod.precio_promocion : prod.precio;

    document.getElementById('detalleTitulo').textContent = prod.nombre_producto;
    document.getElementById('detalleCuerpo').innerHTML = `
        <div class="text-center mb-3 p-4 rounded-3 bg-light text-success display-3">
            <i class="bi bi-box2-heart"></i>
        </div>
        <p class="text-muted">${prod.descripcion}</p>
        <div class="d-flex justify-content-between align-items-center bg-light p-3 rounded-3 mb-3">
            <span>Precio en La Yunta:</span>
            <span class="fs-4 fw-bold text-success">${formatearCOP(precioFinal)}</span>
        </div>
        <p class="small text-muted mb-3"><i class="bi bi-check2-circle text-success me-1"></i>Unidades disponibles en tienda: <strong>${prod.stock}</strong></p>
        <button class="btn btn-petly-yellow w-100" onclick="agregarAlCarrito(${prod.id_producto})" data-bs-dismiss="modal">
            <i class="bi bi-cart-plus me-1"></i> Agregar al Carrito
        </button>
    `;
    const modal = new bootstrap.Modal(document.getElementById('modalDetalleProducto'));
    modal.show();
};

// Agregar producto al carrito
window.agregarAlCarrito = function(idProducto) {
    const prod = productosCatalogo.find(p => p.id_producto === idProducto);
    if (!prod) return;

    const itemExistente = carrito.find(item => item.id_producto === idProducto);
    const precioFinal = prod.en_promocion && prod.precio_promocion ? prod.precio_promocion : prod.precio;

    if (itemExistente) {
        if (itemExistente.cantidad >= prod.stock) {
            mostrarAlerta('No puedes agregar más unidades que el stock disponible.', 'warning');
            return;
        }
        itemExistente.cantidad += 1;
    } else {
        carrito.push({
            id_producto: prod.id_producto,
            nombre: prod.nombre_producto,
            precio: precioFinal,
            cantidad: 1
        });
    }

    actualizarVistaCarrito();
    mostrarAlerta(`¡"${prod.nombre_producto}" se agregó a tu carrito!`);
};

// Actualizar contador y modal del carrito
function actualizarVistaCarrito() {
    localStorage.setItem('petly_carrito', JSON.stringify(carrito));
    const totalUnidades = carrito.reduce((acc, item) => acc + item.cantidad, 0);
    const totalPrecio = carrito.reduce((acc, item) => acc + (item.precio * item.cantidad), 0);

    document.getElementById('contadorCarrito').textContent = totalUnidades;
    document.getElementById('totalCarrito').textContent = formatearCOP(totalPrecio);

    const contenedorLista = document.getElementById('listaCarrito');
    if (carrito.length === 0) {
        contenedorLista.innerHTML = `<p class="text-center text-muted my-3">Tu carrito está vacío por ahora.</p>`;
        return;
    }

    contenedorLista.innerHTML = carrito.map((item, idx) => `
        <div class="d-flex justify-content-between align-items-center border-bottom py-2">
            <div>
                <h6 class="fw-bold mb-0">${item.nombre}</h6>
                <small class="text-muted">${formatearCOP(item.precio)} x ${item.cantidad} und.</small>
            </div>
            <div class="d-flex align-items-center gap-2">
                <span class="fw-bold text-success">${formatearCOP(item.precio * item.cantidad)}</span>
                <button class="btn btn-sm btn-outline-danger" onclick="eliminarDelCarrito(${idx})">
                    <i class="bi bi-trash"></i>
                </button>
            </div>
        </div>
    `).join('');
}

window.eliminarDelCarrito = function(indice) {
    carrito.splice(indice, 1);
    actualizarVistaCarrito();
};

// Inicializar filtros y buscador cuando cargue la página
document.addEventListener('DOMContentLoaded', () => {
    renderizarProductos(productosCatalogo);
    actualizarVistaCarrito();

    // Configurar fecha mínima de citas para hoy
    const inputFecha = document.getElementById('citaFecha');
    if (inputFecha) {
        inputFecha.min = new Date().toISOString().split('T')[0];
    }

    // Buscador en tiempo real
    document.getElementById('inputBuscador')?.addEventListener('input', (e) => {
        const texto = e.target.value.toLowerCase();
        const filtrados = productosCatalogo.filter(p =>
            p.nombre_producto.toLowerCase().includes(texto) ||
            p.descripcion.toLowerCase().includes(texto)
        );
        renderizarProductos(filtrados);
    });

    // Botones de categoría
    document.querySelectorAll('#filtrosCategorias button').forEach(boton => {
        boton.addEventListener('click', () => {
            document.querySelectorAll('#filtrosCategorias button').forEach(b => b.classList.remove('active'));
            boton.classList.add('active');

            const cat = boton.getAttribute('data-categoria');
            if (cat === 'todas') {
                renderizarProductos(productosCatalogo);
            } else if (cat === 'promociones') {
                renderizarProductos(productosCatalogo.filter(p => p.en_promocion));
            } else {
                renderizarProductos(productosCatalogo.filter(p => String(p.id_categoria) === cat));
            }
        });
    });
});
