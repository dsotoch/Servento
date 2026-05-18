<?php
session_start();
if (!($_SESSION['admin_logged'] ?? false)) {
    header("Location: index.php");
    exit;
}
$adminid = $_SESSION['admin_id'];
$id_mio = $adminid;
$adminemail =  $_SESSION['admin_email'];
$successMsg = $_GET['success'] ?? '';
$errorMsg   = $_GET['error'] ?? '';
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Expires: 0');
date_default_timezone_set('America/Lima');

// ===== CONFIG DB =====
include_once("conexion.php");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$sql = "SELECT * FROM configuraciones LIMIT 1";
$stmtw = $pdo->prepare($sql);
$stmtw->execute();
$roww = $stmtw->fetch(PDO::FETCH_ASSOC);
$logow = $roww["logo"] ?? "";
// ===== JSON helpers =====
function jsonOk($data)
{
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['success' => true, 'data' => $data], JSON_UNESCAPED_UNICODE);
    exit;
}
function jsonError($msg)
{
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['success' => false, 'error' => $msg], JSON_UNESCAPED_UNICODE);
    exit;
}

// ===== AJAX API =====
$action = $_GET['action'] ?? null;
include_once("peticiones.php");
?>
<!doctype html>
<html lang="es">

<head>
    <meta charset="utf-8">
    <title>Admin - Prestaservicios</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <link rel="shortcut icon" href="<?= $logow ?>" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <link rel="stylesheet" href="estilos.css">
    <!-- SweetAlert2 JS -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background: #fff;
            /* blanco */
            color: #000;
            padding: 10px;
            /* negro */
        }

        .btn-primary {
            background-color: #00BFA6 !important;
            border: 1px solid #00BFA6 !important;

        }

        .bg-primary {
            background-color: #00BFA6 !important;
        }

        .card {
            background: #f8f9fa;
            /* un gris claro para las tarjetas */
            border: 1px solid #dee2e6;
        }

        .accent {
            color: #00BFA6;
            /* azul de acento */
        }

        .small-muted {
            color: #6c757d;
            font-size: .9rem;
        }

        .table thead th {
            color: #212529;
            background: #e9ecef;
        }

        .btn-accent {
            background: #00BFA6;
            border: none;
            color: #fff;
        }

        input:read-only {
            background-color: #e9ecef;
            /* gris claro tipo Bootstrap */
            color: #495057;
            /* gris oscuro legible */
            cursor: not-allowed;
            /* indica que no se puede editar */
        }

        .bg-blue {
            background-color: #a3c9f1;
            border: 1px solid #a3c9f1;
            /* azul pastel */
        }
        nav-tabs {
    background: linear-gradient(to right, #9f0b8e, #7b0b70);
    border-radius: 0.5rem;
    padding: 0.25rem;
}

/* Tabs inactivas */
.nav-tabs .nav-link {
    color: black;
    background-color: transparent;
    border: none;
    margin-right: 0.25rem;
    border-radius: 0.5rem 0.5rem 0 0;
    transition: all 0.3s ease;
}

/* Hover para las tabs inactivas */
.nav-tabs .nav-link:hover {
    background-color: rgba(255, 255, 255, 0.15);
    color: white;
}

/* Tab activa */
.nav-tabs .nav-link.active {
    background-color: #b20fc0; /* morado brillante para resaltar */
    color: white !important;
    border: none;
    box-shadow: 0 4px 8px rgba(0,0,0,0.2);
}
.filtros{
    border:1px solid #9f0b8e;
    border-radius:5px;
}
.bg-primary{
    background-color: #9f0b8e !important;
    color: white !important;
     border: 1px solid #9f0b8e !important;  
}
    </style>


</head>

<body>
    <?php include_once("modalpush.php");  ?>
    <input type="hidden" id="id_mio" value="<?= $id_mio ?>">
    <div class="container py-2">

        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-1">
            <h3 class="mb-0"> <span class="accent" style="color:#9f0b8e;">Panel Administrador</span></h3>
            <div><button id="btn-refresh" class="btn btn-sm btn-outline-primary">🔄 Refrescar</button>
                <a href="logout.php" class="btn btn-sm btn-outline-danger">💫 Logout</a>
                <a href="reset.php" id="btn-reset" class="btn btn-sm btn-outline-danger">❌ Eliminar Todo</a>

            </div>

        </div>

    </div>
    <hr>

    <?php if (!empty($successMsg)): ?>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <?= htmlspecialchars($successMsg) ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar"></button>
        </div>
    <?php endif; ?>

    <?php if (!empty($errorMsg)): ?>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <?= htmlspecialchars($errorMsg) ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar"></button>
        </div>
    <?php endif; ?>



    <!-- Tabs -->
    <ul class="nav nav-tabs mb-3" id="mainTabs" role="tablist">
    <li class="nav-item">
        <button class="nav-link active" id="tab-servicios" data-bs-toggle="tab" data-bs-target="#tabServicios">Servicios</button>
    </li>
    <li class="nav-item">
        <button class="nav-link" id="tab-promos" data-bs-toggle="tab" data-bs-target="#tabPromos">Promociones</button>
    </li>
    <li class="nav-item">
        <button class="nav-link" id="tab-clientes" data-bs-toggle="tab" data-bs-target="#tabClientes">Clientes</button>
    </li>
    <li class="nav-item">
        <button class="nav-link" id="tab-pagos" data-bs-toggle="tab" data-bs-target="#tabPagos">Pagos</button>
    </li>
    <li class="nav-item">
        <button class="nav-link" id="tab-cupones" data-bs-toggle="tab" data-bs-target="#tabCupones">Cupones</button>
    </li>
    <li class="nav-item">
        <button class="nav-link" id="tab-codigos" data-bs-toggle="tab" data-bs-target="#tabCodigo">Códigos</button>
    </li>
    <li class="nav-item">
        <button class="nav-link" id="tab-categ" data-bs-toggle="tab" data-bs-target="#tabCate">Categorías</button>
    </li>
    <li class="nav-item">
        <button class="nav-link" id="tab-user" data-bs-toggle="tab" data-bs-target="#tabUser">Usuarios</button>
    </li>
    <li class="nav-item">
        <button class="nav-link" id="tab-config" data-bs-toggle="tab" data-bs-target="#tabConfig">Configuraciones</button>
    </li>
</ul>


    <div class="tab-content">
        <?php include_once("cupones.php")  ?>
        <?php include_once("codigos.php")  ?>

        <!-- TAB SERVICIOS -->
        <div class="tab-pane fade show active" id="tabServicios">
            <div class="card p-3 mb-3  shadow-sm filtros">
                <label for="" class="mb-2"><b>Panel de Filtros</b></label>
                <div class="row g-2 align-items-center">
                    <div class="col-md-6"><input id="qServicios" class="form-control" placeholder="Buscar servicio..."></div>
                    <div class="col-md-2">
                                        <label for="" class="mb-1"><b>Estado Publicación</b></label>
<select id="filterEstadoServicios" class="form-select">
                            <option value="">Todos</option>
                            <option value="pendiente">Pendientes</option>
                            <option value="inactivo">Inactivos</option>
                            <option value="activo">Activos</option>
                        </select></div>
                    <div class="col-md-2">
                                                                <label for="" class="mb-1"><b>Cantidad de Registros</b></label>

                        <select id="limitServicios" class="form-select">
                            <option>25</option>
                            <option selected>50</option>
                            <option>100</option>
                        </select></div>
                </div>
            </div>
            <div class="card p-3 mb-3">
                <div class="d-flex justify-content-between align-items-center mb-2"><strong>Servicios</strong><span id="summaryServicios" class="small-muted"></span></div>
                <div class="table-responsive">
                    <table class="table table-hover align-middle" id="tablaServicios">
                        <thead>
                            <tr>
                                <th class="bg-primary text-white">ID</th>
                                <th class="bg-primary text-white">Título</th>
                                <th class="bg-primary text-white">Publicador</th>
                                <th class="bg-primary text-white">Estado</th>
                                <th class="bg-primary text-white">Fecha</th>
                                <th class="bg-primary text-white">Acciones</th>
                            </tr>
                        </thead>
                        <tbody></tbody>
                    </table>
                </div>
                <nav>
                    <ul class="pagination pagination-sm mb-0" id="paginationServicios"></ul>
                </nav>
            </div>
        </div>

        <?php include_once("categorias.php") ?>
        <?php include_once("uusarios.php") ?>

        <!-- TAB PROMOCIONES -->
        <div class="tab-pane fade" id="tabPromos">
<div class="card p-3 mb-3  shadow-sm filtros">
                <label for="" class="mb-2"><b>Panel de Filtros</b></label>
                                <div class="row g-2 align-items-center">
                    <div class="col-md-6"><input id="qPromos" class="form-control" placeholder="Buscar por título..."></div>
                    <div class="col-md-2">                <label for="" class="mb-1"><b>Estado de la Promocion</b></label>
<select id="filterEstadoPromos" class="form-select">
                            <option value="">Todos</option>
                            <option value="activo">Activos</option>
                            <option value="inactivo">Inactivos</option>
                        </select></div>
                    <div class="col-md-2">                <label for="" class="mb-1"><b>Cantidad de Registros</b></label>
<select id="limitPromos" class="form-select">
                            <option>10</option>
                            <option selected>25</option>
                            <option>50</option>
                        </select></div>
                    <div class="col-md-2 text-end"><button class="btn btn-accent btn-sm" onclick="openPromoEdit(null)">✏️ Nueva Promo</button></div>
                </div>
            </div>
            <div class="card p-3 mb-3">
                <div class="d-flex justify-content-between align-items-center mb-2"><strong>Promociones</strong><span id="summaryPromos" class="small-muted"></span></div>
                <div class="table-responsive">
                    <table class="table table-hover align-middle" id="tablaPromos">
                        <thead>
                            <tr>
                                <th class="bg-primary text-white">Título</th>
                                <th class="bg-primary text-white">Dias de Vigencia</th>
                                <th class="bg-primary text-white">Costo</th>
                                <th class="bg-primary text-white">Tipo</th>
                                <th class="bg-primary text-white">Categoria</th>
                                <th class="bg-primary text-white">Estado</th>

                                <th class="bg-primary text-white">Acciones</th>
                            </tr>
                        </thead>
                        <tbody></tbody>
                    </table>
                </div>
                <nav>
                    <ul class="pagination pagination-sm mb-0" id="paginationPromos"></ul>
                </nav>
            </div>
        </div>
        <!-- TAB CLIENTES -->
        <div class="tab-pane fade" id="tabClientes">
<div class="card p-3 mb-3  shadow-sm filtros">
                <label for="" class="mb-2"><b>Panel de Filtros</b></label>                <div class="row g-2 align-items-center">
                    <div class="col-md-6"><input id="qClientes" class="form-control" placeholder="Buscar por Nombre o Correo ..."></div>
                    <div class="col-md-2">  <label for="" class="mb-1"><b>Estado del Cliente</b></label> <select id="filterEstadoClientes" class="form-select">
                            <option value="">Todos</option>
                            <option value="activo">Activos</option>
                            <option value="inactivo">Inactivos</option>
                        </select></div>
                    <div class="col-md-2">  <label for="" class="mb-1"><b>Cantidad de Registros</b></label> <select id="limitClientes" class="form-select">
                            <option>10</option>
                            <option selected>25</option>
                            <option>50</option>
                        </select></div>
                </div>
            </div>
            <div class="mb-2">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <div>
                        <span class="badge bg-success me-2">Pagado ✅</span>
                <span class="badge bg-danger text-white me-2">Pendiente ⏳</span>
                <span class="badge bg-light text-dark">Sin Promocion Asignada --</span>
                <span class="badge bg-warning text-white me-2">Reasignar Promocion 💵</span>
                    </div>
                    <div><button type="button" class="btn btn-sm btn-info" onclick="enviarMensajeTodos()">Enviar Mensaje a Todos</button></div>
                </div>

            </div>

            <div class="card p-3 mb-3">
                <div class="d-flex justify-content-between align-items-center mb-2"><strong>Promociones</strong><span id="summaryPromos" class="small-muted"></span></div>
                <div class="table-responsive">
                    <table class="table table-bordered table-hover align-middle" id="tablaClientes">
                        <thead>
    <tr>
        <th style="border:1px solid #ffff;" class="bg-primary text-white">ID</th>
        <th style="border:1px solid #ffff;" class="bg-primary text-white">Cliente</th>
        <th style="border:1px solid #ffff;" class="bg-primary text-white">Promocion Asignada(Vigencia) - Costo</th>
        <th style="border:1px solid #ffff;" class="bg-primary text-white">Estado</th>
        <th style="border:1px solid #ffff;" class="bg-primary text-white">Fecha de Registro</th>
        <th style="border:1px solid #ffff;" class="bg-primary text-white text-center">Acciones</th>
    </tr>
</thead>
                        <tbody></tbody>
                    </table>
                </div>
                <nav>
                    <ul class="pagination pagination-sm mb-0" id="paginationClientes"></ul>
                </nav>
            </div>
        </div>


        <?php include_once("pagos.php")  ?>
        <div class="tab-pane fade" id="tabConfig" role="tabpanel">

            <div class="card  p-3 mb-3">
                <h5 class="mb-3">Configuración del Sistema</h5>

                <form id="formConfig" enctype="multipart/form-data">
                    <!-- Nombre del sistema -->
                    <div class="mb-3">
                        <label for="nombre_sistema" class="form-label">Nombre del Sistema</label>
                        <input type="text" class="form-control" id="nombre_sistema" name="nombre_sistema" required placeholder="Ingresa el nombre del sistema" value="">
                    </div>
                    <div class="mb-3">
                        <label for="wsp" class="form-label">Numero de WhatsApp</label>
                        <input type="number" min="0" class="form-control" id="wsp" name="wsp" required placeholder="Ingresa el numero" value="">
                    </div>
                    <div class="mb-3">
                        <label for="contacto" class="form-label">Numero de Contacto</label>
                        <input type="number" min="0" class="form-control" id="contacto" name="contacto" required placeholder="Ingresa el numero" value="">
                    </div>
                    <!-- Moneda -->
                    <div class="mb-3">
                        <label for="moneda_sistema" class="form-label">Moneda</label>
                        <select class="form-select" id="moneda_sistema" name="moneda_sistema" required>
                            <option value="usd">USD - Dólares</option>
                            <option value="mxn">MXN - Pesos Mexicanos</option>
                        </select>
                    </div>

                    <!-- Logo -->
                    <div class="mb-3">
                        <label for="logo_sistema" class="form-label">Logo del Sistema</label>
                        <input type="file" class="form-control" id="logo_sistema" name="logo_sistema" accept="image/*">
                        <small class="text-muted">Se recomienda PNG o JPG, máximo 2MB.</small>
                        <br>
                        <img src="" alt="" id="logo_sistema_pr" style="width: 250px;height: 250px;">
                    </div>

                    <button type="submit" class="btn btn-primary">Guardar Configuración</button>
                </form>
                <hr>
                <div class="card p-4 mx-auto mt-5 shadow rounded" style="max-width: 500px; border-top: 4px solid #00BFA6;">
                    <h4 class="card-title mb-3 text-center" style="color: #00BFA6;">Cambiar Datos Admin</h4>

                    <!-- Mensaje de respuesta -->

                    <form method="post" action="passadmin.php">
                        <!-- Email -->
                        <div class="mb-3">
                            <label for="email_admin" class="form-label">Email</label>
                            <input type="hidden" name="usuario_id" value="<?= $adminid ?>">
                            <input type="email" id="email_admin" name="email_admin" class="form-control" required
                                placeholder="admin@ejemplo.com" value="<?= $adminemail ?>">
                        </div>

                        <!-- Nueva Contraseña -->
                        <div class="mb-3">
                            <label for="new_pass" class="form-label">Nueva Contraseña</label>
                            <input type="password" id="new_pass" name="new_pass" class="form-control"
                                placeholder="Dejar vacío si no se cambia">
                        </div>

                        <button type="submit" class="btn text-white w-100" style="background-color: #00BFA6;">
                            Actualizar Datos
                        </button>
                    </form>
                </div>

            </div>
        </div>




        <!-- MODAL -->
        <div class="modal fade" id="mainModal" tabindex="-1">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="modalTitle">Detalle</h5><button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body" id="modalBody">Cargando...</div>
                    <div class="modal-footer"><button type="button" class="btn btn-danger" data-bs-dismiss="modal">Cerrar</button></div>
                </div>
            </div>
        </div>
        <!-- Modal Cliente -->
        <div id="modalCliente" class="oculto" style="
    position: fixed; inset: 0;
    background: rgba(0,0,0,0.6);
    display: flex; justify-content: center; align-items: center;
">
            <div style="background:#fff;padding:20px;border-radius:12px;width:350px;">

                <h5 style="text-align:center;" class="text-white bg-primary">Clientes Chats</h5>

                <div id="contenedorClientes" style="
    max-height: 60vh;
    overflow-y: auto;
    margin-top: 10px;
    padding-right: 6px;
">
                </div>
                <button onclick="cerrarModal()" style="
            margin-top:10px;padding:8px 14px;background:#333;color:white;border:none;border-radius:8px;width:100%;
        ">Cerrar</button>
            </div>
        </div>
        <div id="modalChat" class="oculto" style="
    position: fixed; inset: 0;
    background: rgba(0,0,0,0.6);
    display: flex; justify-content: center; align-items: center;
">
            <div style="background:#fff;padding:20px;border-radius:12px;width:380px; max-height:80vh; display:flex; flex-direction:column;">

                <h5 style="text-align:center;" class="bg-primary text-white">Chat Completo</h5>

                <div id="contenedorChat" style="
            flex:1;
            overflow-y: auto;
            margin-top: 10px;
            border:1px solid #ddd;
            padding:10px;
            border-radius:8px;
        "></div>

                <button onclick="cerrarModalChat()" style="
            margin-top:10px; padding:8px 14px; background:#333; color:white; border:none; border-radius:8px; width:100%;
        ">Cerrar</button>
            </div>
        </div>
        <div id="modalUsuario2" style="
    display: none; 
    position: fixed; 
    top: 0; left: 0; 
    width: 100%; height: 100%; 
    background: rgba(0,0,0,0.7); 
    align-items: center; 
    justify-content: center; 
    z-index: 9999;
    transition: opacity 0.3s ease;
">
            <div style="
        background: #fefefe; 
        padding: 25px; 
        border-radius: 15px; 
        width: 85%; 
        max-width: 550px; 
        position: relative; 
        display: flex; 
        flex-direction: column; 
        align-items: center;
        box-shadow: 0 8px 30px rgba(0,0,0,0.4);
        font-family: Arial, sans-serif;
        transition: transform 0.3s ease;
    ">
                <!-- Botón cerrar -->
                <span onclick="cerrarModalUsuario()" style="
            position: absolute; 
            top: 12px; right: 20px; 
            font-size: 28px; 
            font-weight: bold; 
            cursor: pointer;
            color: #ff4d4d;
            transition: color 0.2s ease;
        " onmouseover="this.style.color='#ff1a1a'" onmouseout="this.style.color='#ff4d4d'">&times;</span>

               <div style="
    background: linear-gradient(135deg, #1e3a8a, #3b82f6);
    padding:20px;
    border-radius:12px;
    color:white;
    box-shadow: 0 4px 15px rgba(0,0,0,0.2);
    margin-bottom:15px;
">

    <h2 style="margin-top:0; font-size:22px; font-weight:bold;">
        👤 Datos del Usuario
    </h2>

    <div style="
        background: rgba(255,255,255,0.1);
        padding:15px;
        border-radius:10px;
        backdrop-filter: blur(5px);
    ">
        <p style="margin:6px 0;">
            <strong>Nombre:</strong> 
            <span id="usuarioNombre"></span>
        </p>

        <p style="margin:6px 0;">
            <strong>Email:</strong> 
            <span id="usuarioEmail"></span>
        </p>

        <p style="margin:6px 0;">
            <strong>Teléfono:</strong> 
            <span id="usuarioTelefono"></span>
        </p>
    </div>

</div>

                <!-- Documentos / Imágenes -->
                <h3 style="color:#1e40af; margin-top:20px; font-size:20px;"><b>Documentos Subidos</b></h3>
                <div style="
            display: flex; 
            gap: 12px; 
            margin-top: 12px; 
            flex-wrap: wrap; 
            justify-content: center;
        ">
                    <img id="docUsuario1" src=""
                        style="width:110px; height:110px; object-fit:cover; border-radius:10px; border:2px solid #1e40af; cursor:pointer; transition: transform 0.2s, box-shadow 0.2s;"
                        onmouseover="this.style.transform='scale(1.1)'; this.style.boxShadow='0 4px 15px rgba(0,0,0,0.3)'"
                        onmouseout="this.style.transform='scale(1)'; this.style.boxShadow='none'"
                        onclick="window.open(this.src, '_blank')">

                    <img id="docUsuario2" src=""
                        style="width:110px; height:110px; object-fit:cover; border-radius:10px; border:2px solid #1e40af; cursor:pointer; transition: transform 0.2s, box-shadow 0.2s;"
                        onmouseover="this.style.transform='scale(1.1)'; this.style.boxShadow='0 4px 15px rgba(0,0,0,0.3)'"
                        onmouseout="this.style.transform='scale(1)'; this.style.boxShadow='none'"
                        onclick="window.open(this.src, '_blank')">

                    <img id="docUsuario3" src=""
                        style="width:110px; height:110px; object-fit:cover; border-radius:10px; border:2px solid #1e40af; cursor:pointer; transition: transform 0.2s, box-shadow 0.2s;"
                        onmouseover="this.style.transform='scale(1.1)'; this.style.boxShadow='0 4px 15px rgba(0,0,0,0.3)'"
                        onmouseout="this.style.transform='scale(1)'; this.style.boxShadow='none'"
                        onclick="window.open(this.src, '_blank')">

                </div>
            </div>
        </div>


        <style>
            .oculto {
                display: none !important;
            }

            .cardCliente {
                display: flex;
                padding: 10px;
                margin: 8px 0;
                border-radius: 10px;
                background: #f2f2f2;
                align-items: center;
                cursor: pointer;
            }

            .fotoCliente {
                width: 60px;
                height: 60px;
                border-radius: 50%;
                margin-right: 12px;
            }

            .cardCliente:hover {
                background: #e8e8e8;
            }
        </style>



        <script src="enviarpush.js"></script>
        <script>
            async function loadConfig() {
                const r = await fetchJSON(`?action=loadconfig`);
                if (!r.success) {
                    alert('Error al cargar los datos de configuracion.');
                    return;
                }
                const d = r.data || [];
                let nombre_sistema = document.getElementById("nombre_sistema");
                let moneda_sistema = document.getElementById("moneda_sistema");
                let wsp = document.getElementById("wsp");

                let contacto = document.getElementById("contacto");

                let logo_sistema_pr = document.getElementById("logo_sistema_pr");
                nombre_sistema.value = d.nombre_sistema || '';
                moneda_sistema.value = d.moneda || '';
                logo_sistema_pr.src = d.logo;
                wsp.value = d.wsp;
                contacto.value = d.telefono;
            }
            document.getElementById('formConfig').addEventListener('submit', async (e) => {
                e.preventDefault();
                const formData = new FormData(e.target);
                const r = await fetchJSON(`?action=save_config`, {
                    body: formData,
                    method: "POST"
                });
                if (!r.success) {
                    alert('Error al registrar los datos.');
                    return;
                }
                alert(r.data);

                loadConfig();
            });

            const $ = s => document.querySelector(s),
                $$ = s => document.querySelectorAll(s);
            const debounce = (fn, wait = 300) => {
                let t;
                return (...a) => {
                    clearTimeout(t);
                    t = setTimeout(() => fn(...a), wait);
                }
            };
            async function fetchJSON(url, opts) {
                try {
                    const r = await fetch(url, opts);
                    return await r.json();
                } catch (e) {
                    console.error(e);
                    return {
                        success: false,
                        error: e.toString()
                    };
                }
            }

            function escapeHtml(s) {
                if (!s) return '';
                return s.toString().replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;').replaceAll("'", "&#039;");
            }

            // --------- ESTADO SERVICIOS ---------
            let stateServ = {
                offset: 0,
                limit: 50,
                q: '',
                estado: '',
                total: 0
            };
            let stateCl = {
                offset: 0,
                limit: 50,
                q: '',
                estado: '',
                total: 0
            };

            let stateCat = {
                offset: 0,
                limit: 25,
                q: '',
                estado: '',
                total: 0
            };
            //categorias

            async function loadCate() {
                const resp = await fetchJSON(`?action=list_categorias&limit=${stateCat.limit}&offset=${stateCat.offset}&q=${encodeURIComponent(stateCat.q)}&estado=${stateCat.estado}`);
                if (!resp.success) {
                    alert(resp.error);
                    return;
                }
                stateCat.total = resp.data.total || 0;
                const tbody = $('#tablaCategorias tbody');
                tbody.innerHTML = '';
                if (resp.data.items.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" class="text-center small-muted">No hay resultados</td></tr>';
                    return;
                }
                resp.data.items.forEach(c => {
                    const tr = document.createElement('tr');

                    // Mostrar subcategorías con viñetas
                    const subcats = (c.subcategorias || [])
                        .map(s => `
        • ${escapeHtml(s.nombre)}
        <span style="cursor:pointer; color:${s.estado === 'activo' ? '#1e40af' : 'red'}; margin-left:5px;" 
              onclick="editarCategoria(${s.id},'subcate')">🖉</span>
    `)
                        .join('<br>');

                    tr.innerHTML = `
        <td>${c.id}</td>
        <td>
            <strong>📁 ${escapeHtml(c.nombre)}</strong><br>
             ${
            subcats
                ? `<div class="mt-1 small">
                    <em>🔹 Subcategorías:</em><br>${subcats}
                   </div>`
                : ''
        }
        </td>
        <td>              <div class="small text-muted">📝 ${escapeHtml(c.descripcion || '')}</div>
  </td>
        <td>
            ${
                c.estado === 'activo'
                    ? '<span class="badge bg-success">Activo</span>'
                    : '<span class="badge bg-danger">Inactivo</span>'
            }
        </td>
        <td class="small">${convertirAMPM(c.fecha_creacion) || '--'}</td>
        <td>
            <button class="btn btn-sm btn-primary me-1" onclick="editarCategoria(${c.id})" title="Editar categoría">✏️</button>
            <button class="btn btn-sm btn-danger me-1" onclick="eliminarCategoria(${c.id})" title="Eliminar categoría">🗑️</button>
            <button class="btn btn-sm btn-secondary" onclick="toggleEstadoCategoria(${c.id})" title="Cambiar estado">
                ${c.estado === 'activo' ? 'Desactivar' : 'Activar'}
            </button>
        </td>
    `;



                    tbody.appendChild(tr);
                });
                renderPagination('Categorias');
            }
            async function loadUsuarios() {
                const resp = await fetchJSON(`?action=list_usuarios&q=${encodeURIComponent(stateUs.q)}&estado=${stateUs.estado}`);
                if (!resp.success) {
                    alert(resp.error);
                    return;
                }
                stateCat.total = resp.data.total || 0;
                const tbody = $('#tablaUsuarios tbody');
                tbody.innerHTML = '';
                if (resp.data.items.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" class="text-center small-muted">No hay resultados</td></tr>';
                    return;
                }
                resp.data.items.forEach(c => {
                    const tr = document.createElement('tr');

                    // Mostrar subcategorías con viñetas
                    const subcats = (c.subcategorias || [])
                        .map(s => `• ${escapeHtml(s.nombre)}`)
                        .join('<br>');

                    tr.innerHTML = `
        <td>${c.id}</td>
        <td>
            <strong>${escapeHtml(c.nombres)}</strong><br>
           
        </td>
        <td>              <div class="small text-muted">${escapeHtml(c.email || '')}</div>
  </td>
        <td>
            ${
                c.estado === 'ACTIVO'
                    ? '<span class="badge bg-success">Activo</span>'
                    : '<span class="badge bg-danger">Inactivo</span>'
            }
        </td>
        <td class="small">${c.fecha_creacion || '--'}</td>
        <td>
            <button class="btn btn-sm btn-primary me-1" onclick="editarUsuario('${encodeURIComponent(JSON.stringify(c))}')" title="Editar Usuario">✏️</button>
            <button class="btn btn-sm btn-danger me-1" onclick="eliminarUsuario(${c.id})" title="Eliminar Usuario">🗑️</button>
            <button class="btn btn-sm btn-secondary" onclick="toggleEstadoUsuario(${c.id})" title="Cambiar estado">
                ${c.estado === 'ACTIVO' ? 'Desactivar' : 'Activar'}
            </button>
        </td>
    `;



                    tbody.appendChild(tr);
                });
            }

            async function editarCategoria(id, tipo='') {
                try {
                    // Mostrar un loader simple mientras se consulta
                    Swal.fire({
                        title: 'Cargando...',
                        text: 'Obteniendo datos de la categoría...',
                        allowOutsideClick: false,
                        didOpen: () => Swal.showLoading()
                    });

                    // Llamada al backend
                    const resp = await fetch(`?action=listarcate&id=${encodeURIComponent(id)}&tipo=${encodeURIComponent(tipo)}`);
                    const data = await resp.json();

                    Swal.close(); // cerrar el loader
                    if (!data.success) {
                        Swal.fire('Error', data.error || 'No se encontró la categoría', 'error');
                        return;
                    }

                    const cat = data.data;

                    // Llenar campos del formulario
                    document.getElementById('nombreCategoria').value = cat.nombre || '';
                    document.getElementById('descripcionCategoria').value = cat.descripcion || '';
                    document.getElementById('estadoCategoria').value = cat.estado || 'activo';

                    // Tipo de registro
                    const tipoSelect = document.getElementById('tipoCategoria');
                    const contenedorPadre = document.getElementById('contenedorCategoriaPadre');
                    const categoriaPadre = document.getElementById('categoriaPadre');

if (cat.categoria_id) {
    const value = String(cat.categoria_id);

    let existe = Array.from(categoriaPadre.options).some(opt => opt.value === value);

    if (!existe) {
        let option = document.createElement('option');
        option.value = value;
        option.text = 'Categoría temporal';
        categoriaPadre.add(option);
    }

    categoriaPadre.value = value;
categoriaPadre.dispatchEvent(new Event('change', { bubbles: true }));
categoriaPadre.blur();
categoriaPadre.focus();

    tipoSelect.value = 'subcategoria';
    contenedorPadre.style.display = 'block';
  

} else {
    tipoSelect.value = 'categoria';
    contenedorPadre.style.display = 'none';
    categoriaPadre.value = '';
}


                    // Guardar el ID en dataset para saber que es edición
                    const form = document.getElementById('formCategoria');
                    form.dataset.id = cat.id;

                    // Cambiar título del modal
                    document.getElementById('modalCategoriaLabel').textContent = 'Editar Categoría';

                    // Mostrar modal
                    const modal = bootstrap.Modal.getOrCreateInstance(document.getElementById('modalCategoria'));
                    modal.show();

                } catch (err) {
                    console.error('Error al abrir edición:', err);
                    Swal.close();
                    Swal.fire('Error', 'No se pudo cargar la categoría.', 'error');
                }
            }


            async function toggleEstadoCategoria(id) {
                if (!confirm('¿Cambiar estado?')) return;
                const fd = new FormData();
                fd.append('id', id);
                const resp = await fetchJSON('?action=toggle_estadocate', {
                    method: 'POST',
                    body: fd
                });
                if (!resp.success) {
                    alert(resp.error);
                    return;
                }
                loadCate();
            }
            async function eliminarCategoria(id) {
                if (!confirm('¿Eliminar Registro?')) return;
                const fd = new FormData();
                fd.append('id', id);
                const resp = await fetchJSON('?action=eliminarcategoria', {
                    method: 'POST',
                    body: fd
                });
                if (!resp.success) {
                    alert(resp.error);
                    return;
                } else {
                    alert(resp.data);
                }
                loadCate();
            }

            //servicios

            async function loadServicios() {
                const resp = await fetchJSON(`?action=list_servicios&limit=${stateServ.limit}&offset=${stateServ.offset}&q=${encodeURIComponent(stateServ.q)}&estado=${stateServ.estado}`);
                if (!resp.success) {
                    alert(resp.error);
                    return;
                }
                stateServ.total = resp.data.total || 0;
                const tbody = $('#tablaServicios tbody');
                tbody.innerHTML = '';
                if (resp.data.items.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" class="text-center small-muted">No hay resultados</td></tr>';
                    return;
                }
                resp.data.items.forEach(s => {
                    const tr = document.createElement('tr');
                    tr.innerHTML = `
  <td>${s.id}</td>
  <td>
    <strong>📌 ${escapeHtml(s.titulo)}</strong><br>
    <span>🗂 ${escapeHtml(s.categoria)}</span>
    <div class="small-muted">
      📝 ${escapeHtml((s.descripcion || '').slice(0, 120))}${(s.descripcion || '').length > 120 ? '…' : ''}
    </div>
  </td>
<td>${escapeHtml(s.nombre_publicador||'--')}</td>
                    <td>
  ${
    s.estado === 'activo'
      ? '<span class="badge bg-success">Activo</span>'
      : s.estado === 'inactivo'
        ? '<span class="badge bg-danger">Inactivo</span>'
        : '<span class="badge bg-warning text-dark">Pendiente</span>'
  }
</td>

                    <td class="small-muted">${convertirAMPM(s.fecha_creacion)||''}</td><td><button class="btn btn-sm btn-outline-dark me-1" onclick="showDetalle(${s.id})">👁️</button><button class="btn btn-sm btn-accent me-1" onclick="toggleEstado(${s.id})">${s.estado==='activo'?'Desactivar':'Activar'}</button><button title='Eliminar Registro' onclick="Eliminar(${s.id})" class='btn btn-sm btn-danger'>X</button></td>`;
                    tbody.appendChild(tr);
                });
                renderPagination('Servicios');
            }
            async function toggleEstado(id) {
                if (!confirm('¿Cambiar estado del servicio?')) return;
                const fd = new FormData();
                fd.append('id', id);
                const resp = await fetchJSON('?action=toggle_estado', {
                    method: 'POST',
                    body: fd
                });
                if (!resp.success) {
                    alert(resp.error);
                    return;
                }
                loadServicios();
            }
            async function toggleEstadoCliente(id) {
                if (!confirm('¿Cambiar estado del Usuario?')) return;
                const fd = new FormData();
                fd.append('id', id);
                const resp = await fetchJSON('?action=toggle_estadoCliente', {
                    method: 'POST',
                    body: fd
                });
                if (!resp.success) {
                    alert(resp.error);
                    return;
                }
                const activeTab = document.querySelector('.nav-link.active')?.getAttribute('data-bs-target');
                loadClientes();
                if (activeTab) {
                    const tab = document.querySelector(`[data-bs-target="${activeTab}"]`);
                    if (tab) {
                        new bootstrap.Tab(tab).show();
                    }
                }
            }
            async function EliminarCliente(id) {
                if (!confirm('¿Eliminar el Cliente?')) return;

                const fd = new FormData();
                fd.append('id', id);
                const resp = await fetchJSON('?action=deleteCliente', {
                    method: 'POST',
                    body: fd
                });
                if (!resp.success) {
                    alert(resp.error);
                    return;
                } else {
                    alert(resp.data);
                }
                const activeTab = document.querySelector('.nav-link.active')?.getAttribute('data-bs-target');
                loadClientes();
                if (activeTab) {
                    const tab = document.querySelector(`[data-bs-target="${activeTab}"]`);
                    if (tab) {
                        new bootstrap.Tab(tab).show();
                    }
                }
            }
            async function Eliminar(id) {
                if (!confirm('¿Eliminar el servicio?')) return;
                const mensaje = prompt("Ingresa un comentario si es necesario");
                const fd = new FormData();
                fd.append('id', id);
                fd.append('mensaje', mensaje);
                const resp = await fetchJSON('?action=delete', {
                    method: 'POST',
                    body: fd
                });
                if (!resp.success) {
                    alert(resp.error);
                    return;
                } else {
                    alert(resp.data);
                }
                loadServicios();
            }
            async function loadClientes() {
                const resp = await fetchJSON(`?action=list_clientes&limit=${stateCl.limit}&offset=${stateCl.offset}&q=${encodeURIComponent(stateCl.q)}&estado=${stateCl.estado}`);
                if (!resp.success) {
                    alert(resp.error);
                    return;
                }
                stateCl.total = resp.data.total || 0;




                const tbody = $('#tablaClientes tbody');
                tbody.innerHTML = '';
                if (resp.data.items.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" class="text-center small-muted">No hay resultados</td></tr>';
                    return;
                }
                const fechaActual = new Date();
                resp.data.items.forEach(s => {
                    let diffDays = 0;
                    if (s.pago_fecha && (s.pago_estado == "exitoso")) {
                        const [anio, mes, dia] = s.pago_fecha.split(" ")[0].split("-");
                        const fechaAsignada = new Date(anio, mes - 1, dia);
                        fechaAsignada.setDate(fechaAsignada.getDate() + Number(s.dias));
                        const diffTime = fechaActual > fechaAsignada;
                        diffDays = 1;
                    } else {
                        diffDays = 0;
                    }
                    const tr = document.createElement('tr');
                    tr.innerHTML = `<td>${s.id}</td><td><strong>${escapeHtml(s.nombres)}</strong><div class="small-muted">
                    ${escapeHtml((s.email||''))}
                    </div></td><td class="${
    s.pago_fecha && s.pago_monto 
        ? (s.pago_estado === 'pendiente' ? 'bg-danger text-white' : 'bg-success') 
        : ''
}">
    ${
    s.pago_fecha && s.pago_monto
        ? `📅${escapeHtml(s.pago_fecha.split(" ")[0])} - 📅${escapeHtml( sumarDias(s.pago_fecha, s.dias) )} 💰${escapeHtml(s.pago_monto)} `
        : '--'
}

</td>

                    <td>
  ${
    s.estado === 'ACTIVO'
      ? '<span class="badge bg-success">Activo</span>'
      : s.estado === 'INACTIVO'
        ? '<span class="badge bg-danger">Inactivo</span>'
        : '<span class="badge bg-warning text-dark">Pendiente</span>'
  }
</td>

                    <td class="small-muted">${s.fecha_creacion||''}</td><td><button class="btn btn-sm btn-outline-dark me-1" onclick="showDetalleCliente(${s.id})">Ver Pago</button><button class="btn btn-sm btn-accent me-1" onclick="toggleEstadoCliente(${s.id})">${s.estado==='ACTIVO'?'Desactivar':'Activar'}</button><button title='Eliminar Cliente' onclick="EliminarCliente(${s.id})" class='btn btn-sm btn-danger'>X</button> ${diffDays >0 ? `<button title="Reasignar Promocion" onclick="reasignar(${s.id},this)" class="btn btn-sm btn-warning ms-1" >💵</button>` : ''} <button class="btn btn-sm bg-blue text-white" title="Enviar Mensaje" onclick="enviarMensaje(${s.id})">⌨️</button><button class="btn-sm  m-2 bg-primario" onclick="Mensajes(${s.id})" title="Ver Chats"> Ⓜ️  </button><button onclick="verDocumentos(${s.id});" title="Ver Documentos" style="cursor:pointer;">📜</button> </td>`
                    tbody.appendChild(tr);
                });
                renderPagination('Clientes');


            }

            function openModal(user) {
                document.getElementById('usuarioNombre').innerText = user.nombres;
                document.getElementById('usuarioEmail').innerText = user.email;
                document.getElementById('usuarioTelefono').innerText = user.telefono;
                document.getElementById('docUsuario1').src = user.img1;
                document.getElementById('docUsuario2').src = user.img2;
                document.getElementById('docUsuario3').src = user.img3;

                const modal = document.getElementById('modalUsuario2');
                modal.hidden = false; // quitar hidden
                modal.style.display = 'flex';
            }

            function cerrarModalUsuario() {
                document.getElementById('modalUsuario2').style.display = 'none';
            }
            async function verDocumentos(idcliente) {
                const url = `documentos.php?usuario_id=${encodeURIComponent(idcliente)}`;
                try {
                    const response = await fetch(url, {
                        method: "GET",
                        headers: {
                            "Content-Type": "application/json"
                        }
                    });

                    if (!response.ok) {
                        throw new Error("Error en la solicitud");
                    }

                    const data = await response.json();
                    openModal(data.data);

                } catch (error) {
                    console.error("Error:", error);
                }
            }

            function sumarDias(fecha, dias) {
                const f = new Date(fecha);
                f.setDate(f.getDate() + parseInt(dias));
                const año = f.getFullYear();
                const mes = String(f.getMonth() + 1).padStart(2, "0");
                const dia = String(f.getDate()).padStart(2, "0");
                return `${año}-${mes}-${dia}`;
            }

            async function Mensajes(id) {
                try {
                    const url = `apirest.php/chat?usuario_id=${encodeURIComponent(id)}`;

                    const response = await fetch(url, {
                        method: "GET",
                        headers: {
                            "Content-Type": "application/json"
                        }
                    });

                    if (!response.ok) {
                        throw new Error("Error en la solicitud");
                    }

                    const data = await response.json();
                    mostrarModalClientes(data.mensaje, id);

                } catch (error) {
                    console.error("Error:", error);
                }
            }

            function cerrarModal() {
                let contenedor = document.getElementById("contenedorClientes");
                contenedor.innerHTML = ""; // limpiar
                document.getElementById("modalCliente").classList.add("oculto");
            }

            function mostrarModalClientes(lista, id_mio) {

                let contenedor = document.getElementById("contenedorClientes");
                contenedor.innerHTML = ""; // limpiar
                lista.forEach(cliente => {
                    let card = `
        <div class="cardCliente" onclick="verChat(${cliente.id},${id_mio})">
            <img src="${cliente.foto}" class="fotoCliente" />
            <div class="datosCliente">
                <h6>${cliente.nombres}</h6>
            </div>
        </div>
        `;
                    contenedor.innerHTML += card;
                });

                document.getElementById("modalCliente").classList.remove("oculto");
            }

            function mostrarModalChat(historial, destino) {

                let cont = document.getElementById("contenedorChat");
                cont.innerHTML = "";

                historial.forEach(msg => {

                    const esMio = msg.destinatario == destino;

                    let burbuja = `
            <div style="
                display: flex;
                justify-content: ${esMio ? 'flex-end' : 'flex-start'};
                margin-bottom: 8px;
            ">
                <div style="
                    background:${esMio ? '#c8ffc8' : '#e6e6e6'};
                    padding:8px 12px;
                    border-radius:12px;
                    max-width:75%;
                    display:inline-block;
                ">
                    ${msg.mensaje}
                </div>
            </div>
        `;

                    cont.innerHTML += burbuja;
                });

                document.getElementById("modalChat").classList.remove("oculto");

                // Scroll al último mensaje
                cont.scrollTop = cont.scrollHeight;
            }


            function cerrarModalChat() {
                document.getElementById("modalChat").classList.add("oculto");
            }


            async function verChat(destino, id_mio) {
                try {
                    const url = `apirest.php/chat?remitente=${encodeURIComponent(destino)}&destinatario=${encodeURIComponent(id_mio)}`;

                    const response = await fetch(url);
                    if (!response.ok) throw new Error("Error al cargar el chat");

                    const historial = await response.json();
                    mostrarModalChat(historial.mensajes, destino);

                } catch (error) {
                    console.error("Error:", error);
                }
            }


            async function reasignar(id, btn) {

                if (!confirm("¿Reasignar la misma Promoción al cliente?")) {
                    return;
                }
                btn.innerHTML = "Procesando...";
                btn.disabled = true;
                const fd = new FormData();
                fd.append('id', id);
                const resp = await fetchJSON('?action=reasignarplan', {
                    method: 'POST',
                    body: fd
                });
                btn.innerHTML = "💵";
                btn.disabled = false;
                if (!resp.success) {
                    alert(resp.error);
                    return;
                } else {
                    let innerData = JSON.parse(resp.data); // convierte la cadena en objeto
                    if (innerData.error) {
                        alert(innerData.error);

                    } else {
                        alert(innerData.data.mensaje);

                    }
                }
                const activeTab = document.querySelector('.nav-link.active')?.getAttribute('data-bs-target');
                loadClientes();
                if (activeTab) {
                    const tab = document.querySelector(`[data-bs-target="${activeTab}"]`);
                    if (tab) {
                        new bootstrap.Tab(tab).show();
                    }
                }
            }

            async function EliminarPromocion(id) {
                if (!confirm('¿Eliminar la Promoción?')) return;
                const fd = new FormData();
                fd.append('id', id);
                const resp = await fetchJSON('?action=delete_promo', {
                    method: 'POST',
                    body: fd
                });
                if (!resp.success) {
                    alert(resp.error);
                    return;
                } else {
                    alert(resp.data);
                }
                const activeTab = document.querySelector('.nav-link.active')?.getAttribute('data-bs-target');
                loadPromos();
                if (activeTab) {
                    const tab = document.querySelector(`[data-bs-target="${activeTab}"]`);
                    if (tab) {
                        new bootstrap.Tab(tab).show();
                    }
                }
            }

            async function showDetalleCliente(idUsuario) {
                const r = await fetchJSON(`?action=detalle_usuario&id=${idUsuario}`);
                if (!r.success) {
                    alert('Error al cargar los datos del usuario.');
                    return;
                }

                const data = r.data;
                const pago = data.asignacion_pago || null; // Pago actual
                const promociones = data.promociones || []; // Lista de promociones activas
                const servicios = data.servicios || []; // Lista de servicios del usuario

                const modal = new bootstrap.Modal($('#mainModal'));

                $('#modalTitle').textContent = `Usuario #${idUsuario} — ${escapeHtml(data.usuario.nombres || 'Sin nombre')}`;

                // Construir la sección de servicios
                const grouped = {};
                servicios.forEach(s => {
                    if (!grouped[s.categoria]) grouped[s.categoria] = [];
                    grouped[s.categoria].push(s);
                });

                let serviciosHTML = '';
                for (const categoria in grouped) {
                    const items = grouped[categoria];
                    serviciosHTML += `
            <div class="card mb-3 shadow-sm">
                <div class="card-body p-2 d-flex justify-content-between align-items-center">
                    <div>
                        <strong>${categoria}</strong>
                        <span class="text-muted ms-2">(${items.length})</span>
                    </div>
                    <div class="d-flex flex-wrap gap-2">
                        ${items.map(s => `
                            <span class="badge bg-primary text-white">${escapeHtml(s.titulo)}</span>
                        `).join('')}
                    </div>
                </div>
            </div>
        `;
                }


                // Construir la sección de promociones
                let promocionesHTML = '<div class="row g-2 mb-3">';

                promociones.forEach(p => {
                    promocionesHTML += `
        <div class="col-12 col-md-6 col-lg-4">
            <div class="card shadow-sm h-100">
                <div class="card-body d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="card-title mb-1">${escapeHtml(p.titulo)}</h6>
                        <small class="text-muted">${escapeHtml(p.descripcion || '')}</small>
                    </div>
                    <span class="badge bg-success fs-6 ms-2">${p.costo.toFixed(2)}</span>
                </div>
            </div>
        </div>
    `;
                });

                promocionesHTML += '</div>';


                // Formulario para asignar monto o promoción
                const formHTML = `
        <form id="asignarPagoForm">
             <input type="hidden" value="${idUsuario}" name="usuario_id">
            <div class="mb-3">
                <label for="promocion" class="form-label">Promoción</label>
                <select class="form-select" id="promocion" name="promocion" required>
                    <option value="">-- Ninguna --</option>
                    ${promociones.map(p => `<option data-dias="${p.dias_vigencia}" data-precio="${p.costo}" value="${p.id}">${escapeHtml(p.titulo)}*${escapeHtml(p.categoria)} -  💰 ${p.costo}</option>`).join('')}
                </select>
            </div>
           <div class="mb-3 position-relative">
    <label for="monto" class="form-label">Monto a pagar</label>
    <div class="input-group mb-2">
        <input type="number" class="form-control" id="monto" min="0" name="monto" value="${pago ? pago.monto : ''}" step="0.01" readonly required>
        <button class="btn btn-outline-secondary" type="button" id="editMontoBtn" title="Editar monto">
          ✏️
        </button>
    </div>
     <label for="fecha_asignada" class="form-label">Fecha de Pago</label>
    <div class="input-group">
        <input type="date" class="form-control" id="fecha_asignada" name="fecha_asignada"    required>
        
    </div>
</div>
            <button type="submit" id="btnasin" class="btn btn-primary">Asignar</button>
        </form>
    `;

               $('#modalBody').innerHTML = `
<div style="font-family:Arial, sans-serif; padding:10px;">

    <!-- PROMOCIÓN ACTUAL -->
    <div style="margin-bottom:15px;">
        <div style="font-weight:bold; margin-bottom:8px;">🎫 Promoción actual Asignado</div>
        
        <div style="
            border:1px solid #ddd;
            border-radius:8px;
            padding:12px;
            background:#f8f9fa;
        ">
            ${
              pago
                ? `
                <div style="margin-bottom:5px;"><strong>Monto:</strong>  ${pago.monto}</div>
                <div style="margin-bottom:5px;">
                    <strong>Estado:</strong> 
                    <span style="
                        padding:3px 10px;
                        border-radius:20px;
                        font-size:12px;
                        color:white;
                        background:${pago.estado === 'activo' ? '#28a745' : '#6c757d'};
                    ">
                        ${escapeHtml(pago.estado)}
                    </span>
                </div>
                <div style="margin-bottom:5px;"><strong>Plan:</strong> ${escapeHtml(pago.descripcion_plan)}</div>
                <div><strong>Fecha:</strong> ${escapeHtml(pago.fecha_asignada)}</div>
                `
                : `<div style="color:#6c757d;">No hay pago registrado</div>`
            }
        </div>
    </div>

    <!-- SERVICIOS -->
    <div style="margin-bottom:15px;">
        <div style="font-weight:bold; margin-bottom:8px;">
            🛠 Servicios del usuario (${servicios.length})
        </div>

        <div style="
            border:1px solid #ddd;
            border-radius:8px;
            padding:10px;
            background:white;
            max-height:200px;
            overflow:auto;
        ">
            ${serviciosHTML || '<div style="color:#6c757d;">Sin servicios</div>'}
        </div>
    </div>

    <!-- PROMOCIONES -->
    <div style="margin-bottom:15px;">
        <div style="font-weight:bold; margin-bottom:8px;">
            🎯 Promociones disponibles
        </div>

        <div style="
            border:1px solid #ddd;
            border-radius:8px;
            padding:10px;
            background:white;
            max-height:200px;
            overflow:auto;
        ">
            ${promocionesHTML || '<div style="color:#6c757d;">No hay promociones</div>'}
        </div>
    </div>

    <!-- FORMULARIO -->
    <div>
        <div style="font-weight:bold; margin-bottom:8px;">
            ➕ Asignar nueva promoción / pago
        </div>

        <div style="
            border:1px solid #ddd;
            border-radius:8px;
            padding:12px;
            background:#f8f9fa;
        ">
            ${formHTML}
        </div>
    </div>

</div>
`;

                // Manejar submit del formulario
                $('#asignarPagoForm').addEventListener('submit', async function(e) {
                    e.preventDefault();
                    const btnasin = document.getElementById("btnasin");
                    if (!confirm("¿Seguro de Asignar esta Promocion  al Cliente?")) {
                        return;
                    }
                    const formData = new FormData(this);
                    btnasin.innerHTML = "Procesando...";
                    btnasin.disabled = true;
                    const resp = await fetchJSON(`?action=asignar_pago`, {
                        method: 'POST',
                        body: formData
                    });
                    btnasin.innerHTML = "Asignar";
                    btnasin.disabled = false;
                    if (resp.success) {
                        alert('Pago o promoción asignada correctamente');
                        modal.hide();
                        loadClientes();
                        loadPagos();
                    } else {
                        alert('Error: ' + resp.error);
                    }
                });
                const promocionSelect = document.getElementById('promocion');
                const montoInput = document.getElementById('monto');
                const editBtn = document.getElementById('editMontoBtn');

                // Evento para llenar monto según la promoción
                promocionSelect.addEventListener('change', () => {
                    const selectedOption = promocionSelect.selectedOptions[0];
                    const precio = selectedOption ? selectedOption.dataset.precio : '';
                    if (precio) {
                        montoInput.value = parseFloat(precio).toFixed(2);
                        montoInput.setAttribute('readonly', true); // Mantener readonly
                    } else if (!precio && !montoInput.dataset.manual) {
                        montoInput.value = '';
                    }
                });

                // Evento del lápiz para habilitar edición manual
                editBtn.addEventListener('click', () => {
                    montoInput.removeAttribute('readonly');
                    montoInput.dataset.manual = true; // Marca que el usuario editó manualmente
                    montoInput.focus();
                });

                modal.show();
            }


           async function showDetalle(id) {
    const r = await fetchJSON(`?action=list_servicios&limit=1&offset=0&q=${id}`);
    const s = r.success && r.data.items[0] ? r.data.items[0] : null;

    const modal = new bootstrap.Modal($('#mainModal'));

    if (!s) {
        $('#modalTitle').textContent = 'Detalle';
        $('#modalBody').innerHTML = `
            <div style="padding:20px; text-align:center; color:#6c757d;">
                Detalle no disponible
            </div>`;
        modal.show();
        return;
    }

    $('#modalTitle').textContent = `Servicio #${s.id} — ${s.titulo}`;

    $('#modalBody').innerHTML = `
    <div style="padding:10px; font-family:Arial, sans-serif;">

        <!-- INFO PRINCIPAL -->
        <div style="display:flex; gap:10px; margin-bottom:15px; flex-wrap:wrap;">

            <div style="flex:1; min-width:200px; padding:12px; border:1px solid #ddd; border-radius:8px; background:#f8f9fa;">
                <div style="font-size:13px; color:#6c757d;">👤 Publicador</div>
                <div style="font-weight:bold;">${escapeHtml(s.nombre_publicador || '--')}</div>
            </div>

            <div style="flex:1; min-width:120px; padding:12px; border:1px solid #ddd; border-radius:8px; text-align:center;">
                <div style="font-size:13px; color:#6c757d;">Estado</div>
                <div style="
                    display:inline-block;
                    padding:4px 10px;
                    border-radius:20px;
                    color:white;
                    font-size:12px;
                    background:${s.estado === 'activo' ? '#28a745' : '#6c757d'};
                ">
                    ${escapeHtml(s.estado || '--')}
                </div>
            </div>

            <div style="flex:1; min-width:150px; padding:12px; border:1px solid #ddd; border-radius:8px; text-align:center;">
                <div style="font-size:13px; color:#6c757d;">Publicado</div>
                <div style="font-weight:bold;">${escapeHtml(convertirAMPM(s.fecha_creacion) || '--')}</div>
            </div>

        </div>

        <!-- IMÁGENES -->
        <div style="margin-bottom:15px;">
            <div style="font-weight:bold; margin-bottom:8px;">📸 Imágenes</div>
            <div style="display:flex; gap:10px; flex-wrap:wrap;">

                ${[s.imagen1, s.imagen2, s.imagen3].map(img => `
                    <div style="
                        flex:1;
                        min-width:150px;
                        max-width:32%;
                        border:1px solid #ddd;
                        border-radius:8px;
                        overflow:hidden;
                        background:white;
                    ">
                        <img 
                            src="https://cucalacurra.servirentamx.com/${img}" 
                            style="
                                width:100%;
                                height:160px;
                                object-fit:cover;
                                display:block;
                                cursor:pointer;
                                transition:0.3s;
                            "
                            onmouseover="this.style.transform='scale(1.05)'"
                            onmouseout="this.style.transform='scale(1)'"
                        >
                    </div>
                `).join('')}

            </div>
        </div>

        <!-- DESCRIPCIÓN -->
        <div>
            <div style="font-weight:bold; margin-bottom:8px;">📝 Descripción</div>
            <div style="
                padding:12px;
                border:1px solid #ddd;
                border-radius:8px;
                background:#f8f9fa;
                line-height:1.5;
                white-space:pre-line;
            ">
                ${escapeHtml(s.descripcion || 'Sin descripción')}
            </div>
        </div>

    </div>
    `;

    modal.show();
}
function convertirAMPM(fechaStr) {
  const fecha = new Date(fechaStr.replace(' ', 'T'));


  return fecha.toLocaleString('es-MX', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false
  }).replace(',', '');
}
            async function showDetallePago(id) {
                const r = await fetchJSON(`?action=list_servicios&limit=1&offset=0&q=${id}`);
                const s = r.success && r.data.items[0] ? r.data.items[0] : null;
                const modal = new bootstrap.Modal($('#mainModal'));
                if (!s) {
                    $('#modalTitle').textContent = 'Detalle';
                    $('#modalBody').innerHTML = '<div class="small-muted">Detalle no disponible</div>';
                    modal.show();
                    return;
                }
                $('#modalTitle').textContent = `Servicio #${s.id} — ${s.titulo}`;
                $('#modalBody').innerHTML = `<div><strong>Publicador:</strong> ${escapeHtml(s.nombre_publicador||'--')}</div><div><strong>Estado:</strong> ${escapeHtml(s.estado||'--')}</div><div><strong>Publicado:</strong> ${escapeHtml(s.fecha_creacion||'--')}
                <div class="d-flex gap-3 mt-2">
    <img src="http://localhost/backeend/${s.imagen1}" class="img-fluid" alt="Imagen 1" style="width:250px; height:150px; object-fit:contain;">
    <img src="http://localhost/backeend/${s.imagen2}" class="img-fluid" alt="Imagen 2" style="width:250px; height:150px; object-fit:contain;">
    <img src="http://localhost/backeend/${s.imagen3}" class="img-fluid" alt="Imagen 3" style="width:250px; height:150px; object-fit:contain;">
</div>


                </div><hr><div>${escapeHtml(s.descripcion||'')}</div>`;
                modal.show();
            }

            // --------- ESTADO PROMOS ---------//

            let statePromos = {
                offset: 0,
                limit: 25,
                q: '',
                estado: '',
                total: 0
            };
            async function loadPromos() {
                const resp = await fetchJSON(`?action=list_promos&limit=${statePromos.limit}&offset=${statePromos.offset}&q=${encodeURIComponent(statePromos.q)}&estado=${statePromos.estado}`);
                if (!resp.success) {
                    alert(resp.error);
                    return;
                }
                statePromos.total = resp.data.total || 0;
                const tbody = $('#tablaPromos tbody');
                tbody.innerHTML = '';
                if (resp.data.items.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="7" class="text-center small-muted">No hay resultados</td></tr>';
                    return;
                }
                resp.data.items.forEach(p => {
                    const tr = document.createElement('tr');
                    tr.innerHTML = `<td>${escapeHtml(p.titulo||'--')}</td><td>${p.dias_vigencia}</td><td>${p.costo||0}</td><td>${p.tipo||'--'}</td><td>${p.categoria||'--'}</td><td>
  <span class="badge ${p.estado === 'activo' ? 'bg-success' : 'bg-danger'}">
    ${p.estado === 'activo' ? 'Activo' : 'Inactivo'}
  </span>
</td>
<td><button class="btn btn-sm btn-accent" onclick="togglePromoEstado(${p.id})">${p.estado==='activo'?'Desactivar':'Activar'}</button> <button title="Eliminar Promocion" onclick="EliminarPromocion(${p.id})"  class="btn btn-danger btn-sm">X</button></td>`;
                    tbody.appendChild(tr);
                });
                renderPagination('Promos');
            }

            async function addPromocion(event) {
                event.preventDefault();
                if (document.getElementById("tipo").value == "categoria" && document.getElementById("categoria").value == "") {
                    alert("Selecione una Categoria");
                    return;
                }
                if (!confirm('¿Registrar Promoción?')) return;

                const form = document.getElementById('formPromocion');
                const fd = new FormData(form);

                const resp = await fetchJSON('?action=add_promo', {
                    method: 'POST',
                    body: fd
                });

                if (!resp.success) {
                    alert(resp.error || 'Error al registrar la promoción.');
                    return;
                }

                alert('✅ Promoción registrada correctamente');
                const modal = bootstrap.Modal.getInstance(document.getElementById('mainModal'));
                modal.hide();
                const activeTab = document.querySelector('.nav-link.active')?.getAttribute('data-bs-target');
                loadPromos();
                if (activeTab) {
                    const tab = document.querySelector(`[data-bs-target="${activeTab}"]`);
                    if (tab) {
                        new bootstrap.Tab(tab).show();
                    }
                }
            }
            async function togglePromoEstado(id) {
                if (!confirm('¿Cambiar estado de la Promoción?')) return;
                const fd = new FormData();
                fd.append('id', id);
                const resp = await fetchJSON('?action=toggle_estado_promo', {
                    method: 'POST',
                    body: fd
                });
                if (!resp.success) {
                    alert(resp.error);
                    return;
                }
                const activeTab = document.querySelector('.nav-link.active')?.getAttribute('data-bs-target');
                loadPromos();
                if (activeTab) {
                    const tab = document.querySelector(`[data-bs-target="${activeTab}"]`);
                    if (tab) {
                        new bootstrap.Tab(tab).show();
                    }
                }
            }
            async function toggleEstadoUsuario(id) {
                if (!confirm('¿Cambiar estado?')) return;
                const fd = new FormData();
                fd.append('id', id);
                const resp = await fetchJSON('?action=toggle_estadousuario', {
                    method: 'POST',
                    body: fd
                });
                if (!resp.success) {
                    alert(resp.error);
                    return;
                }
                const activeTab = document.querySelector('.nav-link.active')?.getAttribute('data-bs-target');
                loadUsuarios();
                if (activeTab) {
                    const tab = document.querySelector(`[data-bs-target="${activeTab}"]`);
                    if (tab) {
                        new bootstrap.Tab(tab).show();
                    }
                }
            }
            async function eliminarUsuario(id) {
                if (!confirm('¿Eliminar Registro?')) return;
                const fd = new FormData();
                fd.append('id', id);
                const resp = await fetchJSON('?action=eliminarusuario', {
                    method: 'POST',
                    body: fd
                });
                if (!resp.success) {
                    alert(resp.error);
                    return;
                } else {
                    alert(resp.data);
                }
                const activeTab = document.querySelector('.nav-link.active')?.getAttribute('data-bs-target');
                loadUsuarios();
                if (activeTab) {
                    const tab = document.querySelector(`[data-bs-target="${activeTab}"]`);
                    if (tab) {
                        new bootstrap.Tab(tab).show();
                    }
                }
            }


            // --------- MODALES PROMO ---------
            function openPromoEdit(id) {
                const modal = new bootstrap.Modal($('#mainModal'));
                $('#modalTitle').textContent = id ? 'Editar Promoción' : 'Nueva Promoción';
                $('#modalBody').innerHTML = `
  <form id="formPromocion" class="text-start" onsubmit="addPromocion(event)">
    <div class="mb-3">
      <label for="titulo" class="form-label">Título</label>
      <input type="text" id="titulo" name="titulo" class="form-control" maxlength="100" required>
    </div>

    <div class="mb-3">
      <label for="descripcion" class="form-label">Descripción</label>
      <textarea id="descripcion" name="descripcion" class="form-control" rows="3"></textarea>
    </div>

  <div class="row">
  <div class="col-md-6 mb-3">
    <label for="costo" class="form-label">Costo</label>
    <input type="number" id="costo" name="costo" class="form-control" min="0" required>
  </div>
<div class="col-md-6 mb-3">
    <label for="tipo" class="form-label">Dias de Vigencia</label>
        <input type="number" id="vigencia" name="vigencia" class="form-control" min="0" required>

  </div>
  <div class="col-md-12 mb-3">
    <label for="tipo" class="form-label">Tipo de promoción</label>
    <select id="tipo" name="tipo" class="form-select" onchange="toggleCategoriaField()">
      <option value="general">General (todos los usuarios)</option>
      <option value="nuevo_usuario">Solo nuevos usuarios</option>
      <option value="categoria">Por categoría de servicio</option>
      <option value="publicacion">Por cada Publicacion</option>
      <option value="dias">Por dias de Vigencia</option>
      <option value="golden">Plan Golden</option>

    </select>
  </div>
</div>

    <div class="mb-3" id="categoriaField" style="display:none;">
      <label for="categoria" class="form-label">Categoría de servicio</label>
      <select id="categoria" name="categoria" class="form-select">

      </select>
    </div>

   

    <div class="text-center mt-3">
      <button type="submit" class="btn btn-primary">📂 Guardar</button>
    </div>
  </form>
        `;
                modal.show();
            }
            async function cargarCategorias() {
                try {
                    const res = await fetch('categorias_listar.php');
                    const data = await res.json();

                    const select = document.getElementById('categoria');
                    select.innerHTML = ''; // Limpiamos

                    if (data.status === 'ok' && data.categorias.length > 0) {
                        select.innerHTML = '<option value="">Selecciona una categoría</option>';
                        data.categorias.forEach(cat => {
                            const opt = document.createElement('option');
                            opt.value = cat.nombre;
                            opt.textContent = cat.nombre;
                            select.appendChild(opt);
                        });
                    } else {
                        select.innerHTML = '<option value="">No hay categorías disponibles</option>';
                    }

                } catch (err) {
                    console.error('Error al cargar categorías:', err);
                    document.getElementById('categoria').innerHTML =
                        '<option value="">Error al cargar</option>';
                }
            }



            async function toggleCategoriaField() {
                const tipo = document.getElementById('tipo').value;
                const inputTitulo = document.getElementById('titulo');
                document.getElementById('categoriaField').style.display = tipo === 'categoria' ? 'block' : 'none';
                if (tipo == "golden") {
                    inputTitulo.value = "PLAN GOLDEN";
                    inputTitulo.readOnly = true;
                } else {
                    if (tipo == "publicacion") {
                        inputTitulo.value = "PLAN PUBLICACION";
                        inputTitulo.readOnly = true;
                    } else {
                        inputTitulo.value = "";
                        inputTitulo.readOnly = false;
                    }

                }
                await cargarCategorias();
            }
            // --------- UTIL ---------
            function renderPagination(type) {
                let s = "";
                let ul = "";
                switch (type) {
                    case "Servicios":
                        s = stateServ;
                        ul = $('#paginationServicios');
                        break;
                    case "Clientes":
                        s = stateCl;
                        ul = $('#paginationClientes');
                        break;
                    case "Pagos":
                        s = window.statePag;
                        ul = $('#paginationPagos');
                        break;
                    case "Categorias":
                        s = window.statePag;
                        ul = $('#paginationCategorias');
                        break;
                    default:
                        s = statePromos;
                        ul = $('#paginationPromos');
                        break;
                }

                ul.innerHTML = '';
                const totalPages = Math.ceil(s.total / s.limit);
                for (let i = 0; i < totalPages; i++) {
                    const li = document.createElement('li');
                    li.className = 'page-item' + (i === s.offset / s.limit ? ' active' : '');
                    li.innerHTML = `<button class="page-link">${i+1}</button>`;
                    li.querySelector('button').addEventListener('click', () => {
                        s.offset = i * s.limit;
                        if (type === 'Servicios') loadServicios();
                        else loadPromos();
                    });
                    ul.appendChild(li);
                }
            }
            document.getElementById('btn-reset').addEventListener('click', function(event) {
                event.preventDefault(); // Evita la navegación inmediata
                const confirmar = confirm("⚠️ ¿Estás seguro de eliminar todos los datos? Esta acción no se puede deshacer.");
                if (confirmar) {
                    window.location.href = this.href; // Si confirma, navegar al enlace
                }
            });

            let stateUs = {
                offset: 0,
                limit: 50,
                q: '',
                estado: '',
                total: 0
            };
            // --------- EVENTOS ---------
            $('#qCategorias').addEventListener('input', debounce(e => {
                stateCat.q = e.target.value;
                stateCat.offset = 0;
                loadCate();
            }));
            $('#filterEstadoCategorias').addEventListener('change', e => {
                stateCat.estado = e.target.value;
                stateCat.offset = 0;
                loadCate();
            });
            $('#limitCategorias').addEventListener('change', e => {
                stateCat.limit = parseInt(e.target.value);
                stateCat.offset = 0;
                loadCate();
            });
            $('#qUsuario').addEventListener('input', debounce(e => {
                stateUs.q = e.target.value;
                stateUs.offset = 0;
                loadUsuarios();
            }));
            $('#filterEstadoUsuario').addEventListener('change', e => {
                stateUs.estado = e.target.value;
                stateUs.offset = 0;
                loadUsuarios();
            });

            $('#qCupones').addEventListener('input', debounce(e => {
                window.stateCupon.q = e.target.value;
                window.stateCupon.offset = 0;
                loadCupones();
            }));
            $('#filterEstadoCupones').addEventListener('change', e => {
                window.stateCupon.estado = e.target.value;
                window.stateCupon.offset = 0;
                loadCupones();
            });
            $('#limitCupones').addEventListener('change', e => {
                window.stateCupon.limit = parseInt(e.target.value);
                window.stateCupon.offset = 0;
                loadCupones();
            });

            $('#qServicios').addEventListener('input', debounce(e => {
                stateServ.q = e.target.value;
                stateServ.offset = 0;
                loadServicios();
            }));
            $('#filterEstadoServicios').addEventListener('change', e => {
                stateServ.estado = e.target.value;
                stateServ.offset = 0;
                loadServicios();
            });
            $('#limitServicios').addEventListener('change', e => {
                stateServ.limit = parseInt(e.target.value);
                stateServ.offset = 0;
                loadServicios();
            });


            $('#qCodigos').addEventListener('input', debounce(e => {
                window.stateCodigos.q = e.target.value;
                window.stateCodigos.offset = 0;
                loadCodigos();
            }));
            $('#filterEstadoCodigos').addEventListener('change', e => {
                window.stateCodigos.estado = e.target.value;
                window.stateCodigos.offset = 0;
                loadCodigos();
            });
            $('#limitCodigos').addEventListener('change', e => {
                window.stateCodigos.limit = parseInt(e.target.value);
                window.stateCodigos.offset = 0;
                loadCodigos();
            });


            $('#qPromos').addEventListener('input', debounce(e => {
                statePromos.q = e.target.value;
                statePromos.offset = 0;
                loadPromos();
            }));
            $('#filterEstadoPromos').addEventListener('change', e => {
                statePromos.estado = e.target.value;
                statePromos.offset = 0;
                loadPromos();
            });
            $('#qPagos').addEventListener('input', debounce(e => {
                window.statePag.q = e.target.value;
                window.statePag.offset = 0;
                loadPagos();
            }));
            $('#filterEstadoPagos').addEventListener('change', e => {
                window.statePag.estado = e.target.value;
                window.statePag.offset = 0;
                loadPagos();
            });
            $('#filterEstadoClientes').addEventListener('change', e => {
                stateCl.estado = e.target.value;
                stateCl.offset = 0;
                loadClientes();
            });
            $('#qClientes').addEventListener('input', debounce(e => {
                stateCl.q = e.target.value;
                stateCl.offset = 0;
                loadClientes();
            }));
            $('#limitPromos').addEventListener('change', e => {
                statePromos.limit = parseInt(e.target.value);
                statePromos.offset = 0;
                loadPromos();
            });
            $('#limitPagos').addEventListener('change', e => {
                window.statePag.limit = parseInt(e.target.value);
                window.statePag.offset = 0;
                loadPagos();
            });
            $('#limitClientes').addEventListener('change', e => {
                stateCl.limit = parseInt(e.target.value);
                stateCl.offset = 0;
                loadClientes();
            });

            $('#btn-refresh').addEventListener('click', async () => {
                const btn = $('#btn-refresh');
                const act = btn.innerHTML;
                btn.innerHTML = "Procesando...";

                try {
                    await loadServicios();
                    await loadPromos();
                    await loadPagos();
                    await loadClientes();
                    await loadConfig();
                    await loadCate();
                    await loadUsuarios();
                    await loadCupones();
                    await loadCodigos();

                } catch (e) {
                    console.error("Error al cargar datos:", e);
                } finally {
                    btn.innerHTML = act;
                }
            });

            // --------- INICIAL ---------
            loadServicios();
            loadPromos();
            loadPagos();
            loadClientes();
            loadConfig();
            loadCate();
            loadUsuarios();
            loadCupones();
            loadCodigos();
        </script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>

</html>