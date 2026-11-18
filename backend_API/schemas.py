
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


# USUARIOS

class UsuarioCrear(BaseModel):
    nom_usr: str = Field(min_length=2, max_length=100)
    mail: str = Field(min_length=5, max_length=150)
    password: str = Field(min_length=8, max_length=72)
    dir_usr: str | None = None

    # Se conserva para compatibilidad con Flutter.
    # El servidor no confiará en este campo.
    tip_usu: int = 2


class UsuarioRespuesta(BaseModel):
    id_usr: int
    nom_usr: str
    mail: str
    dir_usr: str | None
    tip_usu: int

    model_config = ConfigDict(from_attributes=True)


class UsuarioActualizar(BaseModel):
    nom_usr: str = Field(min_length=2, max_length=100)
    mail: str = Field(min_length=5, max_length=150)
    dir_usr: str | None = None
    tip_usu: int = 2


class LoginRequest(BaseModel):
    mail: str = Field(min_length=5, max_length=150)
    password: str = Field(min_length=1, max_length=128)


# PUBLICACIONES

class BlogCrear(BaseModel):
    titulo: str = Field(min_length=2, max_length=200)
    descripcion: str = Field(min_length=1, max_length=500)
    img: str | None = Field(default=None, max_length=255)
    tags: str | None = Field(default="General", max_length=255)


class BlogRespuesta(BaseModel):
    id_blog: int
    titulo: str
    descripcion: str | None = None
    img: str | None = None
    tags: str | None = None
    fecha_publicacion: datetime | None = None

    model_config = ConfigDict(from_attributes=True)


# COMENTARIOS

class ComentarioCrear(BaseModel):
    comentario: str = Field(min_length=1, max_length=500)
    usr_id: int
    blog_id: int
    calificacion: int | None = Field(default=None, ge=1, le=5)


class ComentarioRespuesta(BaseModel):
    id_com: int
    comentario: str
    fecha: datetime
    estatus: int
    usr_id: int
    blog_id: int
    calificacion: int | None = None
    model_config = ConfigDict(from_attributes=True)

class Config:
    from_attributes = True

# RESPUESTA DEL LOGIN CON TOKEN
class LoginRespuesta(UsuarioRespuesta):
    access_token: str
    token_type: str = "bearer"


# CREAR USUARIOS DESDE ADMIN
class UsuarioCrearAdmin(UsuarioCrear):
    tip_usu: int = Field(default=2, ge=1, le=2)


# ACTUALIZAR PELÍCULAS
class BlogActualizar(BaseModel):
    titulo: str = Field(min_length=2, max_length=200)
    descripcion: str = Field(min_length=1, max_length=500)
    img: str | None = Field(default=None, max_length=255)
    tags: str | None = Field(default=None, max_length=255)


# CAMBIAR ESTADO DE UNA RESEÑA
class ComentarioModerar(BaseModel):
    estatus: int = Field(ge=0, le=1)
