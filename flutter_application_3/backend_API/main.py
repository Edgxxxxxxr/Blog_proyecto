import os
from pathlib import Path
from fastapi.staticfiles import StaticFiles

from admin_api import exigir_admin
from admin_api import (
    router as admin_router,
    crear_token,
)

from contextlib import asynccontextmanager
from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from seguridad import (
    crear_hash,
    verificar_password,
    necesita_migracion
)

from database import Base, engine, obtener_sesion
from models import Usuario, Blog, Comentario
from schemas import (
    UsuarioCrear,
    UsuarioActualizar,
    UsuarioRespuesta,
    LoginRespuesta,
    BlogCrear,
    BlogRespuesta,
    ComentarioCrear,
    ComentarioRespuesta,
    LoginRequest,
)

@asynccontextmanager
async def lifespan(app: FastAPI):
    yield

app = FastAPI(
    title="API de aplicación móvil",
    lifespan=lifespan,
)

app.include_router(admin_router)

# Compartir las imágenes del Blog Web con Flutter
CARPETA_IMAGENES_WEB = os.getenv("WEB_IMAGES_DIR")

if CARPETA_IMAGENES_WEB and Path(CARPETA_IMAGENES_WEB).is_dir():

    app.mount(
        "/imagenes",
        StaticFiles(directory=CARPETA_IMAGENES_WEB),
        name="imagenes_web"
    )


# Permitir la comunicación con Flutter Web (cualquier puerto de localhost)
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)



@app.post("/login", response_model=LoginRespuesta)
def iniciar_sesion(
    datos: LoginRequest,
    db: Session = Depends(obtener_sesion),
):
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

@app.get("/usuarios", response_model=list[UsuarioRespuesta])
def listar_usuarios(db: Session = Depends(obtener_sesion)):
    return db.scalars(
        select(Usuario).order_by(Usuario.id_usr)
    ).all()



@app.post(
    "/usuarios",
    response_model=UsuarioRespuesta,
    status_code=201
)
def crear_usuario(
    datos: UsuarioCrear,
    db: Session = Depends(obtener_sesion),
):
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
        tip_usu=1
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


@app.delete("/usuarios/{usuario_id}", dependencies=[Depends(exigir_admin)])
def eliminar_usuario(
    usuario_id: int,
    db: Session = Depends(obtener_sesion),
):
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

@app.get("/blog", response_model=list[BlogRespuesta])
def listar_blog(db: Session = Depends(obtener_sesion)):
    return db.scalars(
        select(Blog).order_by(Blog.id_blog)
    ).all()


@app.post("/blog", response_model=BlogRespuesta, status_code=201, dependencies=[Depends(exigir_admin)])
def crear_blog(
    datos: BlogCrear,
    db: Session = Depends(obtener_sesion),
):
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

@app.get(
    "/comentarios",
    response_model=list[ComentarioRespuesta],
)
def listar_comentarios(db: Session = Depends(obtener_sesion)):
    return db.scalars(
        select(Comentario).order_by(Comentario.id_com)
    ).all()


@app.post(
    "/comentarios",
    response_model=ComentarioRespuesta,
    status_code=201,
)
def crear_comentario(
    datos: ComentarioCrear,
    db: Session = Depends(obtener_sesion),
):
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

from pathlib import Path
from uuid import uuid4
from fastapi import UploadFile, File, Form
from fastapi.staticfiles import StaticFiles
import os
from sqlalchemy.exc import SQLAlchemyError

UPLOAD_DIR = Path(__file__).resolve().parent / "uploads"
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=str(UPLOAD_DIR)), name="uploads")

@app.post("/blog/foto", response_model=BlogRespuesta, status_code=201, dependencies=[Depends(exigir_admin)])
async def crear_blog_con_foto(
    tags: str | None = Form(None),
    titulo: str = Form(...),
    descripcion: str = Form(...),
    imagen: UploadFile = File(...),
    db: Session = Depends(obtener_sesion),
):
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