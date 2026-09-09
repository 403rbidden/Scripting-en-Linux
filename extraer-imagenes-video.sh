#!/bin/bash

# Requiere: ffmpeg
# Instalar en Debian/Kali:
# sudo apt install ffmpeg -y

# Ruta del directorio habitual
REFINAMIENTOS_DIR="/media/sf_VM-Shared/Refinamientos"

# Verificar que el directorio existe
if [ ! -d "$REFINAMIENTOS_DIR" ]; then
  echo -e "\nNo existe el directorio: $REFINAMIENTOS_DIR\n"
  exit 1
fi

# Mostrar archivos disponibles
echo -e "\nArchivos disponibles en $REFINAMIENTOS_DIR:\n"
cd "$REFINAMIENTOS_DIR" || { echo -e "\nNo se pudo acceder al directorio.\n"; exit 1; }
realpath * 2>/dev/null | sort
echo

# Solicitar ruta del vídeo
read -rp "Introduce la ruta absoluta del archivo de vídeo que se quiere procesar: " VIDEO_INPUT

# Verificar que el archivo existe
if [ ! -f "$VIDEO_INPUT" ]; then
  echo -e "\nEl archivo $VIDEO_INPUT no existe.\n"
  exit 1
fi

# Obtener nombre del archivo sin extensión
VIDEO_NAME=$(basename "$VIDEO_INPUT")
BASE_NAME="${VIDEO_NAME%.*}"

# Obtener ruta del directorio donde está el vídeo
VIDEO_DIR=$(dirname "$VIDEO_INPUT")

# Crear subcarpeta con el mismo nombre que el vídeo (sin extensión)
OUTPUT_DIR="$VIDEO_DIR/$BASE_NAME"
mkdir -p "$OUTPUT_DIR"

echo -e "\nSe creará la carpeta:\n$OUTPUT_DIR"
echo -e "Las imágenes extraídas se guardarán solo si hay cambios visuales significativos.\n"

# Extraer solo fotogramas con cambios de escena (umbral 0.3) + primer fotograma
echo -e "Detectando cambios visuales y extrayendo imágenes...\n"
ffmpeg -y -i "$VIDEO_INPUT" -vf "select='eq(n\,0)+gt(scene\,0.3)',showinfo" -vsync vfr "$OUTPUT_DIR/img_%04d.png" >/dev/null 2>&1

# Contar imágenes extraídas
TOTAL=$(find "$OUTPUT_DIR" -type f -name "img_*.png" | wc -l)

if [ "$TOTAL" -eq 0 ]; then
  echo -e "\nNo se han generado imágenes. Es posible que el vídeo tenga pocos cambios visuales.\n"
  exit 1
fi

echo -e "\nProceso finalizado correctamente."
echo -e "\nSe han guardado un total de $TOTAL imágenes en $OUTPUT_DIR."
