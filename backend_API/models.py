"""Puente de compatibilidad para conservar imports antiguos de los modelos ORM.
Este módulo participa en la configuración y compatibilidad del servicio FastAPI."""

from domain.models import *  # noqa: F401,F403
