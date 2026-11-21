"""Define las entidades ORM que representan usuarios, publicaciones, comentarios y funciones de usuario.
Esta capa define entidades persistentes y contratos de entrada y salida."""


from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    ForeignKey,
    Integer,
    String,
    UniqueConstraint,
    func,
    text,
)

from db.session import Base


class Usuario(Base):
    """Cuenta ya existente; conserva sus nombres de columnas del dump."""

    __tablename__ = "usuario"

    id_usr = Column(Integer, primary_key=True, index=True)
    nom_usr = Column(String(100), nullable=False)
    mail = Column(String(150), unique=True, nullable=False)
    pass_hash = Column("pass", String(255), nullable=False)
    dir_usr = Column(String(255), nullable=True)
    tip_usu = Column(Integer, nullable=False, default=2)


class Blog(Base):
    """Catálogo compartido con administración para no duplicar películas."""

    __tablename__ = "blog"

    id_blog = Column(Integer, primary_key=True, index=True)
    titulo = Column(String(200), nullable=False)
    descripcion = Column("desc", String(500), nullable=True)
    img = Column(String(255), nullable=True)
    tags = Column(String(255), nullable=True)
    fecha_publicacion = Column(
        DateTime,
        server_default=func.current_timestamp(),
    )
    # La migración distingue películas de publicaciones antiguas del blog.
    es_pelicula = Column(
        Boolean,
        nullable=False,
        default=False,
        server_default=text("0"),
    )


class Comentario(Base):
    """Los comentarios con calificacion se presentan como reseñas."""

    __tablename__ = "comentarios"

    id_com = Column(Integer, primary_key=True, index=True, autoincrement=True)
    comentario = Column(String(500), nullable=False)
    fecha = Column(
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
    )
    estatus = Column(Integer, nullable=False, default=1)
    usr_id = Column(Integer, ForeignKey("usuario.id_usr"), nullable=False)
    blog_id = Column(Integer, ForeignKey("blog.id_blog"), nullable=False)
    calificacion = Column(Integer, nullable=True)


class Favorito(Base):
    """Relación persistente entre un usuario y una película del catálogo."""

    __tablename__ = "favoritos"
    __table_args__ = (
        UniqueConstraint(
            "usr_id",
            "blog_id",
            name="uq_favorito_usuario_pelicula",
        ),
    )

    id_fav = Column(Integer, primary_key=True, index=True)
    usr_id = Column(
        Integer,
        ForeignKey("usuario.id_usr", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    blog_id = Column(
        Integer,
        ForeignKey("blog.id_blog", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    fecha = Column(DateTime, nullable=False, server_default=func.current_timestamp())


class ReporteResena(Base):
    """Registro de reportes enviados por usuarios sobre una reseña."""

    __tablename__ = "reportes_resena"
    __table_args__ = (
        UniqueConstraint(
            "usr_id",
            "id_com",
            name="uq_reporte_usuario_resena",
        ),
    )

    id_reporte = Column(Integer, primary_key=True, index=True)
    usr_id = Column(
        Integer,
        ForeignKey("usuario.id_usr", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    id_com = Column(
        Integer,
        ForeignKey("comentarios.id_com", ondelete="CASCADE", onupdate="CASCADE"),
        nullable=False,
    )
    fecha = Column(DateTime, nullable=False, server_default=func.current_timestamp())
    estatus = Column(String(20), nullable=False, default="pendiente")
