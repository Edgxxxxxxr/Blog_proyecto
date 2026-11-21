from io import BytesIO
from pathlib import Path
from xml.etree import ElementTree as ET
from docx import Document
from docx.text.paragraph import Paragraph
from docx.table import Table as DocxTable
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import SimpleDocTemplate, Paragraph as P, Spacer, Image as RImage, Table, TableStyle, PageBreak, KeepTogether
from docx.oxml.ns import qn

ROOT=Path(__file__).resolve().parents[1]
DOCX=ROOT/'docs'/'Reporte_Digital_World_of_Movies.docx'
PDF=ROOT/'docs'/'Reporte_Digital_World_of_Movies.pdf'
NAVY=colors.HexColor('#0B2D57'); BLUE=colors.HexColor('#155FA0'); PALE=colors.HexColor('#F2F6FA'); GRID=colors.HexColor('#D7E0E8'); INK=colors.HexColor('#17212B')
font_dir=Path(r'C:\Windows\Fonts')
for name,file in [('Arial', 'arial.ttf'),('Arial-Bold','arialbd.ttf'),('Arial-Italic','ariali.ttf'),('Arial-BoldItalic','arialbi.ttf')]:
    path=font_dir/file
    if path.exists(): pdfmetrics.registerFont(TTFont(name,str(path)))
base='Arial' if 'Arial' in pdfmetrics.getRegisteredFontNames() else 'Helvetica'
bold='Arial-Bold' if 'Arial-Bold' in pdfmetrics.getRegisteredFontNames() else 'Helvetica-Bold'
styles=getSampleStyleSheet()
styles.add(ParagraphStyle(name='BodyEs',parent=styles['BodyText'],fontName=base,fontSize=9.2,leading=13.2,textColor=INK,spaceAfter=6))
styles.add(ParagraphStyle(name='TitleEs',parent=styles['Title'],fontName=bold,fontSize=25,leading=30,textColor=NAVY,alignment=TA_CENTER,spaceAfter=14))
styles.add(ParagraphStyle(name='H1Es',parent=styles['Heading1'],fontName=bold,fontSize=16,leading=20,textColor=NAVY,spaceBefore=8,spaceAfter=8,keepWithNext=True))
styles.add(ParagraphStyle(name='H2Es',parent=styles['Heading2'],fontName=bold,fontSize=11.5,leading=15,textColor=BLUE,spaceBefore=7,spaceAfter=5,keepWithNext=True))
styles.add(ParagraphStyle(name='CoverEs',parent=styles['BodyText'],fontName=base,fontSize=12,leading=18,textColor=INK,alignment=TA_CENTER,spaceAfter=9))
styles.add(ParagraphStyle(name='CodeEs',parent=styles['Code'],fontName='Courier',fontSize=7.6,leading=10,textColor=INK,backColor=PALE,borderColor=GRID,borderWidth=.5,borderPadding=7,spaceBefore=3,spaceAfter=8))
styles.add(ParagraphStyle(name='CaptionEs',parent=styles['BodyText'],fontName=base,fontSize=8,leading=10,textColor=colors.HexColor('#536271'),alignment=TA_CENTER,spaceAfter=7))
styles.add(ParagraphStyle(name='CellEs',parent=styles['BodyText'],fontName=base,fontSize=7.1,leading=9,textColor=INK,spaceAfter=0))
styles.add(ParagraphStyle(name='CellHeadEs',parent=styles['BodyText'],fontName=bold,fontSize=7.3,leading=9,textColor=colors.white,spaceAfter=0))

def esc(s):
    return (s or '').replace('&','&amp;').replace('<','&lt;').replace('>','&gt;').replace('\n','<br/>')
def page_cb(canvas, doc):
    canvas.saveState(); w,h=letter
    canvas.setStrokeColor(GRID); canvas.setLineWidth(.5); canvas.line(.72*inch,.58*inch,w-.72*inch,.58*inch)
    canvas.setFont(base,8); canvas.setFillColor(colors.HexColor('#536271'))
    canvas.drawString(.74*inch,.4*inch,'World of Movies | Reporte digital')
    canvas.drawRightString(w-.74*inch,.4*inch,f'P\u00e1gina {doc.page}')
    canvas.restoreState()

def cell_text(cell): return '\n'.join(p.text for p in cell.paragraphs).strip()
def image_from_para(para):
    blip=para._p.xpath('.//a:blip')
    if not blip: return None
    rid=blip[0].get(qn('r:embed'))
    part=para.part.related_parts.get(rid)
    return part.blob if part else None

doc=Document(DOCX); story=[]
body=doc.element.body
for child in body.iterchildren():
    if child.tag.endswith('}p'):
        p=Paragraph(child,doc)
        blob=image_from_para(p)
        if blob:
            img=RImage(BytesIO(blob),width=6.85*inch,height=4.2*inch,kind='proportional',lazy=2)
            img._restrictSize(6.85*inch,4.2*inch); story += [Spacer(1,4),img,Spacer(1,4)]
        text=p.text.strip()
        has_page_break=bool(p._p.xpath('.//w:br[@w:type="page"]'))
        if text:
            style=p.style.name if p.style else 'Normal'
            if style=='Title': story.append(P(esc(text),styles['TitleEs']))
            elif style.startswith('Heading 1'): story.append(P(esc(text),styles['H1Es']))
            elif style.startswith('Heading 2'): story.append(P(esc(text),styles['H2Es']))
            elif text.startswith('Figura '): story.append(P(esc(text),styles['CaptionEs']))
            elif text.startswith(('Flutter -','FastAPI -','Backend -')):
                story.append(P('<font name="Courier">'+esc(text)+'</font>',styles['CodeEs']))
            elif text=='EVALUACIÓN UNIDAD 3': story.append(Spacer(1,35)); story.append(P(esc(text),ParagraphStyle('top',parent=styles['CoverEs'],fontName=bold,fontSize=13,textColor=BLUE)))
            elif text.startswith(('Aplicación Flutter,','Actividad para alcanzar','Repositorio público')):
                story.append(P(esc(text),ParagraphStyle('coverline',parent=styles['CoverEs'],fontName=bold if text.startswith('Actividad') else base,fontSize=12 if text.startswith('Actividad') else 11,textColor=BLUE if text.startswith('Actividad') else INK)))
            else: story.append(P(esc(text),styles['BodyEs']))
        if has_page_break: story.append(PageBreak())
    elif child.tag.endswith('}tbl'):
        t=DocxTable(child,doc)
        data=[]
        for ri,row in enumerate(t.rows):
            data.append([P(esc(cell_text(c)),styles['CellHeadEs'] if ri==0 else styles['CellEs']) for c in row.cells])
        widths={2:[1.15*inch,2.5*inch,2.95*inch],3:[1.25*inch,2.8*inch,2.55*inch],4:[1.35*inch,3.25*inch,2*inch],5:[1.4*inch,4.0*inch,1.2*inch],6:[1.55*inch,3.2*inch,1.85*inch]}
        tbl=Table(data,colWidths=widths.get(len(data[0]),None),repeatRows=1,splitByRow=1,hAlign='LEFT')
        commands=[('VALIGN',(0,0),(-1,-1),'TOP'),('GRID',(0,0),(-1,-1),.45,GRID),('LEFTPADDING',(0,0),(-1,-1),5),('RIGHTPADDING',(0,0),(-1,-1),5),('TOPPADDING',(0,0),(-1,-1),5),('BOTTOMPADDING',(0,0),(-1,-1),5),('BACKGROUND',(0,0),(-1,0),NAVY)]
        for ri in range(1,len(data)):
            if ri%2==0: commands.append(('BACKGROUND',(0,ri),(-1,ri),PALE))
        tbl.setStyle(TableStyle(commands)); story += [tbl,Spacer(1,7)]

docpdf=SimpleDocTemplate(str(PDF),pagesize=letter,rightMargin=.72*inch,leftMargin=.72*inch,topMargin=.72*inch,bottomMargin=.78*inch,title='Reporte Digital World of Movies',author='Equipo del proyecto')
docpdf.build(story,onFirstPage=page_cb,onLaterPages=page_cb)
print(PDF)

