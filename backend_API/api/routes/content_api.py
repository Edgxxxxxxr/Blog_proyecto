"""Define los endpoints existentes de acceso, cuentas, publicaciones y comentarios.
Sus funciones definen endpoints HTTP y delegan datos en las capas del backend."""

from pathlib import Path
from uuid import uuid4

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from sqlalchemy.orm import Session

from api.routes.admin_api import crear_token, exigir_admin
from core.security import crear_hash, necesita_migracion, verificar_password
from db.session import obtener_sesion
from domain.models import Blog, Comentario, Usuario
from domain.schemas import (
    BlogCrear,
    BlogRespuesta,
    ComentarioCrear,
    ComentarioRespuesta,
    LoginRequest,
    LoginRespuesta,
    UsuarioCrear,
    UsuarioRespuesta,
)

router = APIRouter(tags=["Cuentas y contenido"])
UPLOAD_DIR = Path(__file__).resolve().parents[2] / "uploads"
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
@router.post("/login", response_model=LoginRespuesta)
def iniciar_sesion(
    datos: LoginRequest,
    db: Session = Depends(obtener_sesion),
):
    """Valida las credenciales y devuelve el token de acceso de la cuenta."""
    correo = datos.mail.strip().lower()

    usuario = db.scalar(
        select(Usuario).where(Usuario.mail == correo)
    )

    if usuario is None or not verificar_password(
        datos.password,
        usuario.pass_hash
    ):
        raise HTTPException(
            status_code=401,
            detail="Correo o contraseña incorrectos"
        )

    # Migrar contraseñas antiguas de FastAPI a bcrypt
    if necesita_migracion(usuario.pass_hash):
        try:
            usuario.pass_hash = crear_hash(datos.password)
            db.commit()
        except Exception:
            db.rollback()
            raise HTTPException(
                status_code=500,
                detail="No se pudo actualizar la contraseña"
            )

    return {
        "id_usr": usuario.id_usr,
        "nom_usr": usuario.nom_usr,
        "mail": usuario.mail,
        "dir_usr": usuario.dir_usr,
        "tip_usu": usuario.tip_usu,
        "access_token": crear_token(usuario.id_usr),
        "token_type": "bearer",
    }


# USUARIOS

@router.get("/usuarios", response_model=list[UsuarioRespuesta])
def listar_usuarios(db: Session = Depends(obtener_sesion)):
    """Devuelve las cuentas registradas para los consumidores autorizados del endpoint."""
    return db.scalars(
        select(Usuario).order_by(Usuario.id_usr)
    ).all()



@router.post(
    "/usuarios",
    response_model=UsuarioRespuesta,
    status_code=201
)
def crear_usuario(
    datos: UsuarioCrear,
    db: Session = Depends(obtener_sesion),
):
    """Valida los datos, genera el hash de contraseña y crea una cuenta de usuario."""
    nombre = datos.nom_usr.strip()
    correo = datos.mail.strip().lower()

    if not nombre:
        raise HTTPException(
            status_code=422,
            detail="El nombre es obligatorio"
        )

    try:
        hash_password = crear_hash(datos.password)
    except ValueError as e:
        raise HTTPException(
            status_code=422,
            detail=str(e)
        )

    usuario = Usuario(
        nom_usr=nombre,
        mail=correo,
        pass_hash=hash_password,
        dir_usr=datos.dir_usr,
        # El registro público siempre crea cuentas de usuario, nunca admins.
        tip_usu=2
    )

    db.add(usuario)

    try:
        db.commit()
        db.refresh(usuario)
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="El correo ya está registrado"
        )

    return usuario


@router.delete("/usuarios/{usuario_id}", dependencies=[Depends(exigir_admin)])
def eliminar_usuario(
    usuario_id: int,
    db: Session = Depends(obtener_sesion),
):
    """Elimina la cuenta indicada y gestiona restricciones de la base de datos."""
    usuario = db.get(Usuario, usuario_id)

    if usuario is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )
        
    db.delete(usuario)
    
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="No se puede eliminar: el usuario tiene comentarios asociados",
        )

    return {"mensaje": "Usuario eliminado correctamente"}



# BLOG

@router.get("/blog", response_model=list[BlogRespuesta])
def listar_blog(db: Session = Depends(obtener_sesion)):
    """Devuelve las publicaciones ordenadas del blog."""
    return db.scalars(
        select(Blog).order_by(Blog.id_blog)
    ).all()


@router.post("/blog", response_model=BlogRespuesta, status_code=201, dependencies=[Depends(exigir_admin)])
def crear_blog(
    datos: BlogCrear,
    db: Session = Depends(obtener_sesion),
):
    """Valida y guarda una publicación nueva del blog."""
    publicacion = Blog(
        titulo=datos.titulo.strip(),
        descripcion=datos.descripcion.strip(),
        img=datos.img.strip() if datos.img and datos.img.strip() else None,
        tags=datos.tags.strip() if datos.tags and datos.tags.strip() else None,
    )
    db.add(publicacion)
    db.commit()
    db.refresh(publicacion)
    return publicacion


# COMENTARIOS

@router.get(
    "/comentarios",
    response_model=list[ComentarioRespuesta],
)
def listar_comentarios(db: Session = Depends(obtener_sesion)):
    """Devuelve los comentarios registrados en la base de datos."""
    return db.scalars(
        select(Comentario).order_by(Comentario.id_com)
    ).all()


@router.post(
    "/comentarios",
    response_model=ComentarioRespuesta,
    status_code=201,
)
def crear_comentario(
    datos: ComentarioCrear,
    db: Session = Depends(obtener_sesion),
):
    """Valida usuario, publicación y texto antes de guardar el comentario."""
    if not datos.comentario.strip():
        raise HTTPException(
            status_code=422,
            detail="El comentario no puede estar vacío",
        )

    if db.get(Usuario, datos.usr_id) is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    if db.get(Blog, datos.blog_id) is None:
        raise HTTPException(
            status_code=404,
            detail="Publicación no encontrada",
        )

    nuevo_comentario = Comentario(
        comentario=datos.comentario.strip(),
        usr_id=datos.usr_id,
        blog_id=datos.blog_id,
        estatus=1,
        calificacion=datos.calificacion,
    )

    db.add(nuevo_comentario)
    db.commit()
    db.refresh(nuevo_comentario)

    return nuevo_comentario
@router.post("/blog/foto", response_model=BlogRespuesta, status_code=201, dependencies=[Depends(exigir_admin)])
async def crear_blog_con_foto(
    tags: str | None = Form(None),
    titulo: str = Form(...),
    descripcion: str = Form(...),
    imagen: UploadFile = File(...),
    db: Session = Depends(obtener_sesion),
):
    """Valida y guarda la imagen y publicación como una sola operación."""
    titulo = titulo.strip()
    descripcion = descripcion.strip()
    if not 2 <= len(titulo) <= 150 or not descripcion:
        raise HTTPException(status_code=422, detail="Título (2-150 caracteres) y descripción son obligatorios")

    extension = Path(imagen.filename or "").suffix.lower()
    if extension not in {".jpg", ".jpeg", ".png", ".webp"}:
        raise HTTPException(status_code=400, detail="Solo se permiten JPG, PNG y WebP")

    try:
        contenido = await imagen.read(5 * 1024 * 1024 + 1)
    finally:
        await imagen.close()
    if not contenido or len(contenido) > 5 * 1024 * 1024:
        raise HTTPException(status_code=400, detail="La imagen debe pesar entre 1 byte y 5 MB")

    es_jpeg = contenido.startswith(b"\xff\xd8\xff")
    es_png = contenido.startswith(b"\x89PNG\r\n\x1a\n")
    es_webp = contenido.startswith(b"RIFF") and contenido[8:12] == b"WEBP"
    valido = (extension in {".jpg", ".jpeg"} and es_jpeg) or (extension == ".png" and es_png) or (extension == ".webp" and es_webp)
    if not valido:
        raise HTTPException(status_code=400, detail="El contenido no coincide con una imagen admitida")

    nombre = f"{uuid4().hex}{extension}"
    destino = UPLOAD_DIR / nombre
    try:
        destino.write_bytes(contenido)
        nuevo = Blog(titulo=titulo, descripcion=descripcion, img=f"/uploads/{nombre}", tags=tags.strip() if tags and tags.strip() else None)
        db.add(nuevo)
        db.commit()
        db.refresh(nuevo)
        return nuevo
    except (OSError, SQLAlchemyError):
        db.rollback()
        destino.unlink(missing_ok=True)
        raise HTTPException(status_code=500, detail="No se pudo guardar el blog con fotografía")
