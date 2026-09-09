#!/bin/bash

# 1. Verificar dependencias
DEPENDENCIAS=(libreoffice pdftoppm pdfinfo)

echo -e "Verificando dependencias del sistema\n"

for herramienta in "${DEPENDENCIAS[@]}"; do
    if ! command -v "$herramienta" &>/dev/null; then
        echo "La herramienta '$herramienta' no está instalada. Se procederá a su instalación"
        sudo apt update
        sudo apt install -y libreoffice poppler-utils
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

# 6. Detectar tamaño del PDF en puntos
echo -e "\nDetectando tamaño original del PDF"
PAGE_SIZE_PT=$(pdfinfo "$PDF_GENERADO" | awk '/Page size:/ {print $3, $5}')
PAGE_WIDTH_PT=$(echo "$PAGE_SIZE_PT" | cut -d' ' -f1)
PAGE_HEIGHT_PT=$(echo "$PAGE_SIZE_PT" | cut -d' ' -f2)

# Convertir puntos a cm → 1 pt = 0.0352778 cm
PAGE_WIDTH_CM=$(awk "BEGIN { printf \"%.2f\", $PAGE_WIDTH_PT * 0.0352778 }")
PAGE_HEIGHT_CM=$(awk "BEGIN { printf \"%.2f\", $PAGE_HEIGHT_PT * 0.0352778 }")

echo "Tamaño detectado: $PAGE_WIDTH_CM cm x $PAGE_HEIGHT_CM cm"

# Escalado para que 36 cm = 1360 px
DPI=$(awk "BEGIN { printf \"%d\", 1360 / $PAGE_WIDTH_CM * 2.54 }")
echo "Usando resolución ajustada: ${DPI} DPI"

# 7. Convertir a imágenes con numeración tipo 'pagina-0001.png'
echo -e "\nGenerando imágenes PNG de cada página"
pdftoppm -r "$DPI" -png "$PDF_GENERADO" "${WORKDIR}/pagina_tmp"

# Renombrar con padding: pagina-0001.png, pagina-0002.png, ...
cd "$WORKDIR"
i=1
for f in pagina_tmp-*.png; do
    printf -v nuevo_nombre "pagina-%04d.png" "$i"
    mv "$f" "$nuevo_nombre"
    ((i++))
done

# 8. Eliminar el PDF intermedio
echo -e "\nEliminando el archivo PDF intermedio"
rm -f "$PDF_GENERADO"

echo -e "\nImágenes generadas en: $WORKDIR"

echo -e "\nPara unir las imágenes en un mural único:\nmagick \$(ls pagina-*.png | sort -V) -append \"\$(basename \"\$PWD\").png\""

exit 0
