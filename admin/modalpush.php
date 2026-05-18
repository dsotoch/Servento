<div class="modal fade" id="modalMensaje" tabindex="-1" aria-labelledby="modalMensajeLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      
      <div class="modal-header bg-primary text-white">
        <h5 class="modal-title" id="modalMensajeLabel">Enviar mensaje</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>

      <div class="modal-body">
       

        <div class="mb-3">
          <label for="imagenInput" class="form-label">Imagen:</label>
          <input type="file" class="form-control" id="imagenInput" accept="image/*" required>
          <img id="previewImg" class="img-fluid mt-2 rounded shadow-sm d-none" alt="Vista previa">
        </div>

        <div class="mb-3">
          <label for="vigenciaInput" class="form-label">Vigencia:</label>
          <input type="date" class="form-control" id="vigenciaInput" required>
        </div>
      </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
        <button type="button" class="btn btn-primary" id="enviarBtn">Enviar</button>
      </div>
    </div>
  </div>
</div>
