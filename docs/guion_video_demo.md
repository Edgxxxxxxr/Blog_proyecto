# Guion para el video de demostración

Duración sugerida: 3 a 5 minutos. Mantén la API y la app ejecutándose en el mismo equipo y prepara una cuenta de prueba antes de grabar.

## Secuencia

1. **Presentación (15 s):** muestra el proyecto y menciona Flutter, FastAPI y MySQL. Abre el repositorio público desde la URL del README.
2. **Conexión (20 s):** muestra brevemente el terminal de `uvicorn main:app --reload` y la app abierta. No muestres el archivo `.env`.
3. **Acceso y catálogo (35 s):** inicia sesión con una cuenta de prueba, enseña Inicio con las películas cargadas y busca una por título.
4. **Detalle y reseña (40 s):** abre una película, muestra su información y sus reseñas; publica una calificación con un comentario breve.
5. **Favoritos y perfil (35 s):** agrega la película a Favoritos, abre esa sección y muestra el perfil y las reseñas propias.
6. **Reporte y moderación (45 s):** desde una reseña de otra cuenta, envía un reporte; entra al panel administrativo y muestra el reporte recibido. Resuélvelo o descártalo.
7. **Verificación de datos (30 s):** enseña la documentación `/docs` o una consulta de solo lectura que confirme los registros creados, sin mostrar correos, hashes ni otros datos personales.
8. **Cierre (10 s):** muestra la estructura `backend_API`, `flutter_application_3` y `docs` del repositorio.

## Preparación

- Usa una cuenta de prueba y contenido no personal.
- Ten al menos dos cuentas para poder reportar una reseña de otra persona.
- Ten cargadas varias películas para mostrar búsqueda, detalle y favoritos.
- Ensaya la ruta antes de grabar; no escribas ni muestres contraseñas durante el video.
