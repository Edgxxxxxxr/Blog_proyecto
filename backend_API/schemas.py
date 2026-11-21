"""Puente de compatibilidad para conservar imports antiguos de los esquemas Pydantic.
Este módulo participa en la configuración y compatibilidad del servicio FastAPI."""

from domain.schemas import *  # noqa: F401,F403
