
import os

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL
from sqlalchemy.orm import sessionmaker, DeclarativeBase

load_dotenv()

# Configuración de MySQL
url = URL.create(
    drivername="mysql+pymysql",
    username=os.getenv("DB_USER", "root"),
    password=os.getenv("DB_PASSWORD", "EdgarCastillejo3607"),
    host=os.getenv("DB_HOST", "localhost"),
    port=int(os.getenv("DB_PORT", "3306")),
    database=os.getenv("DB_NAME", "blog_db"),
    query={"charset": "utf8mb4"},
)

# Motor de conexión
engine = create_engine(
    url,
    pool_pre_ping=True
)

SessionLocal = sessionmaker(
    bind=engine,
    autocommit=False,
    autoflush=False
)

class Base(DeclarativeBase):
    pass

# Obtener conexión a la base de datos
def obtener_sesion():
    db = SessionLocal()

    try:
        yield db
    finally:
        db.close()
