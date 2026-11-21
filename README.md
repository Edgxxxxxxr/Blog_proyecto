# World of Movies

World of Movies es una aplicación Flutter conectada a una API FastAPI y a una base de datos MySQL. La app permite crear e iniciar sesión, consultar películas, buscar por título, ver detalles, guardar favoritos, publicar reseñas, reportarlas y administrar el perfil. El panel administrativo conserva las funciones de gestión y moderación.

## Repositorio

El proyecto se entrega en este repositorio público:

https://github.com/Edgxxxxxxr/Blog_proyecto

Clona el proyecto con:

```powershell
git clone https://github.com/Edgxxxxxxr/Blog_proyecto.git
cd Blog_proyecto
```

## Estructura

```text
Proyecto_App_movil/
├── backend_API/                 # API FastAPI, modelos, servicios y migraciones
├── flutter_application_3/       # Aplicación Flutter para móvil y navegador
├── docs/                        # Reporte técnico
└── README.md                    # Estas instrucciones
```

## Requisitos

- Python 3.10 o posterior y MySQL 8 o posterior.
- Flutter y Dart compatibles con el SDK declarado en `flutter_application_3/pubspec.yaml`.
- Git para clonar el repositorio.

## Preparar la base MySQL

El repositorio incluye un esquema vacío y una migración de funciones de usuario. No incluye el respaldo local con cuentas y datos personales.

1. Abre una terminal e inicia el cliente de MySQL con `mysql -u root -p`.
2. En el indicador `mysql>`, ejecuta ambos scripts en este orden, sustituyendo la ruta por la ubicación local del repositorio:

   ```sql
   SOURCE C:/ruta/Proyecto_App_movil/backend_API/migrations/000_base_schema.sql;
   SOURCE C:/ruta/Proyecto_App_movil/backend_API/migrations/001_user_features.sql;
   ```

El primer script crea las tablas `usuario`, `blog` y `comentarios`; el segundo agrega el catálogo de películas, favoritos y reportes. La base inicia vacía: crea una cuenta desde la app para usarla.

## Iniciar la API

Desde la carpeta `backend_API`, crea la configuración local y levanta FastAPI:

```powershell
Copy-Item .env.example .env
py -m venv venv
venv\Scripts\activate
py -m pip install -r requirements.txt
uvicorn main:app --reload
```

Edita `backend_API/.env` con los datos de tu MySQL y reemplaza `API_SECRET_KEY` por una clave aleatoria de al menos 32 caracteres. La API queda disponible en `http://127.0.0.1:8000`; su documentación interactiva está en `http://127.0.0.1:8000/docs`.

## Iniciar Flutter

En otra terminal, desde `flutter_application_3`:

```powershell
flutter pub get
flutter run -d chrome
```

Para esta demostración local, deja la API y Flutter en el mismo equipo. La dirección de API configurada por la app es `http://127.0.0.1:8000`.

## Acceso administrativo

El registro público crea cuentas con rol de usuario. Para habilitar el panel, cambia manualmente el rol de una cuenta de confianza después de registrarla:

```sql
USE blog_db;
UPDATE usuario SET tip_usu = 1 WHERE mail = 'correo-del-admin@example.com';
```

No uses la contraseña ni el correo real de una cuenta en capturas o videos públicos.

## Seguridad y datos

- Las contraseñas se almacenan como hashes bcrypt; no se guardan en texto legible.
- La API firma tokens Bearer con HMAC-SHA256 y los hace expirar después de ocho horas.
- El rol se valida en los endpoints administrativos.
- Cada desarrollador debe conservar su `.env` local. El `.gitignore` excluye ese archivo y los entornos generados.
- `backend_API/migrations/000_base_schema.sql` crea únicamente las tablas, sin filas de cuentas o contenido.

