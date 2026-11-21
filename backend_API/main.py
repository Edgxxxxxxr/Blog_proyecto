"""Punto de entrada de FastAPI: incorpora routers, middleware CORS y recursos estáticos.
Este módulo participa en la configuración y compatibilidad del servicio FastAPI."""

import os
from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from api.routes.admin_api import router as admin_router
from api.routes.content_api import UPLOAD_DIR, router as content_router
from api.routes.user_api import router as user_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Punto central para recursos que se abran al iniciar la aplicación."""
    yield


app = FastAPI(
    title="API de aplicación móvil",
    lifespan=lifespan,
)

# Las rutas se agrupan por área para mantener el punto de entrada pequeño.
app.include_router(admin_router)
app.include_router(user_router)
app.include_router(content_router)

# Archivos subidos por la API y, si existe, imágenes compartidas con el blog web.
app.mount("/uploads", StaticFiles(directory=str(UPLOAD_DIR)), name="uploads")
web_images_dir = os.getenv("WEB_IMAGES_DIR")
if web_images_dir and Path(web_images_dir).is_dir():
    app.mount(
        "/imagenes",
        StaticFiles(directory=web_images_dir),
        name="imagenes_web",
    )

# Permite Flutter Web desde puertos locales durante desarrollo.
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
