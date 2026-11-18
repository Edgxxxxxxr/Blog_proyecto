
from pathlib import Path
from uuid import uuid4
from fastapi import UploadFile, File

from dotenv import load_dotenv
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
load_dotenv()

import os
import hmac
import json
import base64
import hashlib
import time

from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    Header,
)
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from database import obtener_sesion
from models import Usuario, Blog, Comentario
from schemas import (
    UsuarioCrearAdmin,
    UsuarioActualizar,
    UsuarioRespuesta,
    BlogActualizar,
    BlogRespuesta,
    ComentarioModerar,
    ComentarioRespuesta,
)
from seguridad import crear_hash


router = APIRouter(prefix="/admin", tags=["Administrador"])


# =====================================
# AUTENTICACIÓN
# =====================================

def obtener_clave():
    clave = os.getenv("API_SECRET_KEY", "")
    if len(clave) < 32:
        raise RuntimeError(
            "Configura API_SECRET_KEY en el archivo .env"
        )
    return clave.encode("utf-8")


def codificar(datos):
    contenido = json.dumps(
        datos, separators=(",", ":")
    ).encode("utf-8")

    return base64.urlsafe_b64encode(
        contenido
    ).decode("ascii").rstrip("=")


def decodificar(texto):
    texto += "=" * (-len(texto) % 4)
    return json.loads(
        base64.urlsafe_b64decode(texto)
    )


def crear_token(usuario_id):
    contenido = codificar({
        "id": usuario_id,
        "exp": int(time.time()) + 8 * 3600,
    })

    firma = hmac.new(
        obtener_clave(),
        contenido.encode("ascii"),
        hashlib.sha256,
    ).hexdigest()

    return f"{contenido}.{firma}"

seguridad_bearer = HTTPBearer()
def obtener_usuario_actual(
    credenciales: HTTPAuthorizationCredentials = Depends(
        seguridad_bearer
    ),
    db: Session = Depends(obtener_sesion),
):
    try:
        token = credenciales.credentials

        contenido, firma = token.split(".", 1)

        firma_correcta = hmac.new(
            obtener_clave(),
            contenido.encode("ascii"),
            hashlib.sha256,
        ).hexdigest()

        if not hmac.compare_digest(
            firma,
            firma_correcta
        ):
            raise ValueError("Firma incorrecta")

        datos = decodificar(contenido)

        if int(datos["exp"]) <= time.time():
            raise ValueError("Token vencido")

        usuario = db.get(
            Usuario,
            int(datos["id"])
        )

        if usuario is None:
            raise ValueError("Usuario inexistente")

        return usuario

    except (
        ValueError,
        KeyError,
        TypeError,
        AttributeError
    ):
        raise HTTPException(
            status_code=401,
            detail="Sesión inválida o vencida"
        )

def exigir_admin(
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    if usuario.tip_usu != 1:
        raise HTTPException(
            status_code=403,
            detail="No tienes permisos de administrador"
        )

    return usuario


# =====================================
# ESTADÍSTICAS
# =====================================

@router.get("/estadisticas")
def estadisticas(
    db: Session = Depends(obtener_sesion),
    admin: Usuario = Depends(exigir_admin),
):
    return {
        "peliculas": len(db.scalars(select(Blog)).all()),
        "usuarios": len(db.scalars(select(Usuario)).all()),
        "resenas": len(db.scalars(select(Comentario)).all()),
    }


# =====================================
# PELÍCULAS
# =====================================

@router.put("/peliculas/{id_blog}",
            response_model=BlogRespuesta)
def editar_pelicula(
    id_blog: int,
    datos: BlogActualizar,
    db: Session = Depends(obtener_sesion),
    admin: Usuario = Depends(exigir_admin),
):
    pelicula = db.get(Blog, id_blog)

    if pelicula is None:
        raise HTTPException(404, "Película no encontrada")

    pelicula.titulo = datos.titulo.strip()
    pelicula.descripcion = datos.descripcion.strip()
    pelicula.img = datos.img
    pelicula.tags = datos.tags

    db.commit()
    db.refresh(pelicula)

    return pelicula


@router.delete("/peliculas/{id_blog}")
def eliminar_pelicula(
    id_blog: int,
    db: Session = Depends(obtener_sesion),
    admin: Usuario = Depends(exigir_admin),
):
    pelicula = db.get(Blog, id_blog)

    if pelicula is None:
        raise HTTPException(404, "Película no encontrada")

    db.delete(pelicula)

    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            409,
            "No se puede eliminar: la película tiene comentarios asociados",
        )

    return {"mensaje": "Película eliminada"}


# =====================================
# USUARIOS
# =====================================

@router.post(
    "/usuarios",
    response_model=UsuarioRespuesta,
    status_code=201,
)
def agregar_usuario_admin(
    datos: UsuarioCrearAdmin,
    db: Session = Depends(obtener_sesion),
    admin: Usuario = Depends(exigir_admin),
):
    usuario = Usuario(
        nom_usr=datos.nom_usr.strip(),
        mail=datos.mail.strip().lower(),
        pass_hash=crear_hash(datos.password),
        dir_usr=datos.dir_usr,
        tip_usu=datos.tip_usu,
    )

    db.add(usuario)

    try:
        db.commit()
        db.refresh(usuario)
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            409, "El correo ya está registrado"
        )

    return usuario


@router.put(
    "/usuarios/{id_usr}",
    response_model=UsuarioRespuesta,
)
def editar_usuario(
    id_usr: int,
    datos: UsuarioActualizar,
    db: Session = Depends(obtener_sesion),
    admin: Usuario = Depends(exigir_admin),
):
    usuario = db.get(Usuario, id_usr)

    if usuario is None:
        raise HTTPException(404, "Usuario no encontrado")

    if id_usr == admin.id_usr and datos.tip_usu != 1:
        raise HTTPException(
            400, "No puedes quitarte tu propio rol"
        )

    if datos.tip_usu not in (1, 2):
        raise HTTPException(422, "Rol no válido")

    usuario.nom_usr = datos.nom_usr.strip()
    usuario.mail = datos.mail.strip().lower()
    usuario.dir_usr = datos.dir_usr
    usuario.tip_usu = datos.tip_usu

    try:
        db.commit()
        db.refresh(usuario)
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            409, "El correo ya está registrado"
        )

    return usuario


@router.delete("/usuarios/{id_usr}")
def eliminar_usuario_admin(
    id_usr: int,
    db: Session = Depends(obtener_sesion),
    admin: Usuario = Depends(exigir_admin),
):
    if id_usr == admin.id_usr:
        raise HTTPException(
            400, "No puedes eliminar tu propia cuenta"
        )

    usuario = db.get(Usuario, id_usr)

    if usuario is None:
        raise HTTPException(404, "Usuario no encontrado")

    db.delete(usuario)

    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            409, "El usuario tiene comentarios asociados"
        )

    return {"mensaje": "Usuario eliminado"}


# =====================================
# RESEÑAS
# =====================================

@router.put(
    "/resenas/{id_com}",
    response_model=ComentarioRespuesta,
)
def moderar_resena(
    id_com: int,
    datos: ComentarioModerar,
    db: Session = Depends(obtener_sesion),
    admin: Usuario = Depends(exigir_admin),
):
    resena = db.get(Comentario, id_com)

    if resena is None:
        raise HTTPException(404, "Reseña no encontrada")

    resena.estatus = datos.estatus

    db.commit()
    db.refresh(resena)

    return resena


@router.delete("/resenas/{id_com}")
def eliminar_resena(
    id_com: int,
    db: Session = Depends(obtener_sesion),
    admin: Usuario = Depends(exigir_admin),
):
    resena = db.get(Comentario, id_com)

    if resena is None:
        raise HTTPException(404, "Reseña no encontrada")

    db.delete(resena)
    db.commit()

    return {"mensaje": "Reseña eliminada"}


# =====================================
# CONSULTAR PELÍCULAS
# =====================================

@router.get(
    "/peliculas",
    response_model=list[BlogRespuesta]
)
def listar_peliculas_admin(
    db: Session = Depends(obtener_sesion),
    admin: Usuario = Depends(exigir_admin),
):
    return db.scalars(
        select(Blog).order_by(Blog.id_blog.desc())
    ).all()


# =====================================
# AGREGAR PELÍCULAS
# =====================================

@router.post(
    "/peliculas",
    response_model=BlogRespuesta,
    status_code=201
)
def agregar_pelicula_admin(
    datos: BlogActualizar,
    db: Session = Depends(obtener_sesion),
    admin: Usuario = Depends(exigir_admin),
):
    pelicula = Blog(
        titulo=datos.titulo.strip(),
        descripcion=datos.descripcion.strip(),
        img=datos.img,
        tags=datos.tags,
    )

    db.add(pelicula)
    db.commit()
    db.refresh(pelicula)

    return pelicula


# =====================================
# CONSULTAR USUARIOS
# =====================================

@router.get(
    "/usuarios",
    response_model=list[UsuarioRespuesta]
)
def listar_usuarios_admin(
    db: Session = Depends(obtener_sesion),
    admin: Usuario = Depends(exigir_admin),
):
    return db.scalars(
        select(Usuario).order_by(Usuario.id_usr)
    ).all()


# =====================================
# CONSULTAR RESEÑAS
# =====================================

@router.get(
    "/resenas",
    response_model=list[ComentarioRespuesta]
)
def listar_resenas_admin(
    db: Session = Depends(obtener_sesion),
    admin: Usuario = Depends(exigir_admin),
):
    return db.scalars(
        select(Comentario).order_by(
            Comentario.id_com.desc()
        )
    ).all()


# =====================================
# SUBIR IMAGEN DE UNA PELÍCULA
# =====================================

@router.post("/imagenes", status_code=201)
async def subir_imagen(
    imagen: UploadFile = File(...),
    admin: Usuario = Depends(exigir_admin),
):
    extension = Path(
        imagen.filename or ""
    ).suffix.lower()

    extensiones = {".jpg", ".jpeg", ".png", ".webp"}

    try:
        if extension not in extensiones:
            raise HTTPException(
                400,
                "Solo se permiten imágenes JPG, PNG y WebP"
            )

        contenido = await imagen.read(
            5 * 1024 * 1024 + 1
        )

        if not contenido or len(contenido) > 5 * 1024 * 1024:
            raise HTTPException(
                400,
                "La imagen debe pesar menos de 5 MB"
            )

        es_jpeg = contenido.startswith(b"\xff\xd8\xff")

        es_png = contenido.startswith(
            b"\x89PNG\r\n\x1a\n"
        )

        es_webp = (
            contenido.startswith(b"RIFF")
            and contenido[8:12] == b"WEBP"
        )

        valido = (
            (extension in {".jpg", ".jpeg"} and es_jpeg)
            or (extension == ".png" and es_png)
            or (extension == ".webp" and es_webp)
        )

        if not valido:
            raise HTTPException(
                400,
                "El archivo no es una imagen válida"
            )

        # Utilizar la carpeta compartida con PHP
        carpeta_web = os.getenv("WEB_IMAGES_DIR")

        nombre = f"{uuid4().hex}{extension}"

        if carpeta_web and Path(carpeta_web).is_dir():
            carpeta = Path(carpeta_web)
            ruta = nombre
        else:
            carpeta = (
                Path(__file__).resolve().parent
                / "uploads"
            )
            ruta = f"/uploads/{nombre}"

        carpeta.mkdir(parents=True, exist_ok=True)

        destino = carpeta / nombre
        destino.write_bytes(contenido)

        return {
            "img": ruta,
            "mensaje": "Imagen guardada correctamente"
        }

    except OSError:
        raise HTTPException(
            500,
            "No se pudo guardar la imagen"
        )

    finally:
        await imagen.close()
