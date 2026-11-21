from datetime import date
from pathlib import Path
from textwrap import wrap

from PIL import Image, ImageDraw, ImageFont
from docx import Document
from docx.enum.section import WD_SECTION
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Inches, Pt, RGBColor


ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
ASSETS = DOCS / "assets"
OUTPUT = DOCS / "Reporte_Digital_World_of_Movies.docx"
APP_CAPTURE = ASSETS / "captura_inicio_app.png"

NAVY = "0B2D57"
BLUE = "155FA0"
SKY = "EAF3FB"
INK = "17212B"
MUTED = "536271"
PALE = "F5F8FB"
GRID = "D7E0E8"


def font(size: int, bold: bool = False):
    path = r"C:\Windows\Fonts\arialbd.ttf" if bold else r"C:\Windows\Fonts\arial.ttf"
    return ImageFont.truetype(path, size)


def draw_box(draw, box, title, lines, width=4):
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=18, fill="white", outline=f"#{GRID}", width=width)
    draw.rounded_rectangle((x1, y1, x2, y1 + 58), radius=18, fill=f"#{NAVY}")
    draw.rectangle((x1, y1 + 38, x2, y1 + 58), fill=f"#{NAVY}")
    draw.text((x1 + 18, y1 + 13), title, fill="white", font=font(25, True))
    y = y1 + 78
    for line in lines:
        for item in wrap(line, width=max(18, (x2 - x1 - 38) // 15)):
            draw.text((x1 + 18, y), item, fill=f"#{INK}", font=font(20))
            y += 29
        y += 7


def arrow(draw, points, label=None, label_xy=None):
    draw.line(points, fill=f"#{BLUE}", width=5, joint="curve")
    x2, y2 = points[-1]
    x1, y1 = points[-2]
    if abs(x2 - x1) >= abs(y2 - y1):
        direction = 1 if x2 >= x1 else -1
        head = [(x2, y2), (x2 - direction * 18, y2 - 11), (x2 - direction * 18, y2 + 11)]
    else:
        direction = 1 if y2 >= y1 else -1
        head = [(x2, y2), (x2 - 11, y2 - direction * 18), (x2 + 11, y2 - direction * 18)]
    draw.polygon(head, fill=f"#{BLUE}")
    if label and label_xy:
        draw.text(label_xy, label, fill=f"#{BLUE}", font=font(18, True))


def build_class_diagram(path: Path):
    image = Image.new("RGB", (1800, 830), "white")
    draw = ImageDraw.Draw(image)
    draw.text((60, 34), "Arquitectura por capas y clases principales", fill=f"#{NAVY}", font=font(34, True))
    boxes = [
        (50, 160, 360, 675, "Flutter UI", [
            "MovieUserPage", "HomeTab / SearchTab", "FavoritesTab / ProfileTab", "MovieDetailPage", "AdminDashboardPage",
        ]),
        (405, 160, 715, 675, "ViewModels", [
            "HomeViewModel", "SearchViewModel", "FavoritesViewModel", "ProfileViewModel", "MovieDetailViewModel",
        ]),
        (760, 160, 1070, 675, "Cliente HTTP", [
            "MovieRepository", "UserRepository", "MovieService", "UserService", "AuthService / AdminService",
        ]),
        (1115, 160, 1425, 675, "API FastAPI", [
            "api/routes/user_api.py", "admin_api.py", "content_api.py", "MovieService", "MovieRepository",
        ]),
        (1470, 160, 1750, 675, "MySQL", [
            "usuario", "blog", "comentarios", "favoritos", "reportes_resena",
        ]),
    ]
    for x1, y1, x2, y2, title, lines in boxes:
        draw_box(draw, (x1, y1, x2, y2), title, lines)
    for x in [360, 715, 1070, 1425]:
        arrow(draw, [(x + 4, 412), (x + 38, 412)])
    labels = ["presenta", "coordina", "solicita", "consulta"]
    for i, text in enumerate(labels):
        x = 354 + i * 355
        draw.text((x, 370), text, fill=f"#{MUTED}", font=font(17))
    draw.text((58, 735), "La interfaz delega operaciones a ViewModels y repositorios; FastAPI valida la sesión antes de leer o modificar MySQL.", fill=f"#{MUTED}", font=font(20))
    image.save(path)


def build_er_diagram(path: Path):
    image = Image.new("RGB", (1800, 1110), "white")
    draw = ImageDraw.Draw(image)
    draw.text((60, 34), "Modelo de datos relacional", fill=f"#{NAVY}", font=font(34, True))
    draw_box(draw, (70, 130, 520, 410), "usuario", [
        "PK id_usr", "nom_usr, mail (único)", "pass, dir_usr, tip_usu",
    ])
    draw_box(draw, (1280, 130, 1730, 410), "blog", [
        "PK id_blog", "titulo, desc, img", "tags, fecha_publicacion", "es_pelicula",
    ])
    draw_box(draw, (670, 430, 1130, 735), "comentarios", [
        "PK id_com", "FK usr_id -> usuario", "FK blog_id -> blog", "comentario, calificacion", "fecha, estatus",
    ])
    draw_box(draw, (70, 770, 520, 1035), "favoritos", [
        "PK id_fav", "FK usr_id -> usuario", "FK blog_id -> blog", "fecha", "Único (usr_id, blog_id)",
    ])
    draw_box(draw, (1280, 770, 1730, 1035), "reportes_resena", [
        "PK id_reporte", "FK usr_id -> usuario", "FK id_com -> comentarios", "fecha, estatus", "Único (usr_id, id_com)",
    ])

    arrow(draw, [(520, 290), (610, 290), (610, 515), (670, 515)], "1:N", (548, 455))
    arrow(draw, [(1280, 290), (1190, 290), (1190, 555), (1130, 555)], "1:N", (1178, 455))
    arrow(draw, [(235, 410), (235, 770)], "1:N", (250, 600))
    arrow(draw, [(1500, 410), (1500, 770)], "1:N", (1515, 600))
    arrow(draw, [(520, 610), (600, 610), (600, 870), (1280, 870)], "1:N", (565, 825))
    arrow(draw, [(1130, 665), (1190, 665), (1190, 945), (1280, 945)], "1:N", (1160, 895))
    image.save(path)


def shade(cell, fill):
    tc_pr = cell._tc.get_or_add_tcPr()
    shd = OxmlElement("w:shd")
    shd.set(qn("w:fill"), fill)
    tc_pr.append(shd)


def set_cell_border(cell, color=GRID, size="5"):
    tc = cell._tc
    tc_pr = tc.get_or_add_tcPr()
    borders = tc_pr.first_child_found_in("w:tcBorders")
    if borders is None:
        borders = OxmlElement("w:tcBorders")
        tc_pr.append(borders)
    for edge in ("top", "left", "bottom", "right", "insideH", "insideV"):
        element = borders.find(qn(f"w:{edge}"))
        if element is None:
            element = OxmlElement(f"w:{edge}")
            borders.append(element)
        element.set(qn("w:val"), "single")
        element.set(qn("w:sz"), size)
        element.set(qn("w:color"), color)


def style_table(table, header=True, widths=None):
    table.autofit = False
    for row_index, row in enumerate(table.rows):
        for col_index, cell in enumerate(row.cells):
            cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
            set_cell_border(cell)
            if widths:
                cell.width = Inches(widths[col_index])
            if header and row_index == 0:
                shade(cell, NAVY)
                for paragraph in cell.paragraphs:
                    for run in paragraph.runs:
                        run.font.bold = True
                        run.font.color.rgb = RGBColor(255, 255, 255)
            elif row_index % 2 == 0:
                shade(cell, PALE)


def add_page_number(paragraph):
    paragraph.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    run = paragraph.add_run("Página ")
    run.font.size = Pt(8)
    run.font.color.rgb = RGBColor.from_string(MUTED)
    field = OxmlElement("w:fldSimple")
    field.set(qn("w:instr"), "PAGE")
    paragraph._p.append(field)


def add_hyperlink(paragraph, text, url):
    part = paragraph.part
    relation = part.relate_to(
        url,
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink",
        is_external=True,
    )
    hyperlink = OxmlElement("w:hyperlink")
    hyperlink.set(qn("r:id"), relation)
    run = OxmlElement("w:r")
    props = OxmlElement("w:rPr")
    color = OxmlElement("w:color")
    color.set(qn("w:val"), BLUE)
    props.append(color)
    underline = OxmlElement("w:u")
    underline.set(qn("w:val"), "single")
    props.append(underline)
    run.append(props)
    text_node = OxmlElement("w:t")
    text_node.text = text
    run.append(text_node)
    hyperlink.append(run)
    paragraph._p.append(hyperlink)


def add_code(doc, code):
    p = doc.add_paragraph()
    p.paragraph_format.left_indent = Inches(0.18)
    p.paragraph_format.right_indent = Inches(0.12)
    p.paragraph_format.space_before = Pt(3)
    p.paragraph_format.space_after = Pt(8)
    p.paragraph_format.keep_together = True
    for i, line in enumerate(code.strip("\n").splitlines()):
        if i:
            p.add_run().add_break()
        run = p.add_run(line)
        run.font.name = "Consolas"
        run.font.size = Pt(8.5)
        run.font.color.rgb = RGBColor.from_string(NAVY)
    p_pr = p._p.get_or_add_pPr()
    shd = OxmlElement("w:shd")
    shd.set(qn("w:fill"), "F1F5F8")
    p_pr.append(shd)
    return p


def add_picture(doc, path, width, alt_text):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run()
    inline = run.add_picture(str(path), width=Inches(width))
    inline._inline.docPr.set("descr", alt_text)
    p.paragraph_format.space_after = Pt(3)
    return p


def add_caption(doc, text):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(8)
    run = p.add_run(text)
    run.italic = True
    run.font.size = Pt(9)
    run.font.color.rgb = RGBColor.from_string(MUTED)


def configure_styles(doc):
    section = doc.sections[0]
    section.page_width = Inches(8.5)
    section.page_height = Inches(11)
    section.top_margin = Inches(0.68)
    section.bottom_margin = Inches(0.68)
    section.left_margin = Inches(0.78)
    section.right_margin = Inches(0.78)

    normal = doc.styles["Normal"]
    normal.font.name = "Arial"
    normal.font.size = Pt(10)
    normal.font.color.rgb = RGBColor.from_string(INK)
    normal.paragraph_format.space_after = Pt(6)
    normal.paragraph_format.line_spacing = 1.08
    for name, size in (("Title", 28), ("Heading 1", 19), ("Heading 2", 13)):
        style = doc.styles[name]
        style.font.name = "Arial"
        style.font.size = Pt(size)
        style.font.bold = True
        style.font.color.rgb = RGBColor.from_string("000000")
        style.paragraph_format.keep_with_next = True
        style.paragraph_format.space_before = Pt(10 if name != "Title" else 0)
        style.paragraph_format.space_after = Pt(7)

    header = section.header.paragraphs[0]
    header.text = "WORLD OF MOVIES  |  EVALUACIÓN UNIDAD 3"
    header.style = doc.styles["Normal"]
    header.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    for run in header.runs:
        run.font.size = Pt(8)
        run.font.bold = True
        run.font.color.rgb = RGBColor.from_string(MUTED)
    add_page_number(section.footer.paragraphs[0])


def paragraph(doc, text, bold_prefix=None):
    p = doc.add_paragraph()
    if bold_prefix and text.startswith(bold_prefix):
        p.add_run(bold_prefix).bold = True
        p.add_run(text[len(bold_prefix):])
    else:
        p.add_run(text)
    return p


def build_report():
    ASSETS.mkdir(parents=True, exist_ok=True)
    class_image = ASSETS / "diagrama_clases_capas.png"
    er_image = ASSETS / "modelo_datos.png"
    build_class_diagram(class_image)
    build_er_diagram(er_image)

    doc = Document()
    configure_styles(doc)

    # Portada
    for _ in range(3):
        doc.add_paragraph()
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run("EVALUACIÓN UNIDAD 3")
    run.font.size = Pt(13)
    run.font.bold = True
    run.font.color.rgb = RGBColor.from_string(BLUE)

    p = doc.add_paragraph(style="Title")
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.add_run("Reporte digital del proyecto\nWorld of Movies")

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run("Aplicación Flutter, API FastAPI y base de datos MySQL")
    r.font.size = Pt(14)
    r.font.color.rgb = RGBColor.from_string(MUTED)

    doc.add_paragraph()
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run("Actividad para alcanzar 30 Puntos")
    r.bold = True
    r.font.size = Pt(15)
    r.font.color.rgb = RGBColor.from_string(NAVY)

    doc.add_paragraph()
    meta = doc.add_table(rows=4, cols=2)
    meta.style = "Table Grid"
    labels = ["Estudiante(s)", "Docente", "Grupo", "Fecha"]
    values = ["________________________________", "________________________________", "________________________________", "20 de noviembre de 2026"]
    for i, (label, value) in enumerate(zip(labels, values)):
        meta.cell(i, 0).text = label
        meta.cell(i, 1).text = value
        shade(meta.cell(i, 0), SKY)
        for run in meta.cell(i, 0).paragraphs[0].runs:
            run.bold = True
    style_table(meta, header=False, widths=[1.55, 4.75])
    doc.add_paragraph()
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_hyperlink(p, "Repositorio público en GitHub", "https://github.com/Edgxxxxxxr/Blog_proyecto")

    doc.add_page_break()

    # 1. Propósito y alcance
    doc.add_heading("1. Propósito y alcance", level=1)
    paragraph(doc, "Este reporte describe la solución World of Movies desarrollada para ampliar el proyecto base de blog. La app Flutter consulta una API FastAPI, que valida las solicitudes y lee o modifica los registros en MySQL. La solución integra las funciones del panel administrativo con las vistas de usuario.")
    paragraph(doc, "El alcance documentado incluye registro e inicio de sesión, catálogo y búsqueda de películas, detalle, favoritos, reseñas con puntuación, perfil y reporte de reseñas; desde administración se gestionan cuentas y películas, y se revisan reseñas y reportes. La base conserva las tablas legado usuario, blog y comentarios para no romper la API existente.")
    paragraph(doc, "La demostración prevista se ejecuta de forma local con Flutter en Chrome, FastAPI en el puerto 8000 y MySQL. La app consume la API desde http://127.0.0.1:8000; por tanto, ambas partes deben estar disponibles durante la presentación.")

    doc.add_heading("Arquitectura y clases", level=2)
    paragraph(doc, "Las pantallas muestran el estado y envían acciones a ViewModels. Repositories mantienen una interfaz de acceso a datos y los Services realizan las solicitudes HTTP. En el servidor, las rutas autentican y validan la entrada, el servicio aplica reglas de negocio, el repositorio consulta SQLAlchemy y los modelos ORM representan las tablas MySQL.")
    add_picture(doc, class_image, 6.85, "Diagrama de clases principales organizadas por capa desde Flutter hasta MySQL.")
    add_caption(doc, "Figura 1. Clases y flujo de dependencias del cliente y el backend.")

    doc.add_heading("Componentes principales", level=2)
    t = doc.add_table(rows=1, cols=3)
    for j, title in enumerate(["Capa", "Clases o módulos", "Responsabilidad"]):
        t.cell(0, j).text = title
    rows = [
        ("Flutter", "MovieUserPage, HomeTab, SearchTab, FavoritesTab, ProfileTab, MovieDetailPage", "Presentar las vistas y navegar entre sus secciones."),
        ("Estado", "HomeViewModel, SearchViewModel, FavoritesViewModel, ProfileViewModel, MovieDetailViewModel", "Cargar información, aplicar validaciones y coordinar acciones."),
        ("Datos cliente", "MovieRepository, UserRepository, MovieService, UserService, AuthService", "Enviar peticiones HTTP y convertir las respuestas a modelos Flutter."),
        ("API", "api/routes, MovieService, MovieRepository", "Validar sesión y rol; aplicar reglas y consultar la base."),
        ("Persistencia", "Usuario, Blog, Comentario, Favorito, ReporteResena", "Representar entidades y relaciones del esquema MySQL."),
    ]
    for row in rows:
        cells = t.add_row().cells
        for j, value in enumerate(row):
            cells[j].text = value
    style_table(t, widths=[1.15, 3.15, 2.1])

    doc.add_page_break()

    # 2. Modelo de datos
    doc.add_heading("2. Modelo de datos", level=1)
    paragraph(doc, "El esquema parte de usuario, blog y comentarios, y agrega favoritos y reportes_resena. La columna blog.es_pelicula distingue las películas que se presentan en el catálogo sin duplicar el contenido que ya administra el panel. Una reseña se almacena como un comentario con calificacion; el valor puede ser nulo para comentarios antiguos.")
    add_picture(doc, er_image, 6.9, "Diagrama entidad-relación de usuario, blog, comentarios, favoritos y reportes de reseña.")
    add_caption(doc, "Figura 2. Entidades, claves primarias, foráneas y cardinalidades.")

    t = doc.add_table(rows=1, cols=3)
    for j, title in enumerate(["Tabla", "Datos clave", "Relaciones y reglas"]):
        t.cell(0, j).text = title
    rows = [
        ("usuario", "id_usr, nom_usr, mail, pass, dir_usr, tip_usu", "mail es único; rol 1 identifica administración y rol 2 usuario."),
        ("blog", "id_blog, titulo, desc, img, fecha_publicacion, es_pelicula", "Registro compartido para contenido y películas."),
        ("comentarios", "id_com, usr_id, blog_id, comentario, calificacion, estatus", "FK a usuario y blog; puntuación de 1 a 5 cuando existe."),
        ("favoritos", "id_fav, usr_id, blog_id, fecha", "FK a usuario y blog; combinación usuario-película única."),
        ("reportes_resena", "id_reporte, usr_id, id_com, fecha, estatus", "FK a usuario y comentario; el mismo usuario reporta una reseña una vez."),
    ]
    for row in rows:
        cells = t.add_row().cells
        for j, value in enumerate(row):
            cells[j].text = value
    style_table(t, widths=[1.2, 2.75, 2.45])
    paragraph(doc, "Los scripts SQL están en backend_API/migrations. 000_base_schema.sql crea solo la estructura vacía y 001_user_features.sql agrega las funciones de usuario. Los scripts no contienen filas de personas ni contraseñas.", bold_prefix="Los scripts SQL están en backend_API/migrations.")

    doc.add_page_break()

    # 3. Requisitos y acceso a datos
    doc.add_heading("3. Requisitos funcionales y acceso a datos", level=1)
    paragraph(doc, "La siguiente matriz relaciona los requisitos principales del caso con las funciones incluidas en el proyecto.")
    t = doc.add_table(rows=1, cols=3)
    for j, title in enumerate(["Requisito", "Implementación", "Módulo"]):
        t.cell(0, j).text = title
    rows = [
        ("Autenticación y sesión", "Registro e inicio de sesión validan correo y contraseña; la API responde con token Bearer.", "AuthService; rutas de contenido y seguridad."),
        ("Consulta del contenido", "La app obtiene el catálogo, busca por título y carga el detalle de la película.", "MovieService Flutter; user_api y MovieService FastAPI."),
        ("Interacción de usuario", "Agrega favoritos, publica calificaciones y comentarios, consulta sus reseñas y actualiza su perfil.", "ViewModels y MovieRepository/UserRepository."),
        ("Moderación", "Envía reportes de reseña a una bandeja administrativa y permite atenderlos o descartarlos.", "reportes_resena; AdminDashboardPage y admin_api."),
        ("Persistencia", "Las operaciones escriben y consultan registros MySQL mediante SQLAlchemy.", "domain/models.py y repositories."),
    ]
    for row in rows:
        cells = t.add_row().cells
        for j, value in enumerate(row):
            cells[j].text = value
    style_table(t, widths=[1.3, 3.25, 1.85])

    doc.add_heading("Ruta de una consulta del catálogo", level=2)
    paragraph(doc, "La pantalla solicita películas a través del servicio HTTP y adjunta el token de sesión. FastAPI valida ese token, delega la operación al servicio de dominio, y el repositorio consulta únicamente registros marcados como película. El servicio completa promedio, cantidad de reseñas y estado de favorito antes de devolver el JSON.")
    add_code(doc, """Flutter - movie_service.dart
final response = await http.get(
  Uri.parse('$_baseUrl/peliculas'),
  headers: _headers(token),
);""")
    add_code(doc, """FastAPI - api/routes/user_api.py
@router.get('/peliculas', response_model=list[PeliculaUsuarioRespuesta])
def listar_peliculas(q=Query(default=None), db=Depends(obtener_sesion),
                     usuario=Depends(obtener_usuario_actual)):
    return movie_service.list_movies(db, usuario, q)""")
    add_code(doc, """Backend - repositories/movie_repository.py
statement = select(Blog).where(Blog.es_pelicula.is_(True))
if query:
    statement = statement.where(Blog.titulo.ilike(f'%{query}%'))""")

    doc.add_heading("Prueba visible en la app", level=2)
    paragraph(doc, "La captura compartida es parcial: muestra una parte de la tarjeta de una película y la navegación inferior. El código anterior documenta el recorrido entre Flutter, FastAPI y MySQL; agrega en tu entrega final una captura completa donde se vea el catálogo cargado.")
    if APP_CAPTURE.exists():
        add_picture(doc, APP_CAPTURE, 6.85, "Captura parcial compartida: tarjeta de película con cartel y duración junto a la navegación inferior.")
        add_caption(doc, "Figura 3. Vista de inicio con información de película y navegación del usuario.")
    else:
        paragraph(doc, "Inserta aquí una captura de la app en Inicio donde se vea una película cargada desde la API.")

    doc.add_page_break()

    # 4. Seguridad, recursos y reflexión
    doc.add_heading("4. Seguridad, recursos y librerías", level=1)
    t = doc.add_table(rows=1, cols=2)
    t.cell(0, 0).text = "Mecanismo"
    t.cell(0, 1).text = "Uso en el proyecto"
    rows = [
        ("Hash de contraseña", "bcrypt almacena contraseñas como hash. Se verifican formatos bcrypt heredados y los hashes Argon2 antiguos se actualizan a bcrypt al autenticar."),
        ("Sesión de API", "Token Bearer con firma HMAC-SHA256, identificador de usuario y expiración de ocho horas."),
        ("Control de acceso", "Los endpoints administrativos verifican el rol; el registro público asigna rol de usuario desde el servidor."),
        ("Integridad", "Claves foráneas, correo único, favorito único por cuenta y reporte único por cuenta/reseña."),
        ("Configuración", "DB_PASSWORD y API_SECRET_KEY se leen desde backend_API/.env. El archivo se excluye de Git."),
    ]
    for row in rows:
        cells = t.add_row().cells
        cells[0].text, cells[1].text = row
    style_table(t, widths=[1.55, 4.85])

    doc.add_heading("Recursos multimedia y bibliotecas", level=2)
    t = doc.add_table(rows=1, cols=3)
    for j, title in enumerate(["Recurso", "Uso", "Dónde se declara"]):
        t.cell(0, j).text = title
    rows = [
        ("Carteles e imágenes", "Se muestran desde una URL o desde /uploads de FastAPI; administración puede cargar imágenes.", "movie_poster.dart, post_service.dart, admin_service.dart"),
        ("image_picker", "Selecciona una imagen de la galería para adjuntarla a una publicación.", "flutter_application_3/pubspec.yaml"),
        ("http", "Envía solicitudes JSON y multipart al backend.", "flutter_application_3/pubspec.yaml"),
        ("Material y Cupertino Icons", "Controles visuales, formularios, navegación e iconos.", "Flutter SDK y cupertino_icons"),
        ("FastAPI / SQLAlchemy / PyMySQL", "Rutas HTTP, validación de esquemas y acceso MySQL.", "backend_API/requirements.txt"),
        ("bcrypt / pwdlib", "Hashes de contraseña actuales y verificación de formatos anteriores.", "backend_API/requirements.txt"),
    ]
    for row in rows:
        cells = t.add_row().cells
        for j, value in enumerate(row):
            cells[j].text = value
    style_table(t, widths=[1.7, 3.0, 1.7])
    paragraph(doc, "La app no necesita GPS ni otros sensores para el flujo actual. image_picker se usa para elegir una imagen existente; la aplicación no utiliza ubicación para consultar o mostrar películas.")

    doc.add_page_break()
    doc.add_heading("5. Reflexión del proceso", level=1)
    paragraph(doc, "Al integrar las funciones de usuario con una API que ya atendía administración, fue necesario conservar las tablas y los nombres de columnas existentes. La separación entre pantallas, ViewModels, repositorios, servicios y rutas facilita ubicar cada cambio y reduce el acoplamiento entre interfaz y base de datos.")
    paragraph(doc, "El modelo reutiliza comentarios para representar reseñas y mantiene las películas en blog, mientras favoritos y reportes tienen tablas propias con restricciones de integridad. Esta decisión mantiene compatibilidad con el panel y permite que las operaciones del usuario se persistan en las mismas tablas que consulta la administración.")
    paragraph(doc, "Para entregar el proyecto, se añadieron scripts SQL sin datos personales, instrucciones de instalación y un guion para la demostración. La presentación local debe mostrar el recorrido completo de una operación y su resultado en la vista administrativa; el video se grabará aparte siguiendo el guion incluido en docs.")

    doc.add_heading("Archivos de entrega", level=2)
    p = doc.add_paragraph()
    p.add_run("Repositorio: ")
    add_hyperlink(p, "github.com/Edgxxxxxxr/Blog_proyecto", "https://github.com/Edgxxxxxxr/Blog_proyecto")
    paragraph(doc, "Modelo de datos y migraciones: backend_API/migrations/000_base_schema.sql y 001_user_features.sql.")
    paragraph(doc, "Instrucciones de instalación y uso: README.md en la raíz del repositorio.")
    paragraph(doc, "Demostración en video: guion de recorrido en docs/guion_video_demo.md.")

    doc.core_properties.title = "Reporte digital del proyecto World of Movies"
    doc.core_properties.subject = "Evaluación Unidad 3: Flutter, FastAPI y MySQL"
    doc.core_properties.author = "Equipo World of Movies"
    doc.save(OUTPUT)
    print(OUTPUT)


if __name__ == "__main__":
    build_report()
