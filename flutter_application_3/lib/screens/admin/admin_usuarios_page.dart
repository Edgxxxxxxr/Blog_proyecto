/// Archivo: admin_usuarios_page.dart.
/// Lista las cuentas registradas y conecta las acciones de administración.

// World of Movies: Listado y acciones sobre usuarios.
// part of permite compartir imports y el estado de la pantalla principal.
part of '../admin_dashboard_page.dart';

// Este mixin aporta funciones al mismo estado; no crea otra pantalla independiente.
mixin _AdminUsuarios on _AdminDashboardBase {
  // =====================================
  // LISTADO DE USUARIOS
  // =====================================

  // Construye el listado de usuarios con búsqueda y acciones.
  /// Construye el listado administrativo de cuentas y sus acciones.
  @override
  Widget pantallaUsuarios() {
    // Filtra por nombre y correo.
    final lista = usuarios.where((u) {
      // Une el nombre y correo para hacer la búsqueda.
      return '${u['nom_usr']} ${u['mail']}'.toLowerCase().contains(
        // Compara con la búsqueda en minúsculas.
        busqueda.toLowerCase(),
      );
    // Convierte los usuarios filtrados en una lista.
    }).toList();

    // Crea el componente Column de la interfaz.
    return Column(
      // Lista de widgets que componen esta sección.
      children: [
        // Inserta el buscador de usuarios.
        buscador('Buscar usuario...'),

        // Crea el componente Expanded de la interfaz.
        Expanded(
          // Contiene el widget hijo.
          child: lista.isEmpty
              // Valor que se utiliza cuando la condición es verdadera.
              ? const Center(child: Text('No hay usuarios'))
              // Valor alternativo cuando la condición es falsa.
              : ListView.builder(
                  // Número de registros que tendrá la lista.
                  itemCount: lista.length,

                  // Construye cada fila utilizando su índice.
                  itemBuilder: (context, index) {
                    // Obtiene el usuario correspondiente a esta posición.
                    final usuario = lista[index];

                    // Identifica al administrador según el rol 1.
                    final esAdmin = usuario['tip_usu'] == 1;

                    // Identifica la cuenta con la que se inició sesión.
                    final esMiCuenta =
                        // Compara los identificadores de las dos cuentas.
                        usuario['id_usr'] == administrador['id_usr'];

                    // Crea el componente Card de la interfaz.
                    return Card(
                      // Define el espacio exterior del elemento.
                      margin: const EdgeInsets.symmetric(
                        // Espacio horizontal.
                        horizontal: 15,
                        // Espacio vertical.
                        vertical: 6,
                      ),

                      // Contiene el widget hijo.
                      child: ListTile(
                        // Contenido situado al inicio de la fila.
                        leading: CircleAvatar(
                          // Contiene el widget hijo.
                          child: Icon(
                            // Elige un icono diferente para el administrador.
                            esAdmin ? Icons.admin_panel_settings : Icons.person,
                          ),
                        ),

                        // Define el título visible.
                        title: Text(usuario['nom_usr'] ?? ''),

                        // Contenido secundario debajo del título.
                        subtitle: Column(
                          // Alinea los hijos en el eje transversal.
                          crossAxisAlignment: CrossAxisAlignment.start,

                          // Lista de widgets que componen esta sección.
                          children: [
                            // Crea el componente Text de la interfaz.
                            Text(usuario['mail'] ?? ''),

                            // Crea el componente Text de la interfaz.
                            Text(
                              // Muestra el nombre correspondiente al rol.
                              esAdmin ? 'Administrador' : 'Usuario',
                              // Configura la apariencia del texto.
                              style: const TextStyle(
                                // Define el grosor del texto.
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        // Acciones o contenido situado al final de la fila.
                        trailing: Row(
                          // Controla cuánto espacio ocupa el widget en su eje principal.
                          mainAxisSize: MainAxisSize.min,

                          // Lista de widgets que componen esta sección.
                          children: [
                            // Crea el componente IconButton de la interfaz.
                            IconButton(
                              // Texto de ayuda de la acción.
                              tooltip: 'Editar',
                              // Icono que representa la acción.
                              icon: const Icon(Icons.edit),

                              // Abre el formulario con los datos de este usuario.
                              onPressed: () => formularioUsuario(usuario),
                            ),

                            // Crea el componente IconButton de la interfaz.
                            IconButton(
                              // Texto de ayuda de la acción.
                              tooltip: 'Eliminar',
                              // Icono que representa la acción.
                              icon: const Icon(
                                // Selecciona el icono visual indicado.
                                Icons.delete_outline,
                                // Establece el color del elemento.
                                color: Colors.red,
                              ),

                              // Impide eliminar la propia cuenta desde este botón.
                              onPressed: esMiCuenta
                                  // Valor que se utiliza cuando la condición es verdadera.
                                  ? null
                                  // Valor alternativo cuando la condición es falsa.
                                  : () async {
                                      // Comprueba esta condición antes de ejecutar el siguiente bloque.
                                      if (await confirmar(
                                        // Texto de confirmación para eliminar al usuario.
                                        '¿Eliminar este usuario?',
                                      )) {
                                        // Ejecuta la acción remota y actualiza la información del panel.
                                        await ejecutarOperacion(
                                          // Solicita eliminar el usuario por id_usr.
                                          () => servicio!.eliminarUsuario(
                                            // Identificador del usuario que se eliminará.
                                            usuario['id_usr'],
                                          ),
                                          // Mensaje de éxito de eliminación del usuario.
                                          'Usuario eliminado',
                                        );
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

}
