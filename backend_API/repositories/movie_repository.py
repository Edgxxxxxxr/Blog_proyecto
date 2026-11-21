"""Encapsula las consultas SQLAlchemy del catálogo, favoritos, reseñas y reportes.
Esta capa concentra consultas y operaciones directas con la base de datos."""

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from domain.models import Blog, Comentario, Favorito, ReporteResena, Usuario


class MovieRepository:
    """Encapsula las consultas SQLAlchemy usadas por el catálogo de usuario."""

    def list_movies(self, db: Session, query: str = "") -> list[Blog]:
        """Busca películas activas por título y las devuelve ordenadas desde SQLAlchemy."""
        statement = select(Blog).where(Blog.es_pelicula.is_(True))
        if query:
            statement = statement.where(Blog.titulo.ilike(f"%{query}%"))
        return db.scalars(statement.order_by(Blog.id_blog.desc())).all()

    def get_movie(self, db: Session, movie_id: int) -> Blog | None:
        """Busca una fila del catálogo por su identificador."""
        return db.get(Blog, movie_id)

    def get_rating_summary(self, db: Session, movie_id: int) -> tuple[float, int]:
        """Calcula el promedio y el número de calificaciones publicadas."""
        summary = db.execute(
            select(
                func.coalesce(func.avg(Comentario.calificacion), 0),
                func.count(Comentario.id_com),
            ).where(
                Comentario.blog_id == movie_id,
                Comentario.estatus == 1,
                Comentario.calificacion.is_not(None),
            )
        ).one()
        return float(summary[0] or 0), int(summary[1] or 0)

    def is_favorite(self, db: Session, user_id: int, movie_id: int) -> bool:
        """Comprueba en la base de datos si existe la relación de favorito."""
        favorite_id = db.scalar(
            select(Favorito.id_fav).where(
                Favorito.usr_id == user_id,
                Favorito.blog_id == movie_id,
            )
        )
        return favorite_id is not None

    def list_reviews(self, db: Session, movie_id: int):
        """Consulta reseñas visibles junto con el nombre de cada autor."""
        return db.execute(
            select(Comentario, Usuario.nom_usr)
            .join(Usuario, Usuario.id_usr == Comentario.usr_id)
            .where(
                Comentario.blog_id == movie_id,
                Comentario.estatus == 1,
                Comentario.calificacion.is_not(None),
            )
            .order_by(Comentario.fecha.desc(), Comentario.id_com.desc())
        ).all()

    def list_favorites(self, db: Session, user_id: int) -> list[Blog]:
        """Recupera las películas favoritas de una cuenta en orden de guardado."""
        return db.scalars(
            select(Blog)
            .join(Favorito, Favorito.blog_id == Blog.id_blog)
            .where(
                Favorito.usr_id == user_id,
                Blog.es_pelicula.is_(True),
            )
            .order_by(Favorito.fecha.desc())
        ).all()

    def get_favorite(
        self, db: Session, user_id: int, movie_id: int
    ) -> Favorito | None:
        """Busca una relación de favorito concreta para evitar duplicados."""
        return db.scalar(
            select(Favorito).where(
                Favorito.usr_id == user_id,
                Favorito.blog_id == movie_id,
            )
        )

    def add_favorite(self, db: Session, favorite: Favorito) -> None:
        """Añade la relación usuario-película y confirma la transacción."""
        db.add(favorite)
        db.commit()

    def delete_favorite(self, db: Session, favorite: Favorito) -> None:
        """Elimina la relación de favorito y confirma la transacción."""
        db.delete(favorite)
        db.commit()

    def get_review(self, db: Session, review_id: int) -> Comentario | None:
        """Busca una reseña por su clave primaria."""
        return db.get(Comentario, review_id)

    def add_review(self, db: Session, review: Comentario) -> Comentario:
        """Persiste una reseña nueva y recarga sus valores generados."""
        db.add(review)
        db.commit()
        db.refresh(review)
        return review

    def add_report(self, db: Session, report: ReporteResena) -> ReporteResena:
        """Persiste un reporte de reseña y devuelve su estado inicial."""
        db.add(report)
        db.commit()
        db.refresh(report)
        return report

    def update_user(self, db: Session, user: Usuario) -> Usuario:
        """Confirma los cambios de perfil y recarga la cuenta actualizada."""
        db.commit()
        db.refresh(user)
        return user

    def list_user_reviews(self, db: Session, user_id: int):
        """Consulta reseñas propias junto con el título de la película."""
        return db.execute(
            select(Comentario, Blog.titulo)
            .join(Blog, Blog.id_blog == Comentario.blog_id)
            .where(
                Comentario.usr_id == user_id,
                Comentario.calificacion.is_not(None),
                Blog.es_pelicula.is_(True),
            )
            .order_by(Comentario.fecha.desc(), Comentario.id_com.desc())
        ).all()
