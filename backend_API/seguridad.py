
import bcrypt
from pwdlib import PasswordHash

# Para reconocer cuentas antiguas de FastAPI
argon2 = PasswordHash.recommended()


def crear_hash(password: str) -> str:
    clave = password.encode("utf-8")

    if len(clave) > 72:
        raise ValueError(
            "La contraseña no puede superar 72 bytes."
        )

    hash_generado = bcrypt.hashpw(
        clave,
        bcrypt.gensalt(rounds=12)
    ).decode("utf-8")

    # Prefijo utilizado por PHP con PASSWORD_BCRYPT
    return "$2y$" + hash_generado[4:]


def verificar_password(password: str, hash_guardado: str) -> bool:
    if not hash_guardado:
        return False

    # Contraseñas creadas desde PHP o bcrypt
    if hash_guardado.startswith(("$2y$", "$2b$", "$2a$")):
        try:
            return bcrypt.checkpw(
                password.encode("utf-8"),
                hash_guardado.encode("utf-8")
            )
        except (ValueError, TypeError):
            return False

    # Contraseñas antiguas creadas en FastAPI
    if hash_guardado.startswith("$argon2"):
        try:
            return argon2.verify(
                password,
                hash_guardado
            )
        except Exception:
            return False

    return False


def necesita_migracion(hash_guardado: str) -> bool:
    return hash_guardado.startswith("$argon2")
