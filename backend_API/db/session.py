"""Configura SQLAlchemy, carga las variables de entorno y proporciona sesiones por solicitud.
Esta capa crea conexiones y controla la vida de cada sesión SQLAlchemy."""


import os
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL
from sqlalchemy.orm import sessionmaker, DeclarativeBase

# La configuración se carga desde esta carpeta, independientemente
# del directorio desde el que se inicie uvicorn.
load_dotenv(Path(__file__).resolve().parents[1] / ".env")

password = os.getenv("DB_PASSWORD")
if password is None:
    raise RuntimeError(
        "Falta DB_PASSWORD. Crea backend_API/.env usando .env.example."
    )

# Esta API utiliza blog_db, la base incluida en el respaldo recibido.
url = URL.create(
    drivername="mysql+pymysql",
    username=os.getenv("DB_USER", "root"),
    password=password,
    host=os.getenv("DB_HOST", "localhost"),
    port=int(os.getenv("DB_PORT", "3306")),
    database=os.getenv("DB_NAME", "blog_db"),
    query={"charset": "utf8mb4"},
)

# pool_pre_ping detecta conexiones MySQL que dejaron de responder.
engine = create_engine(url, pool_pre_ping=True)

SessionLocal = sessionmaker(
    bind=engine,
    autocommit=False,
    autoflush=False
)

class Base(DeclarativeBase):
    """Declara la clase base de los modelos ORM de SQLAlchemy."""
    pass

# Obtener conexión a la base de datos
def obtener_sesion():
    """Abre una sesión de base de datos para la solicitud y la cierra al terminar."""
    db = SessionLocal()

    try:
        yield db
    finally:
        db.close()
