"""Puente de compatibilidad para importar la conexión SQLAlchemy desde su ubicación anterior.
Este módulo participa en la configuración y compatibilidad del servicio FastAPI."""

from db.session import *  # noqa: F401,F403
