// World of Movies: Perfil y opciones de configuración.
// part of permite compartir imports y el estado de la pantalla principal.
part of '../admin_dashboard_page.dart';

// Este mixin aporta funciones al mismo estado; no crea otra pantalla independiente.
mixin _AdminPerfil on _AdminDashboardBase {
  // =====================================
  // PERFIL Y CONFIGURACIÓN
  // =====================================

  // Construye la pantalla de perfil y configuración.
  @override
  Widget configuracion() {
    // Usa inicialmente los datos recibidos durante el login.
    Map<String, dynamic> perfil = administrador;

    // Busca los datos actuales del administrador en la lista de usuarios.
    for (final usuario in usuarios) {
      // Comprueba si el identificador corresponde al administrador.
      if (usuario['id_usr'] == administrador['id_usr']) {
        // Utiliza los datos actualizados del usuario encontrado.
        perfil = usuario;
        // Termina el recorrido cuando encuentra la cuenta.
        break;
      }
    }

    // Crea el componente ListView de la interfaz.
    return ListView(
      // Define el espacio interior del elemento.
      padding: const EdgeInsets.all(20),

      // Lista de widgets que componen esta sección.
      children: [
        // Añade un espacio fijo entre los componentes.
        const SizedBox(height: 20),

        // Crea el componente CircleAvatar de la interfaz.
        const CircleAvatar(
          // Radio del avatar circular.
          radius: 50,
          // Establece el color de fondo.
          backgroundColor: Color(0xFF08245C),

          // Contiene el widget hijo.
          child: Icon(Icons.person, size: 65, color: Colors.white),
        ),

        // Añade un espacio fijo entre los componentes.
        const SizedBox(height: 15),

        // Crea el componente Text de la interfaz.
        Text(
          // Muestra el nombre del perfil o el texto alternativo.
          perfil['nom_usr'] ?? 'Administrador',
          // Alinea el texto dentro de su espacio.
          textAlign: TextAlign.center,

          // Configura la apariencia del texto.
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        // Crea el componente Text de la interfaz.
        Text(perfil['mail'] ?? '', textAlign: TextAlign.center),

        // Añade un espacio fijo entre los componentes.
        const SizedBox(height: 10),

        // Crea el componente Text de la interfaz.
        const Text('Administrador', textAlign: TextAlign.center),

        // Añade un espacio fijo entre los componentes.
        const SizedBox(height: 30),

        // Crea el componente ListTile de la interfaz.
        ListTile(
          // Contenido situado al inicio de la fila.
          leading: const Icon(Icons.edit_outlined),
          // Define el título visible.
          title: const Text('Editar perfil'),
          // Acciones o contenido situado al final de la fila.
          trailing: const Icon(Icons.chevron_right),

          // Abre el formulario para editar el perfil.
          onTap: () => formularioUsuario(perfil),
        ),

        // Añade una línea de separación visual.
        const Divider(),

        // Crea el componente ListTile de la interfaz.
        ListTile(
          // Contenido situado al inicio de la fila.
          leading: const Icon(Icons.refresh),
          // Define el título visible.
          title: const Text('Actualizar información'),
          // Acciones o contenido situado al final de la fila.
          trailing: const Icon(Icons.chevron_right),

          // Vuelve a consultar la información del servidor.
          onTap: cargarDatos,
        ),

        // Añade una línea de separación visual.
        const Divider(),

        // Crea el componente ListTile de la interfaz.
        ListTile(
          // Contenido situado al inicio de la fila.
          leading: const Icon(Icons.logout, color: Colors.red),

          // Define el título visible.
          title: const Text(
            // Etiqueta de la acción de salida.
            'Cerrar sesión',
            // Configura la apariencia del texto.
            style: TextStyle(color: Colors.red),
          ),

          // Invoca la confirmación y salida de la sesión.
          onTap: cerrarSesion,
        ),
      ],
    );
  }

}
