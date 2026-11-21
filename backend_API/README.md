# API FastAPI

Este backend atiende autenticación, cuentas, publicaciones, catálogo de películas, favoritos, reseñas y moderación. La API está organizada por rutas, dominio, repositorios y servicios; `main.py` conserva el comando `uvicorn main:app --reload`.

## Base de datos

No publiques el respaldo `blog_db.sql`: contiene cuentas y hashes de contraseñas. Para crear una base nueva y vacía, ejecuta desde el cliente de MySQL:

```sql
SOURCE C:/ruta/Proyecto_App_movil/backend_API/migrations/000_base_schema.sql;
SOURCE C:/ruta/Proyecto_App_movil/backend_API/migrations/001_user_features.sql;
```

Si se parte de una base ya creada con el esquema legado, aplica únicamente la segunda migración.

## Configuración y ejecución

Copia `.env.example` como `.env`, configura las variables para tu equipo y luego instala y ejecuta:

```powershell
py -m venv venv
venv\Scripts\activate
py -m pip install -r requirements.txt
uvicorn main:app --reload
```

El ORM refleja el esquema SQL, pero no crea ni cambia tablas automáticamente. La API no inicia sus rutas si falta `DB_PASSWORD` o si `API_SECRET_KEY` tiene menos de 32 caracteres.
