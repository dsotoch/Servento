let idUsuarioActual = null;
function enviarMensajeTodos() {
        idUsuarioActual = "todos";

    document.getElementById("imagenInput").value = "";
    document.getElementById("previewImg").style.display = "none";
    document.getElementById("vigenciaInput").value = "";
    const modalEl = document.getElementById("modalMensaje");
    const modal = new bootstrap.Modal(modalEl);
    modal.show();
}
function enviarMensaje(id) {
    idUsuarioActual = id;
    document.getElementById("imagenInput").value = "";
    document.getElementById("previewImg").style.display = "none";
    document.getElementById("vigenciaInput").value = "";
    const modalEl = document.getElementById("modalMensaje");
    const modal = new bootstrap.Modal(modalEl);
    modal.show();
}


// Previsualizar imagen
document.getElementById("imagenInput").addEventListener("change", (e) => {
    const file = e.target.files[0];
    const preview = document.getElementById("previewImg");
    if (file) {
        preview.src = URL.createObjectURL(file);
        preview.style.display = "block";
    } else {
        preview.style.display = "none";
    }
});

// Enviar datos al servidor
document.getElementById("enviarBtn").addEventListener("click", async () => {
    const imagen = document.getElementById("imagenInput").files[0];
    const vigencia = document.getElementById("vigenciaInput").value;

    if (!imagen) {
        alert("Por favor ingresa una Imagen.");
        return;
    }
    if (!vigencia) {
        alert("Selecciona una fecha de vigencia.");
        return;
    }

    const fd = new FormData();
    fd.append('id', idUsuarioActual);
    fd.append('servicio', 'Mensaje interno');
    fd.append('vigencia', vigencia);
    if (imagen) fd.append('imagen', imagen);

    try {
        const resp = await fetch('?action=send_sms', { method: 'POST', body: fd });
        const data = await resp.json();

        if (!data.success) {
            alert('❌ ' + (data.error || 'Error al enviar el mensaje.'));
        } else {
            alert('✅ ' + (data.data || 'Mensaje enviado correctamente.'));
            const modal = bootstrap.Modal.getInstance(document.getElementById('modalMensaje'));
            modal.hide();
        }
    } catch (e) {
        alert('Error de conexión con el servidor.');
    }
});