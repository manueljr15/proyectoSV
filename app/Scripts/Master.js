function asignarAlumnos(id_docente) {
    $.ajax({
        url: '/Tutores_Alumnos/Create?id=' + id_docente,
        async: true,
        success: function (data) {
            document.getElementById("bodyModal").innerHTML = data;
        }
    });
}

