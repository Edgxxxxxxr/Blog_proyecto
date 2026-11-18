
from sqlalchemy import (
    Column,
    Integer,
    String,
    DateTime,
    ForeignKey,
    func
)

from database import Base


# TABLA USUARIO
class Usuario(Base):
    __tablename__ = "usuario"

    id_usr = Column(
        Integer,
        primary_key=True,
        index=True
    )

    nom_usr = Column(String(100), nullable=False)

    mail = Column(
        String(150),
        unique=True,
        nullable=False
    )

    # En MySQL la columna se llama "pass"
    pass_hash = Column(
        "pass",
        String(255),
        nullable=False
    )

    dir_usr = Column(String(255), nullable=True)

    tip_usu = Column(
        Integer,
        nullable=False,
        default=1
    )


# TABLA BLOG
class Blog(Base):
    __tablename__ = "blog"

    id_blog = Column(
        Integer,
        primary_key=True,
        index=True
    )

    titulo = Column(String(200), nullable=False)

    # En MySQL la columna se llama "desc"
    descripcion = Column(
        "desc",
        String(500),
        nullable=True
    )

    img = Column(String(255), nullable=True)

    tags = Column(String(255), nullable=True)

    fecha_publicacion = Column(
        DateTime,
        server_default=func.current_timestamp()
    )


# TABLA COMENTARIOS
class Comentario(Base):
    __tablename__ = "comentarios"
    
    id_com = Column(Integer, primary_key=True, index=True, autoincrement=True)
    comentario = Column(String(500), nullable=False)
    fecha = Column(DateTime, nullable=False)
    estatus = Column(Integer, nullable=False, default=1)
    calificacion = Column(Integer, nullable=True)

    usr_id = Column(Integer, ForeignKey("usuario.id_usr"), nullable=False)
    blog_id = Column(Integer, ForeignKey("blog.id_blog"), nullable=False)

    id_com = Column(
        Integer,
        primary_key=True,
        index=True
    )

    comentario = Column(
        String(500),
        nullable=False
    )

    fecha = Column(
        DateTime,
        nullable=False,
        server_default=func.current_timestamp()
    )

    estatus = Column(
        Integer,
        nullable=False,
        default=1
    )

    usr_id = Column(
        Integer,
        ForeignKey("usuario.id_usr"),
        nullable=False
    )

    blog_id = Column(
        Integer,
        ForeignKey("blog.id_blog"),
        nullable=False
    )
