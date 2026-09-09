#!/bin/bash

# 1. Verificar dependencias
DEPENDENCIAS=(libreoffice pdftoppm magick)

echo -e "Verificando dependencias del sistema\n"

for herramienta in "${DEPENDENCIAS[@]}"; do
    if ! command -v "$herramienta" &>/dev/null; then
        echo "La herramienta '$herramienta' no está instalada. Se procederá a su instalación"
        sudo apt update
        sudo apt install -y libreoffice poppler-utils imagemagick
        break
    fi
done

# 2. Solicitar el archivo a procesar
echo -n "Introduzca la ruta absoluta del archivo .docx a procesar: "
read INPUT_DOCX

# 3. Validar el archivo
if [[ ! -f "$INPUT_DOCX" || "${INPUT_DOCX##*.}" != "docx" ]]; then
    echo "Ruta inválida o el archivo no tiene extensión .docx"
    exit 1
fi

# 4. Preparar directorio de trabajo
NOMBRE_BASE="$(basename "$INPUT_DOCX" .docx)"
DIRECTORIO_BASE="$(dirname "$INPUT_DOCX")"
WORKDIR="${DIRECTORIO_BASE}/${NOMBRE_BASE}"
mkdir -p "$WORKDIR"

# 5. Convertir .docx a .pdf
echo -e "\nConvirtiendo .docx a .pdf"
libreoffice --headless --convert-to pdf "$INPUT_DOCX" --outdir "$WORKDIR"
PDF_GENERADO="${WORKDIR}/${NOMBRE_BASE}.pdf"

if [ ! -f "$PDF_GENERADO" ]; then
    echo -e "\nNo se ha generado el archivo PDF"
    exit 1
fi

# 6. Convertir .pdf a imágenes .png
echo -e "\nExtrayendo páginas del PDF como imágenes PNG"
pdftoppm "$PDF_GENERADO" "${WORKDIR}/pagina" -png

# 7. Eliminar el PDF intermedio
echo -e "\nEliminando el archivo PDF intermedio"
rm -f "$PDF_GENERADO"

echo -e "\nImágenes generadas en: $WORKDIR"

echo -e "\nPara unir las imágenes en un mural único:\nmagick \$(ls pagina-*.png | sort -V) -append \"\$(basename \"\$PWD\").png\""

exit 0
