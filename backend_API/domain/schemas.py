"""Define los esquemas Pydantic usados para validar solicitudes y respuestas HTTP.
Esta capa declara los contratos de entrada y salida que consume la API."""


from datetime import datetime

from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


# USUARIOS

class UsuarioCrear(BaseModel):
    """Valida los datos necesarios para registrar una cuenta de usuario.

    El rol enviado por el cliente se conserva por compatibilidad, pero el backend asigna el rol seguro.
    """
    nom_usr: str = Field(min_length=2, max_length=100)
    mail: str = Field(min_length=5, max_length=150)
    password: str = Field(min_length=8, max_length=72)
    dir_usr: str | None = None

    # Se conserva para compatibilidad con Flutter.
    # El servidor no confiará en este campo.
    tip_usu: int = 2


class UsuarioRespuesta(BaseModel):
    """Define los campos públicos que devuelve la API para una cuenta."""
    id_usr: int
    nom_usr: str
    mail: str
    dir_usr: str | None
    tip_usu: int

    model_config = ConfigDict(from_attributes=True)


class UsuarioPerfilActualizar(BaseModel):
    """Datos que el usuario puede cambiar en su propio perfil."""

    nom_usr: str = Field(min_length=2, max_length=100)
    mail: str = Field(min_length=5, max_length=150)
    dir_usr: str | None = Field(default=None, max_length=255)


class UsuarioActualizar(BaseModel):
    """Valida los campos que puede modificar una operación administrativa."""
    nom_usr: str = Field(min_length=2, max_length=100)
    mail: str = Field(min_length=5, max_length=150)
    dir_usr: str | None = None
    tip_usu: int = 2


class LoginRequest(BaseModel):
    """Valida el correo y la contraseña recibidos durante el inicio de sesión."""
    mail: str = Field(min_length=5, max_length=150)
    password: str = Field(min_length=1, max_length=128)


# PUBLICACIONES

class BlogCrear(BaseModel):
    """Valida los datos de una publicación o película nueva del catálogo."""
    titulo: str = Field(min_length=2, max_length=200)
    descripcion: str = Field(min_length=1, max_length=500)
    img: str | None = Field(default=None, max_length=255)
    tags: str | None = Field(default="General", max_length=255)


class BlogRespuesta(BaseModel):
    """Define los campos de una publicación que se devuelve a los clientes."""
    id_blog: int
    titulo: str
    descripcion: str | None = None
    img: str | None = None
    tags: str | None = None
    fecha_publicacion: datetime | None = None
    es_pelicula: bool = False

    model_config = ConfigDict(from_attributes=True)


class PeliculaUsuarioRespuesta(BaseModel):
    """Datos del catálogo público y resumen de calificaciones."""

    id_blog: int
    titulo: str
    descripcion: str | None = None
    img: str | None = None
    tags: str | None = None
    fecha_publicacion: datetime | None = None
    calificacion_promedio: float = 0
    total_resenas: int = 0
    es_favorita: bool = False


class ResenaUsuarioCrear(BaseModel):
    """El texto es opcional; la calificación de una reseña es obligatoria."""

    calificacion: int = Field(ge=1, le=5)
    comentario: str = Field(default="", max_length=250)


class ResenaUsuarioRespuesta(BaseModel):
    """Representa una reseña pública con su película, autor, texto y puntuación."""
    id_com: int
    usr_id: int
    blog_id: int
    nombre_usuario: str
    comentario: str
    fecha: datetime
    calificacion: int


class MiResenaRespuesta(BaseModel):
    """Representa una reseña del usuario actual e incluye el título de la película."""
    id_com: int
    blog_id: int
    titulo_pelicula: str
    comentario: str
    fecha: datetime
    calificacion: int


class ReporteResenaRespuesta(BaseModel):
    """Representa el estado de un reporte de reseña enviado por un usuario."""
    id_reporte: int
    usr_id: int
    id_com: int
    fecha: datetime
    estatus: str

    model_config = ConfigDict(from_attributes=True)


class ReporteResenaAdminRespuesta(BaseModel):
    """Información completa para revisar un reporte desde el panel admin."""

    id_reporte: int
    id_com: int
    titulo_pelicula: str
    autor_resena: str
    reportado_por: str
    comentario: str
    calificacion: int
    fecha_reporte: datetime
    estatus: str
    estatus_resena: int


class ReporteResenaModeracion(BaseModel):
    """Acción administrativa que atiende o descarta un reporte."""

    estatus: Literal["resuelto", "descartado"]
    ocultar_resena: bool = False


# COMENTARIOS

class ComentarioCrear(BaseModel):
    """Valida un comentario o reseña y los identificadores asociados."""
    comentario: str = Field(min_length=1, max_length=500)
    usr_id: int
    blog_id: int
    calificacion: int | None = Field(default=None, ge=1, le=5)


class ComentarioRespuesta(BaseModel):
    """Define los campos de un comentario o reseña devueltos por la API."""
    id_com: int
    comentario: str
    fecha: datetime
    estatus: int
    usr_id: int
    blog_id: int
    calificacion: int | None = None
    model_config = ConfigDict(from_attributes=True)

class Config:
    """Mantiene la configuración ORM para convertir objetos de base de datos."""
    from_attributes = True

# RESPUESTA DEL LOGIN CON TOKEN
class LoginRespuesta(UsuarioRespuesta):
    """Combina los datos de la cuenta con el token emitido al iniciar sesión."""
    access_token: str
    token_type: str = "bearer"


# CREAR USUARIOS DESDE ADMIN
class UsuarioCrearAdmin(UsuarioCrear):
    """Extiende el registro de cuentas con validación del rol desde administración."""
    tip_usu: int = Field(default=2, ge=1, le=2)


# ACTUALIZAR PELÍCULAS
class BlogActualizar(BaseModel):
    """Valida los campos editables de una película o publicación existente."""
    titulo: str = Field(min_length=2, max_length=200)
    descripcion: str = Field(min_length=1, max_length=500)
    img: str | None = Field(default=None, max_length=255)
    tags: str | None = Field(default=None, max_length=255)


# CAMBIAR ESTADO DE UNA RESEÑA
class ComentarioModerar(BaseModel):
    """Valida el nuevo estado de publicación de una reseña moderada."""
    estatus: int = Field(ge=0, le=1)
