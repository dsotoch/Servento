<!-- TAB CUPONES -->
<div class="tab-pane fade " id="tabCupones">
<div class="card p-3 mb-3  shadow-sm filtros">
                <label for="" class="mb-2"><b>Panel de Filtros</b></label>           <div class="row g-2 align-items-center">
            <div class="col-md-6">
                <input id="qCupones" class="form-control" placeholder="Buscar cupón... por código o descripción">
            </div>
            <div class="col-md-2">
                <label for="" class="mb-1"><b>Estado del Cupón</b></label>
                <select id="filterEstadoCupones" class="form-select">
                    <option value="">Todos</option>
                    <option value="activo">Activos</option>
                    <option value="inactivo">Inactivos</option>
                </select>
            </div>
            <div class="col-md-2">
                                <label for="" class="mb-1"><b>Cantidad de Registros</b></label>

                <select id="limitCupones" class="form-select">
                    <option>25</option>
                    <option selected>50</option>
                    <option>100</option>
                </select>
            </div>
        </div>
    </div>

    <div class="card p-3 mb-3">
        <div class="d-flex justify-content-between align-items-center mb-2">
            <strong>Cupones registrados</strong>
            <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#modalCupon">
                + Nuevo cupón
            </button>
        </div>

        <div class="table-responsive mt-3">
            <table class="table table-hover align-middle" id="tablaCupones">
                <thead>
                    <tr>
                        <th class="bg-primary text-white">Código</th>
                        <th class="bg-primary text-white">Descripción</th>
                        <th class="bg-primary text-white">Descuento</th>
                        <th class="bg-primary text-white">Fecha de Vigencia</th>
                        <th class="bg-primary text-white">Estado</th>
                        <th class="bg-primary text-white">Acción</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
        <nav>
            <ul class="pagination pagination-sm mb-0" id="paginationCupones"></ul>
        </nav>
    </div>
</div>
<!-- MODAL NUEVO CUPÓN -->
<div class="modal fade" id="modalCupon" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title">Nuevo Cupón</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="formCupon">
                    <div class="mb-3">
                        <label class="form-label">Código</label>
                        <input type="text" id="codigoCupon" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Descripción</label>
                        <textarea id="descripcionCupon" class="form-control" rows="2"></textarea>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Descuento</label>
                            <input type="number" id="descuentoCupon" class="form-control" min="1" value="100" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Fecha de Expiración</label>
                            <input type="date" id="vigenciaCupon" class="form-control" required>
                        </div>
                    </div>

                </form>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button class="btn btn-primary" id="btnGuardarCupon">Guardar</button>
            </div>
        </div>
    </div>
</div>

<script>
    // --------- ESTADO CUPONES ---------
    window.stateCupon = {
        offset: 0,
        limit: 50,
        q: '',
        estado: '',
        total: 0
    };

    // Cargar cupones
    async function loadCupones() {
        const resp = await fetchJSON(`?action=list_cupones&limit=${window.stateCupon.limit}&offset=${window.stateCupon.offset}&q=${encodeURIComponent(window.stateCupon.q)}&estado=${window.stateCupon.estado}`);

        if (!resp.success) {
            alert(resp.error);
            return;
        }

        window.stateCupon.total = resp.data.total || 0;
        const tbody = $('#tablaCupones tbody');
        tbody.innerHTML = '';

        if (resp.data.items.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" class="text-center small-muted">No hay resultados</td></tr>';
            return;
        }

        resp.data.items.forEach(cupon => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
          <td><strong>${escapeHtml(cupon.codigo)}</strong></td>
          <td>${escapeHtml(cupon.descripcion || '---')}</td>
          <td>${parseFloat(cupon.monto_descuento || 0).toFixed(2)}</td>
<td>
  ${formatearFecha(cupon.vigencia_inicio)} - 
  ${formatearFecha(cupon.vigencia_fin)}
</td>
          <td>
            ${
              cupon.activo == '1'
                ? '<span class="badge bg-success">Activo</span>'
                  : '<span class="badge bg-danger">Inactivo</span>'
            }
          </td>
          <td>
<button class="btn btn-sm btn-primary me-1" id="btncambiocupon" onclick="toggleEstadoCupon(${cupon.id})" title="Cambiar estado">
        ${
              cupon.activo == '1'
                ? 'Desactivar'
                  : 'Activar'
            }

</button>
            <button class="btn btn-sm btn-danger" id="btneliminarcupon" onclick="eliminarCupon(${cupon.id})" title="Eliminar">X</button>
          </td>
        `;
            tbody.appendChild(tr);
        });

        renderPagination('Cupones');
    }

    function formatearFecha(fecha) {
        if (!fecha) return '---';
        const d = new Date(fecha);
        if (isNaN(d)) return '---';
        return d.toLocaleDateString('es-PE', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric'
        });
    }

    // Guardar nuevo cupón
    document.getElementById('btnGuardarCupon').addEventListener('click', async () => {
        const codigo = $('#codigoCupon').value.trim();
        const descripcion = $('#descripcionCupon').value.trim();
        const descuento = $('#descuentoCupon').value.trim();
        const vigencia = $('#vigenciaCupon').value.trim();

        if (!codigo || !descuento || !vigencia) {
            alert('Por favor completa los campos requeridos.');
            return;
        }

        const fd = new FormData();
        fd.append('codigo', codigo);
        fd.append('descripcion', descripcion);
        fd.append('porcentaje_descuento', descuento);
        fd.append('vigencia', vigencia);
        const textoOriginal = document.getElementById('btnGuardarCupon').innerHTML;
        document.getElementById('btnGuardarCupon').innerHTML = "Procesando...";
        document.getElementById('btnGuardarCupon').disabled = true;

        const resp = await fetchJSON('?action=crearcupon', {
            method: 'POST',
            body: fd
        });
        document.getElementById('btnGuardarCupon').innerHTML = textoOriginal;
        document.getElementById('btnGuardarCupon').disabled = false;
        alert(resp.data || resp.error);
        const modal = bootstrap.Modal.getInstance(document.getElementById('modalCupon'));
        modal.hide();
        loadCupones();
        document.getElementById('formCupon').reset();
    });

    // Eliminar cupón
    async function eliminarCupon(id) {
        if (!confirm('¿Eliminar el cupón?')) return;
        const fd = new FormData();
        const btn = document.getElementById("btneliminarcupon");
        const texto = btn.innerHTML;
        btn.innerHTML = "Procesando...";
        btn.disabled = true;
        fd.append('id', id);
        const resp = await fetchJSON('?action=eliminarcupon', {
            method: 'POST',
            body: fd
        });
        btn.innerHTML = texto;
        btn.disabled = false;
        alert(resp.data || resp.error);
        loadCupones();
    }

    // Cambiar estado
    async function toggleEstadoCupon(id) {
        if (!confirm('¿Cambiar estado del cupón?')) return;
        const fd = new FormData();
        const btn = document.getElementById("btncambiocupon");
        const texto = btn.innerHTML;
        btn.innerHTML = "Procesando...";
        btn.disabled = true;
        fd.append('id', id);
        const resp = await fetchJSON('?action=toggle_estado_cupon', {
            method: 'POST',
            body: fd
        });
        btn.innerHTML = texto;
        btn.disabled = false;
        alert(resp.data || resp.error);
        loadCupones();
    }
</script>