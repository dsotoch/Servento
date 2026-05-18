  <!-- TAB Categorias -->
  <div class="tab-pane fade" id="tabUser">
    <div class="card p-3 mb-3  shadow-sm filtros">
                <label for="" class="mb-2"><b>Panel de Filtros</b></label>  
          <div class="row g-2 align-items-center">
              <div class="col-md-6"><input id="qUsuario" class="form-control" placeholder="Buscar Usuario..."></div>
              <div class="col-md-2">                <label for="" class="mb-1"><b>Estado del Usuario</b></label>  
<select id="filterEstadoUsuario" class="form-select">
                      <option value="">Todos</option>
                      <option value="inactivo">Inactivos</option>
                      <option value="activo">Activos</option>
                  </select></div>

              <div class="col-md-2 text-end"><button class="btn btn-accent btn-sm" onclick="openUsuario();">✏️ Nuevo Usuario</button></div>

          </div>
      </div>
      <div class="card p-3 mb-3">
          <div class="d-flex justify-content-between align-items-center mb-2"><strong>Categorias</strong><span id="summaryCategorias" class="small-muted"></span></div>
          <div class="table-responsive">
              <table class="table table-hover align-middle" id="tablaUsuarios">
                  <thead>
                      <tr>
                          <th class="bg-primary text-white">ID</th>
                          <th class="bg-primary text-white">Nombres</th>
                          <th class="bg-primary text-white">Email</th>
                          <th class="bg-primary text-white">Estado</th>
                          <th class="bg-primary text-white">Fecha de Creación</th>
                          <th class="bg-primary text-white">Acciones</th>
                      </tr>
                  </thead>

                  <tbody></tbody>
              </table>
          </div>

      </div>
  </div>
  <!-- Modal Usuario -->
  <div class="modal fade" id="modalUsuario" tabindex="-1" aria-labelledby="modalUsuarioLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
          <div class="modal-content border-0 shadow-lg">
              <div class="modal-header bg-primary text-white">
                  <h5 class="modal-title" id="modalUsuarioLabel">Agregar Usuario</h5>
                  <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
              </div>
              <form id="formUsuario">
                  <div class="modal-body">

                      <!-- Email -->
                      <div class="mb-3">
                          <label class="form-label">Correo Electrónico</label>
                          <input type="email" class="form-control" name="email" id="emailUsuario" required>
                      </div>

                      <!-- Nombres -->
                      <div class="mb-3">
                          <label class="form-label">Nombres</label>
                          <input type="text" class="form-control" name="nombres" id="nombresUsuario" required>
                      </div>

                      <!-- Contraseña -->
                      <div class="mb-3">
                          <label class="form-label">Contraseña</label>
                          <input type="password" class="form-control" name="password" id="passwordUsuario">
                      </div>

                      <!-- Estado -->
                      <div class="mb-3">
                          <label class="form-label">Estado</label>
                          <select class="form-select" name="estado" id="estadoUsuario" required>
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
      function openUsuario() {
          const modal = new bootstrap.Modal(document.getElementById('modalUsuario'));
          const form = document.getElementById("formUsuario");
          form.reset();
          form.removeAttribute("data-id");
          modal.show();
      }

      document.addEventListener("DOMContentLoaded", () => {
          const form = document.getElementById("formUsuario");

          // Envío del formulario (Guardar o Editar)
          form.addEventListener("submit", async (e) => {
              e.preventDefault();
              const formData = new FormData(form);

              // Detectar si es edición o nuevo
              const url = form.dataset.id ?
                  "usuario_modificar.php" :
                  "usuarios_guardar.php";

              if (form.dataset.id) formData.append("id", form.dataset.id);

              try {
                  const res = await fetch(url, {
                      method: "POST",
                      body: formData
                  });

                  const data = await res.json();

                  if (data.status === "ok") {
                      alert("✅ " + data.mensaje);
                      form.reset();
                      form.removeAttribute("data-id");
                      const modalEl = document.getElementById("modalUsuario");
                      const modalInstance = bootstrap.Modal.getInstance(modalEl);
                      modalInstance.hide();
                      loadUsuarios();

                  } else {
                      alert("❌ " + data.mensaje);
                  }
              } catch (error) {
                  console.error("Error al guardar usuario:", error);
                  alert("⚠️ No se pudo conectar con el servidor.");
              }
          });
      });

      // Función para abrir modal con datos de usuario (editar)
      function editarUsuario(usuario) {
          try {
              if (typeof usuario === 'string') {
                  usuario = JSON.parse(decodeURIComponent(usuario));
              }

              document.getElementById('emailUsuario').value = usuario.email || '';
              document.getElementById('nombresUsuario').value = usuario.nombres || '';
              document.getElementById('estadoUsuario').value = usuario.estado.toLowerCase() || 'ACTIVO';
              document.getElementById('passwordUsuario').value = ''; // vacío por seguridad

              const form = document.getElementById('formUsuario');
              form.dataset.id = usuario.id;
              document.getElementById('modalUsuarioLabel').textContent = 'Editar Usuario';

              const modal = new bootstrap.Modal(document.getElementById('modalUsuario'));
              modal.show();
          } catch (err) {
              console.error('Error al abrir edición:', err);
              alert('Error al abrir el usuario.');
          }
      }
  </script>