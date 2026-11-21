"""Puente de compatibilidad para conservar imports antiguos del router administrativo.
Este módulo participa en la configuración y compatibilidad del servicio FastAPI."""

from api.routes.admin_api import *  # noqa: F401,F403
