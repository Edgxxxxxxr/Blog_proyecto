from contextlib import asynccontextmanager


from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from pwdlib import PasswordHash

from pathlib import Path
import shutil
import uuid

from fastapi import (
    FastAPI,
    Depends,
    HTTPException,
    Response,
    Request,
    UploadFile,
    File,
    Form,
)
from fastapi.staticfiles import StaticFiles

from database import Base, engine, obtener_sesion
from models import Usuario, Blog, Comentario
from schemas import (
    UsuarioCrear,
    UsuarioActualizar,
    UsuarioRespuesta,
    BlogRespuesta,
    ComentarioCrear,
    ComentarioRespuesta,
    LoginRequest,
)

password_hash = PasswordHash.recommended()


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield


app = FastAPI(
    title="API de aplicación móvil",
    lifespan=lifespan,
)
UPLOAD_DIR = Path(__file__).resolve().parent / "uploads"
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

app.mount(
    "/uploads",
    StaticFiles(directory=str(UPLOAD_DIR)),
    name="uploads",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def inicio():
    return {"mensaje": "API funcionando correctamente"}

@app.post("/login", response_model=UsuarioRespuesta)
def iniciar_sesion(
    datos: LoginRequest,
    db: Session = Depends(obtener_sesion),
):
    correo = datos.mail.strip().lower()

    usuario = db.scalar(
        select(Usuario).where(Usuario.mail == correo)
    )

    # Se utiliza el mismo mensaje para no revelar
    # si el correo está registrado.
    if usuario is None or not password_hash.verify(
        datos.password,
        usuario.pass_hash,
    ):
        raise HTTPException(
            status_code=401,
            detail="Correo o contraseña incorrectos",
        )

    # Devuelve únicamente los datos públicos del usuario.
    return usuario

# USUARIOS

@app.get("/usuarios", response_model=list[UsuarioRespuesta])
def listar_usuarios(db: Session = Depends(obtener_sesion)):
    return db.scalars(
        select(Usuario).order_by(Usuario.id_usr)
    ).all()


@app.post("/usuarios", response_model=UsuarioRespuesta, status_code=201)
def crear_usuario(
    datos: UsuarioCrear,
    db: Session = Depends(obtener_sesion),
):
    usuario = Usuario(
        nom_usr=datos.nom_usr.strip(),
        mail=datos.mail.strip().lower(),
        pass_hash=password_hash.hash(datos.password),
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
            status_code=409,
            detail="El correo ya está registrado",
        )

    return usuario


@app.put("/usuarios/{usuario_id}", response_model=UsuarioRespuesta)
def actualizar_usuario(
    usuario_id: int,
    datos: UsuarioActualizar,
    db: Session = Depends(obtener_sesion),
):
    usuario = db.get(Usuario, usuario_id)

    if usuario is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    usuario.nom_usr = datos.nom_usr.strip()
    usuario.mail = datos.mail.strip().lower()
    usuario.dir_usr = datos.dir_usr
    usuario.tip_usu = datos.tip_usr

    try:
        db.commit()
        db.refresh(usuario)
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="El correo ya está registrado",
        )

    return usuario


@app.delete("/usuarios/{usuario_id}", status_code=204)
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
            detail="No se pudo eliminar el usuario porque tiene datos relacionados",
        )

    return Response(status_code=204)


# BLOG

@app.get("/blog", response_model=list[BlogRespuesta])
def listar_blog(db: Session = Depends(obtener_sesion)):
    return db.scalars(
        select(Blog).order_by(Blog.id_blog)
    ).all()


@app.post("/blog", response_model=BlogRespuesta, status_code=201)
def crear_blog(
    request: Request,
    titulo: str = Form(...),
    descripcion: str = Form(...),
    imagen: UploadFile = File(...),
    tags: str | None = Form(default=None),
    db: Session = Depends(obtener_sesion),
):
    if not titulo.strip() or not descripcion.strip():
        raise HTTPException(
            status_code=422,
            detail="El título y la descripción son obligatorios",
        )

    extension = Path(imagen.filename or "").suffix.lower()
    if extension not in {".jpg", ".jpeg", ".png", ".webp"}:
        raise HTTPException(
            status_code=400,
            detail="Formato de imagen no permitido. Usa JPG, JPEG, PNG o WEBP.",
        )

    nombre_archivo = f"{uuid.uuid4().hex}{extension}"
    ruta_archivo = UPLOAD_DIR / nombre_archivo

    with ruta_archivo.open("wb") as destino:
        shutil.copyfileobj(imagen.file, destino)

    url_imagen = (
        f"{str(request.base_url).rstrip('/')}/uploads/{nombre_archivo}"
    )

    publicacion = Blog(
        titulo=titulo.strip(),
        descripcion=descripcion.strip(),
        img=url_imagen,
        tags=tags.strip() if tags and tags.strip() else None,
    )

    try:
        db.add(publicacion)
        db.commit()
        db.refresh(publicacion)
    except Exception as error:
        db.rollback()
        ruta_archivo.unlink(missing_ok=True)
        raise HTTPException(
            status_code=500,
            detail="No se pudo guardar la publicación en la base de datos.",
        ) from error

    return publicacion


@app.get("/blog/{blog_id}", response_model=BlogRespuesta)
def obtener_blog(
    blog_id: int,
    db: Session = Depends(obtener_sesion),
):
    publicacion = db.get(Blog, blog_id)

    if publicacion is None:
        raise HTTPException(
            status_code=404,
            detail="Publicación no encontrada",
        )

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

    nuevo = Comentario(
        comentario=datos.comentario.strip(),
        usr_id=datos.usr_id,
        blog_id=datos.blog_id,
        estatus=1,
    )

    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)

    return nuevo

