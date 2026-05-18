<!-- TAB CODIGOS -->
<div class="tab-pane fade " id="tabCodigo">
    <div class="card p-3 mb-3  shadow-sm filtros">
                <label for="" class="mb-2"><b>Panel de Filtros</b></label>
        <div class="row g-2 align-items-center">
            <div class="col-md-6">
                <input id="qCodigos" class="form-control" placeholder="Buscar código... por código o descripción">
            </div>
            <div class="col-md-2"><label for="" class="mb-1"><b>Estado del Codigo</b></label>
                <select id="filterEstadoCodigos" class="form-select">
                    <option value="">Todos</option>
                    <option value="activo">Activos</option>
                    <option value="inactivo">Inactivos</option>
                </select>
            </div>
            <div class="col-md-2"><label for="" class="mb-1"><b>Cantidad de Registros</b></label>
                <select id="limitCodigos" class="form-select">
                    <option>25</option>
                    <option selected>50</option>
                    <option>100</option>
                </select>
            </div>
        </div>
    </div>

    <div class="card p-3 mb-3">
        <div class="d-flex justify-content-between align-items-center mb-2">
            <strong>Códigos registrados</strong>
            <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#modalCodigo">
                + Nuevo código
            </button>
        </div>

        <div class="table-responsive mt-3">
            <table class="table table-hover align-middle" id="tablaCodigos">
                <thead>
                    <tr>
                        <th class="bg-primary text-white">Código</th>
                        <th class="bg-primary text-white">Descripción</th>
                        <th class="bg-primary text-white">Días Gratis</th>
                        <th class="bg-primary text-white">Vigencia</th>
                        <th class="bg-primary text-white">Estado</th>
                        <th class="bg-primary text-white">Acción</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
        <nav>
            <ul class="pagination pagination-sm mb-0" id="paginationCodigos"></ul>
        </nav>
    </div>
</div>

<!-- MODAL NUEVO CÓDIGO -->
<div class="modal fade" id="modalCodigo" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title">Nuevo Código</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="formCodigo">
                    <div class="mb-3">
                        <label class="form-label">Código</label>
                        <input type="text" id="codigo" class="form-control" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Descripción</label>
                        <textarea id="descripcion" class="form-control" rows="2"></textarea>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Días gratis</label>
                            <input type="number" id="dias" class="form-control" min="1" value="7" required>
                        </div>

                        <div class="col-md-6 mb-3">
                            <label class="form-label">Fecha de Inicio</label>
                            <input type="date" id="fecha_inicio" class="form-control" required>
                        </div>
                    </div>

                </form>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button class="btn btn-primary" id="btnGuardarCodigo">Guardar</button>
            </div>
        </div>
    </div>
</div>

<script>
    // --------- ESTADO CODIGOS ---------
    window.stateCodigos = {
        offset: 0,
        limit: 50,
        q: '',
        estado: '',
        total: 0
    };

    async function loadCodigos() {
        const resp = await fetchJSON(`?action=list_codigos_publicacion&limit=${window.stateCodigos.limit}&offset=${window.stateCodigos.offset}&q=${encodeURIComponent(window.stateCodigos.q)}&estado=${window.stateCodigos.estado}`);

        if (!resp.success) {
            alert(resp.error);
            return;
        }

        window.stateCodigos.total = resp.data.total || 0;

        const tbody = $('#tablaCodigos tbody');
        tbody.innerHTML = '';

        if (resp.data.items.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" class="text-center small-muted">No hay resultados</td></tr>';
            return;
        }

        resp.data.items.forEach(cd => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td><strong>${escapeHtml(cd.codigo)}</strong></td>
                <td>${escapeHtml(cd.descripcion || '---')}</td>
                <td>${cd.dias_gratis} días</td>
                <td>${formatearFecha(cd.fecha_inicio)} - ${formatearFecha(cd.fecha_fin)}</td>
                <td>
                    ${cd.activo == '1'
                        ? '<span class="badge bg-success">Activo</span>'
                        : '<span class="badge bg-danger">Inactivo</span>'}
                </td>
                <td>
                    <button class="btn btn-sm btn-primary me-1" onclick="toggleEstadoCodigo(${cd.id})">
                        ${cd.activo == '1' ? 'Desactivar' : 'Activar'}
                    </button>
                    <button class="btn btn-sm btn-danger" onclick="eliminarCodigo(${cd.id})">X</button>
                </td>
            `;
            tbody.appendChild(tr);
        });

        renderPagination('Codigos');
    }

    function formatearFecha(f) {
        if (!f) return '---';
        const dt = new Date(f);
        if (isNaN(dt)) return '---';
        return dt.toLocaleDateString('es-PE');
    }

    document.getElementById('btnGuardarCodigo').addEventListener('click', async () => {
        const codigo = $('#codigo').value.trim();
        const descripcion = $('#descripcion').value.trim();
        const dias = $('#dias').value.trim();
        const fecha_inicio = $('#fecha_inicio').value.trim();

        if (!codigo || !dias || !fecha_inicio) {
            alert("Completa los campos requeridos.");
            return;
        }

        const fd = new FormData();
        fd.append('codigo', codigo);
        fd.append('descripcion', descripcion);
        fd.append('dias', dias);
        fd.append('fecha_inicio', fecha_inicio);

        const btn = document.getElementById('btnGuardarCodigo');
        const textoOriginal = btn.innerHTML;
        btn.innerHTML = "Procesando...";
        btn.disabled = true;

        const resp = await fetchJSON('?action=save_codigo_publicacion', {
            method: 'POST',
            body: fd
        });

        btn.innerHTML = textoOriginal;
        btn.disabled = false;

        alert(resp.data || resp.error);

        bootstrap.Modal.getInstance(document.getElementById('modalCodigo')).hide();

        loadCodigos();

        document.getElementById('formCodigo').reset();
    });


    async function eliminarCodigo(id) {
        if (!confirm('¿Eliminar el código?')) return;

        const fd = new FormData();
        fd.append('id', id);

        const resp = await fetchJSON('?action=eliminar_codigo', {
            method: 'POST',
            body: fd
        });

        alert(resp.data || resp.error);
        loadCodigos();
    }

    async function toggleEstadoCodigo(id) {
        if (!confirm('¿Cambiar estado?')) return;

        const fd = new FormData();
        fd.append('id', id);

        const resp = await fetchJSON('?action=toggle_estado_codigo', {
            method: 'POST',
            body: fd
        });

        alert(resp.data || resp.error);
        loadCodigos();
    }
</script>