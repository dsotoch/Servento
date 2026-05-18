  <!-- TAB Categorias -->
  <div class="tab-pane fade" id="tabCate">
    <div class="card p-3 mb-3  shadow-sm filtros">
                <label for="" class="mb-2"><b>Panel de Filtros</b></label>          <div class="row g-2 align-items-center">
              <div class="col-md-6"><input id="qCategorias" class="form-control" placeholder="Buscar categoria..."></div>
              <div class="col-md-2"><label for="" class="mb-1"><b>Estado de la Categoría</b></label><select id="filterEstadoCategorias" class="form-select">
                      <option value="">Todos</option>
                      <option value="inactivo">Inactivos</option>
                      <option value="activo">Activos</option>
                  </select></div>
              <div class="col-md-2"><label for="" class="mb-1"><b>Cantidad de Registros</b></label><select id="limitCategorias" class="form-select">
                      <option selected>25</option>
                      <option>50</option>
                      <option>100</option>
                  </select></div>
              <div class="col-md-2 text-end"><button class="btn btn-accent btn-sm" onclick="openCate();">✏️ Nueva Categoria</button></div>

          </div>
      </div>
      <div class="card p-3 mb-3">
          <div class="d-flex justify-content-between align-items-center mb-2"><strong>Categorias</strong><span id="summaryCategorias" class="small-muted"></span></div>
          <div class="table-responsive">
              <table class="table table-bordered table-hover align-middle" id="tablaCategorias">
                  <thead>
                      <tr>
                          <th class="bg-primary text-white">ID</th>
                          <th class="bg-primary text-white">Nombre de Categoría</th>
                          <th class="bg-primary text-white">Descripción</th>
                          <th class="bg-primary text-white">Estado</th>
                          <th class="bg-primary text-white">Fecha de Creación</th>
                          <th class="bg-primary text-white">Acciones</th>
                      </tr>
                  </thead>

                  <tbody></tbody>
              </table>
          </div>
          <nav>
              <ul class="pagination pagination-sm mb-0" id="paginationCategorias"></ul>
          </nav>
      </div>
  </div>
  <!-- Modal Categoría -->
  <div class="modal fade" id="modalCategoria" tabindex="-1" aria-labelledby="modalCategoriaLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
          <div class="modal-content border-0 shadow-lg">
              <div class="modal-header bg-primary text-white">
                  <h5 class="modal-title" id="modalCategoriaLabel">Agregar Categoría</h5>
                  <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
              </div>
              <form id="formCategoria">
                  <div class="modal-body">

                      <!-- Tipo de registro -->
                      <div class="mb-3">
                          <label class="form-label">Tipo de registro</label>
                          <select class="form-select" name="tipo" id="tipoCategoria" required>
                              <option value="categoria" selected>Categoría</option>
                              <option value="subcategoria">Subcategoría</option>
                          </select>
                      </div>

                      <!-- Categoría Padre -->
                      <div class="mb-3" id="contenedorCategoriaPadre" style="display:none;">
                          <label class="form-label">Categoría Padre</label>
                          <select class="form-select" name="categoria_padre_id" id="categoriaPadre">
                              <option value="">Seleccione una categoría</option>
                              <!-- Se llenará dinámicamente con JS -->
                          </select>
                      </div>

                      <!-- Nombre -->
                      <div class="mb-3">
                          <label class="form-label">Nombre</label>
                          <input type="text" class="form-control" name="nombre" id="nombreCategoria" required>
                      </div>

                      <!-- Descripción -->
                      <div class="mb-3">
                          <label class="form-label">Descripción</label>
                          <textarea class="form-control" name="descripcion" id="descripcionCategoria" rows="2"></textarea>
                      </div>

                      <!-- Estado -->
                      <div class="mb-3">
                          <label class="form-label">Estado</label>
                          <select class="form-select" name="estado" id="estadoCategoria">
                              <option value="activo" selected>Activo</option>
                              <option value="inactivo">Inactivo</option>
                          </select>
                      </div>

                  </div>
                  <div class="modal-footer">
                      <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                      <button type="submit" class="btn btn-accent">Guardar</button>
                  </div>
              </form>
          </div>
      </div>
  </div>
  <script>
      function openCate() {
          const modal = new bootstrap.Modal(document.getElementById('modalCategoria'));
          modal.show();
      }

      document.addEventListener("DOMContentLoaded", () => {
          const tipoSelect = document.getElementById("tipoCategoria");
          const contenedorPadre = document.getElementById("contenedorCategoriaPadre");
          const categoriaPadre = document.getElementById("categoriaPadre");

          // Mostrar/ocultar select de categoría padre
          tipoSelect.addEventListener("change", () => {
              contenedorPadre.style.display = tipoSelect.value === "subcategoria" ? "block" : "none";
          });

          // Cargar categorías activas en el select (AJAX)
          async function cargarCategoriasPadre() {
              try {
                  const res = await fetch("categorias_listar.php");
                  const data = await res.json();

                  const categoriaPadre = document.getElementById("categoriaPadre");

                  categoriaPadre.innerHTML = '<option value="">Seleccione una categoría</option>';

                  if (data.status === "ok" && Array.isArray(data.categorias)) {
                      data.categorias.forEach(cat => {
                          categoriaPadre.innerHTML += `<option value="${cat.id}">${cat.nombre}</option>`;
                      });
                  } else {
                      categoriaPadre.innerHTML += '<option value="">No hay categorías disponibles</option>';
                  }
              } catch (error) {
                  console.error("Error cargando categorías:", error);
              }
          }



          // Llenar categorías cuando se abre el modal
          const modal = document.getElementById('modalCategoria');
          modal.addEventListener('show.bs.modal', cargarCategoriasPadre);

          // Envío del formulario
          document.getElementById("formCategoria").addEventListener("submit", async (e) => {
              e.preventDefault();
              const form = e.target;

              const formData = new FormData(e.target);
              if (form.dataset.id) {
                  formData.append("id", form.dataset.id);
                  var url = "categorias_modificar.php";
              } else {
                  var url = "categorias_guardar.php";
              }

              try {
                  const res = await fetch(url, {
                      method: "POST",
                      body: formData
                  });

                  const data = await res.json();

                  if (data.status === "ok") {
                      alert(data.mensaje);
                      form.reset();
                      form.removeAttribute("data-id");
                      // Cerrar modal
                      const modalEl = document.getElementById("modalCategoria");
                      const modalInstance = bootstrap.Modal.getInstance(modalEl);
                      modalInstance.hide();
                      loadCate();


                  } else {
                      alert("❌ " + data.mensaje);
                  }

              } catch (error) {
                  console.error("Error al guardar categoría:", error);
                  alert("⚠️ Error: no se pudo conectar con el servidor.");
              }
          });

      });
  </script>