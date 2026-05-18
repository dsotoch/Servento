<?php
?>

<body>
    <div class="container py-4">


        <div class="tab-content">


            <!-- TAB PAGOS -->
            <div class="tab-pane fade" id="tabPagos">
<div class="card p-3 mb-3  shadow-sm filtros">
                <label for="" class="mb-2"><b>Panel de Filtros</b></label>                    <div class="row g-2 align-items-center">
                        <div class="col-md-6"><input id="qPagos" class="form-control" placeholder="Buscar Pago... por fecha yyyy-m-d"></div>
                        <div class="col-md-2"><label for="" class="mb-1"><b>Estado del Pago</b></label><select id="filterEstadoPagos" class="form-select">
                                <option value="">Todos</option>
                                <option value="pendiente">Pendientes</option>
                                <option value="fallido">Fallidos</option>
                                <option value="exitoso">Pagados</option>
                            </select></div>
                        <div class="col-md-2"><label for="" class="mb-1"><b>Cantidad de Registros</b></label><select id="limitPagos" class="form-select">
                                <option>25</option>
                                <option selected>50</option>
                                <option>100</option>
                            </select></div>
                    </div>
                </div>
                <div class="card p-3 mb-3">
                    <strong>Pagos recientes</strong>
                    <div class="table-responsive mt-3">
                        <table class="table table-hover align-middle" id="tablaPagos">
                            <thead>
                                <tr>
                                    <th class="bg-primary text-white">Operacion</th>
                                    <th class="bg-primary text-white">Fecha Registro</th>
                                    <th class="bg-primary text-white">Usuario</th>
                                    <th class="bg-primary text-white">Descripcion</th>
                                    <th class="bg-primary text-white">Metodo</th>
                                    <th class="bg-primary text-white">Monto</th>
                                    <th class="bg-primary text-white">Estado</th>
                                    <th class="bg-primary text-white">Fecha Pago</th>
                                    <th class="bg-primary text-white">Accion</th>

                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                    <nav>
                        <ul class="pagination pagination-sm mb-0" id="paginationPagos"></ul>
                    </nav>
                </div>
            </div>

        </div> <!-- tab-content -->


        <script>
            // --------- ESTADO SERVICIOS ---------
            window.window.statePag = {
                offset: 0,
                limit: 50,
                q: '',
                estado: '',
                total: 0
            };

            async function loadPagos() {
                const resp = await fetchJSON(`?action=list_pagos&limit=${window.statePag.limit}&offset=${window.statePag.offset}&q=${encodeURIComponent(window.statePag.q)}&estado=${window.statePag.estado}`);

                if (!resp.success) {
                    alert(resp.error);
                    return;
                }

                window.statePag.total = resp.data.total || 0;
                const tbody = $('#tablaPagos tbody');
                tbody.innerHTML = '';

                if (resp.data.items.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="9" class="text-center small-muted">No hay resultados</td></tr>';
                    return;
                }

                resp.data.items.forEach(pago => {
                    const tr = document.createElement('tr');
                    tr.innerHTML = `
            <td>${pago.stripe_charge_id ||'---'}</td>
                        <td>${escapeHtml(pago.created_at || '---')}</td>

            <td>${escapeHtml(pago.nombre_usuario || 'Usuario #' + pago.usuario_id)}</td>
            <td>${escapeHtml(pago.descripcion || '---')}</td>
            <td>${escapeHtml(pago.metodo_pago || '---')}</td>
            <td>${escapeHtml(pago.moneda.toUpperCase())} ${parseFloat(pago.monto || 0).toFixed(2)}</td>
            <td>
                ${
                    pago.estado === 'exitoso'
                        ? '<span class="badge bg-success">Pagado</span>'
                        : pago.estado === 'pendiente'
                            ? '<span class="badge bg-warning text-dark">Pendiente</span>'
                            : '<span class="badge bg-danger">Fallido</span>'
                }
            </td>
            <td class="small-muted">${pago.fecha_pago || '---'}</td>
                       <td class="small-muted"><button class="btn btn-danger btn-sm" onclick="eliminarPago(${pago.id})" title="Eliminar Pago">X</button></td>

        `;
                    tbody.appendChild(tr);
                });

                renderPagination('Pagos');
            }

            async function eliminarPago(id) {
                if (!confirm('¿Eliminar el pago?')) return;
                const fd = new FormData();
                fd.append('id', id);
                const resp = await fetchJSON('?action=eliminarpago', {
                    method: 'POST',
                    body: fd
                });
                if (!resp.success) {
                    alert(resp.error);
                    return;
                } else {
                    alert(resp.data);

                }
                loadPagos();
                loadClientes();
            }
            async function toggleEstado(id) {
                if (!confirm('¿Cambiar estado del servicio?')) return;
                const fd = new FormData();
                fd.append('id', id);
                const resp = await fetchJSON('?action=toggle_estado_pago', {
                    method: 'POST',
                    body: fd
                });
                if (!resp.success) {
                    alert(resp.error);
                    return;
                }
                loadPagos();
            }
        </script>