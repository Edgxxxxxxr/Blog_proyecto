"""Aplica las reglas del catálogo de usuario y prepara respuestas para películas, perfil y reseñas.
Esta capa combina repositorios y aplica reglas de negocio."""

from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session
from fastapi import HTTPException

from domain.models import Comentario, Favorito, ReporteResena, Usuario
from domain.schemas import (
    MiResenaRespuesta,
    PeliculaUsuarioRespuesta,
    ResenaUsuarioRespuesta,
)
from repositories.movie_repository import MovieRepository


class MovieService:
    """Coordina repositorio, validaciones y formatos de respuesta de usuario."""

    def __init__(self, repository: MovieRepository | None = None):
        """Guarda el repositorio que provee las consultas SQLAlchemy del servicio."""
        self.repository = repository or MovieRepository()

    def _require_movie(self, db: Session, movie_id: int):
        """Confirma que el registro existe y está marcado como película."""
        movie = self.repository.get_movie(db, movie_id)
        if movie is None or not movie.es_pelicula:
            raise HTTPException(status_code=404, detail="Película no encontrada")
        return movie

    def _movie_response(
        self, db: Session, movie, user_id: int
    ) -> PeliculaUsuarioRespuesta:
        """Combina los datos de catálogo, calificaciones y favorito en la respuesta pública."""
        average, count = self.repository.get_rating_summary(db, movie.id_blog)
        return PeliculaUsuarioRespuesta(
            id_blog=movie.id_blog,
            titulo=movie.titulo,
            descripcion=movie.descripcion,
            img=movie.img,
            tags=movie.tags,
            fecha_publicacion=movie.fecha_publicacion,
            calificacion_promedio=round(average, 1),
            total_resenas=count,
            es_favorita=self.repository.is_favorite(db, user_id, movie.id_blog),
        )

    def list_movies(
        self, db: Session, user: Usuario, query: str | None
    ) -> list[PeliculaUsuarioRespuesta]:
        """Devuelve el catálogo de películas con los datos personalizados del usuario."""
        # Convierte cada película en una respuesta con calificación y favorito del usuario.
        return [
            self._movie_response(db, movie, user.id_usr)
            for movie in self.repository.list_movies(db, (query or "").strip())
        ]

    def get_movie(
        self, db: Session, movie_id: int, user: Usuario
    ) -> PeliculaUsuarioRespuesta:
        """Devuelve el detalle y resumen de una película válida."""
        movie = self._require_movie(db, movie_id)
        return self._movie_response(db, movie, user.id_usr)

    def list_reviews(
        self, db: Session, movie_id: int
    ) -> list[ResenaUsuarioRespuesta]:
        """Devuelve las reseñas públicas con sus autores y puntuaciones."""
        self._require_movie(db, movie_id)
        # Incluye en cada elemento los datos públicos del autor de la reseña.
        return [
            ResenaUsuarioRespuesta(
                id_com=review.id_com,
                usr_id=review.usr_id,
                blog_id=review.blog_id,
                nombre_usuario=name,
                comentario=review.comentario,
                fecha=review.fecha,
                calificacion=review.calificacion,
            )
            for review, name in self.repository.list_reviews(db, movie_id)
        ]

    def list_favorites(
        self, db: Session, user: Usuario
    ) -> list[PeliculaUsuarioRespuesta]:
        """Devuelve la lista de películas favoritas del usuario autenticado."""
        # Añade a cada favorito su resumen de calificaciones para la vista.
        return [
            self._movie_response(db, movie, user.id_usr)
            for movie in self.repository.list_favorites(db, user.id_usr)
        ]

    def add_favorite(self, db: Session, movie_id: int, user: Usuario) -> None:
        """Valida la película y registra el favorito de forma idempotente."""
        self._require_movie(db, movie_id)
        if self.repository.get_favorite(db, user.id_usr, movie_id) is not None:
            return
        try:
            self.repository.add_favorite(
                db, Favorito(usr_id=user.id_usr, blog_id=movie_id)
            )
        except IntegrityError:
            # La restricción única hace idempotente una pulsación concurrente.
            db.rollback()

    def remove_favorite(self, db: Session, movie_id: int, user: Usuario) -> None:
        """Elimina el favorito del usuario si la relación existe."""
        favorite = self.repository.get_favorite(db, user.id_usr, movie_id)
        if favorite is not None:
            self.repository.delete_favorite(db, favorite)

    def create_review(
        self,
        db: Session,
        movie_id: int,
        user: Usuario,
        rating: int,
        comment: str,
    ) -> ResenaUsuarioRespuesta:
        """Valida la película y guarda una reseña vinculada al usuario autenticado."""
        self._require_movie(db, movie_id)
        review = self.repository.add_review(
            db,
            Comentario(
                comentario=comment.strip(),
                calificacion=rating,
                usr_id=user.id_usr,
                blog_id=movie_id,
                estatus=1,
            ),
        )
        return ResenaUsuarioRespuesta(
            id_com=review.id_com,
            usr_id=review.usr_id,
            blog_id=review.blog_id,
            nombre_usuario=user.nom_usr,
            comentario=review.comentario,
            fecha=review.fecha,
            calificacion=review.calificacion,
        )

    def report_review(self, db: Session, review_id: int, user: Usuario):
        """Valida la reseña y registra un reporte único para moderación."""
        review = self.repository.get_review(db, review_id)
        if review is None or review.calificacion is None:
            raise HTTPException(status_code=404, detail="Reseña no encontrada")
        if review.usr_id == user.id_usr:
            raise HTTPException(
                status_code=400,
                detail="No puedes reportar tu propia reseña",
            )
        try:
            return self.repository.add_report(
                db, ReporteResena(usr_id=user.id_usr, id_com=review_id)
            )
        except IntegrityError:
            db.rollback()
            raise HTTPException(status_code=409, detail="Ya reportaste esta reseña")

    def update_profile(
        self, db: Session, user: Usuario, name: str, email: str, address: str | None
    ) -> Usuario:
        """Normaliza y persiste los datos editables del perfil."""
        user.nom_usr = name.strip()
        user.mail = email.strip().lower()
        user.dir_usr = address.strip() if address else None
        try:
            return self.repository.update_user(db, user)
        except IntegrityError:
            db.rollback()
            raise HTTPException(status_code=409, detail="El correo ya está registrado")

    def list_my_reviews(
        self, db: Session, user: Usuario
    ) -> list[MiResenaRespuesta]:
        """Prepara la lista de reseñas propias con los títulos del catálogo."""
        # Combina cada reseña del usuario con el título de su película.
        return [
            MiResenaRespuesta(
                id_com=review.id_com,
                blog_id=review.blog_id,
                titulo_pelicula=title,
                comentario=review.comentario,
                fecha=review.fecha,
                calificacion=review.calificacion,
            )
            for review, title in self.repository.list_user_reviews(db, user.id_usr)
        ]


movie_service = MovieService()
