"""Define los endpoints autenticados del catálogo, perfil, reseñas, reportes y favoritos.
Sus funciones definen endpoints HTTP y delegan datos en las capas del backend."""

from fastapi import APIRouter, Depends, Query, Response, status
from sqlalchemy.orm import Session

from api.routes.admin_api import obtener_usuario_actual
from db.session import obtener_sesion
from domain.models import Usuario
from domain.schemas import (
    MiResenaRespuesta,
    PeliculaUsuarioRespuesta,
    ResenaUsuarioCrear,
    ResenaUsuarioRespuesta,
    ReporteResenaRespuesta,
    UsuarioPerfilActualizar,
    UsuarioRespuesta,
)
from services.movie_service import movie_service


router = APIRouter(tags=["Usuario"])


@router.get("/peliculas", response_model=list[PeliculaUsuarioRespuesta])
def listar_peliculas(
    q: str | None = Query(default=None, max_length=100),
    db: Session = Depends(obtener_sesion),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Lista el catálogo activo y aplica la búsqueda opcional por título."""
    return movie_service.list_movies(db, usuario, q)


@router.get(
    "/peliculas/{blog_id}", response_model=PeliculaUsuarioRespuesta
)
def obtener_pelicula(
    blog_id: int,
    db: Session = Depends(obtener_sesion),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Devuelve el detalle de una película y su resumen de reseñas."""
    return movie_service.get_movie(db, blog_id, usuario)


@router.get(
    "/peliculas/{blog_id}/resenas",
    response_model=list[ResenaUsuarioRespuesta],
)
def listar_resenas_pelicula(
    blog_id: int,
    db: Session = Depends(obtener_sesion),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Lista las reseñas publicadas para una película."""
    return movie_service.list_reviews(db, blog_id)


@router.get("/favoritos", response_model=list[PeliculaUsuarioRespuesta])
def listar_favoritos(
    db: Session = Depends(obtener_sesion),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Lista los favoritos que pertenecen a la sesión actual."""
    return movie_service.list_favorites(db, usuario)


@router.put(
    "/favoritos/{blog_id}", status_code=status.HTTP_204_NO_CONTENT
)
def agregar_favorito(
    blog_id: int,
    db: Session = Depends(obtener_sesion),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Guarda una película como favorita de forma idempotente."""
    movie_service.add_favorite(db, blog_id, usuario)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.delete(
    "/favoritos/{blog_id}", status_code=status.HTTP_204_NO_CONTENT
)
def quitar_favorito(
    blog_id: int,
    db: Session = Depends(obtener_sesion),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Elimina un favorito de la sesión actual si existe."""
    movie_service.remove_favorite(db, blog_id, usuario)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post(
    "/peliculas/{blog_id}/resenas",
    response_model=ResenaUsuarioRespuesta,
    status_code=status.HTTP_201_CREATED,
)
def crear_resena(
    blog_id: int,
    datos: ResenaUsuarioCrear,
    db: Session = Depends(obtener_sesion),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Crea una reseña vinculándola al usuario del token."""
    return movie_service.create_review(
        db, blog_id, usuario, datos.calificacion, datos.comentario
    )


@router.post(
    "/resenas/{id_com}/reportes",
    response_model=ReporteResenaRespuesta,
    status_code=status.HTTP_201_CREATED,
)
def reportar_resena(
    id_com: int,
    db: Session = Depends(obtener_sesion),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Envía una reseña a la bandeja de moderación."""
    return movie_service.report_review(db, id_com, usuario)


@router.get("/usuarios/me", response_model=UsuarioRespuesta)
def obtener_mi_perfil(usuario: Usuario = Depends(obtener_usuario_actual)):
    """Devuelve el perfil asociado al token actual."""
    return usuario


@router.put("/usuarios/me", response_model=UsuarioRespuesta)
def actualizar_mi_perfil(
    datos: UsuarioPerfilActualizar,
    db: Session = Depends(obtener_sesion),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Actualiza los datos editables sin permitir cambiar el rol."""
    return movie_service.update_profile(
        db, usuario, datos.nom_usr, datos.mail, datos.dir_usr
    )


@router.get(
    "/usuarios/me/resenas", response_model=list[MiResenaRespuesta]
)
def listar_mis_resenas(
    db: Session = Depends(obtener_sesion),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    """Lista las reseñas y calificaciones creadas por este usuario."""
    return movie_service.list_my_reviews(db, usuario)
