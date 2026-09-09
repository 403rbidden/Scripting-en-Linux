#!/bin/bash

# Descripción: 
# Convierte un archivo .docx en una única imagen vertical (.png),
# consolidando todas las páginas como mural de evidencia técnica.

set -e

DEPENDENCIAS=(libreoffice pdftoppm magick)

echo "Verificando dependencias del sistema"

for herramienta in "${DEPENDENCIAS[@]}"; do
    if ! command -v "$herramienta" &>/dev/null; then
        echo "La herramienta '$herramienta' no está instalada. Se procederá a su instalación"
        sudo apt update
        sudo apt install -y libreoffice poppler-utils imagemagick
        break
    fi
done

echo -n "Introduzca la ruta absoluta del archivo .docx a procesar: "
read INPUT_DOCX

if [[ ! -f "$INPUT_DOCX" || "${INPUT_DOCX##*.}" != "docx" ]]; then
    echo "Ruta inválida o el archivo no tiene extensión .docx"
    exit 1
fi

NOMBRE_BASE="$(basename "$INPUT_DOCX" .docx)"
DIRECTORIO_BASE="$(dirname "$INPUT_DOCX")"
WORKDIR="${DIRECTORIO_BASE}/${NOMBRE_BASE}_temp"
mkdir -p "$WORKDIR"

echo "Convirtiendo .docx a .pdf"
libreoffice --headless --convert-to pdf "$INPUT_DOCX" --outdir "$WORKDIR"
PDF_GENERADO="${WORKDIR}/${NOMBRE_BASE}.pdf"

if [ ! -f "$PDF_GENERADO" ]; then
    echo "No se ha generado el archivo PDF"
    exit 1
fi

echo "Extrayendo páginas del PDF como imágenes PNG"
pdftoppm "$PDF_GENERADO" "${WORKDIR}/pagina" -png

echo "Generando imagen mural vertical"
mapfile -t IMAGENES_ORDENADAS < <(find "$WORKDIR" -type f -name 'pagina-*.png' | sort -V)

IMAGEN_FINAL="${DIRECTORIO_BASE}/${NOMBRE_BASE}.png"
magick "${IMAGENES_ORDENADAS[@]}" -append "$IMAGEN_FINAL"

if [ -f "$IMAGEN_FINAL" ]; then
    echo "Imagen generada correctamente: $IMAGEN_FINAL"
else
    echo "Error al generar la imagen de evidencia"
    exit 1
fi

#echo "Eliminando archivos temporales"
#rm -rf "$WORKDIR"

exit 0
