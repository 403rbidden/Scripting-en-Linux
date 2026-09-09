#!/bin/bash

# Ruta del directorio compartido
REFINAMIENTOS_DIR="/media/sf_VM_shared/Refinamientos"

# Verificar que el directorio existe
if [ ! -d "$REFINAMIENTOS_DIR" ]; then
  echo -e "\nNo existe el directorio: $REFINAMIENTOS_DIR\n"
  exit 1
fi

# Mostrar solo archivos .mkv con ruta absoluta
echo -e "\nArchivos .mkv disponibles en $REFINAMIENTOS_DIR:\n"

if [ -d "$REFINAMIENTOS_DIR" ]; then
  find "$REFINAMIENTOS_DIR" -type f -iname "*.mkv" -print0 2>/dev/null \
    | xargs -0 -I{} realpath "{}" 2>/dev/null \
    | sort

  # Comprobar si no se encontró nada
  if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "[INFO] No se encontraron archivos .mkv en el directorio."
  fi
else
  echo -e "\nNo se pudo acceder al directorio.\n"
  exit 1
fi

echo

# Solicitar al usuario la ruta del archivo a transcribir
read -rp "Introduce la ruta absoluta del archivo de vídeo que se quiere transcribir: " VIDEO_INPUT

# Verificar existencia del archivo
if [ ! -f "$VIDEO_INPUT" ]; then
  echo -e "\nEl archivo $VIDEO_INPUT no existe.\n"
  exit 1
fi

# Activar el entorno virtual de Whisper
source /home/mj/Documents/Environments/whisper/bin/activate

# Construir la ruta del archivo .wav quitando la extensión
WAV_OUTPUT="${VIDEO_INPUT%.*}.wav"

# Convertir a WAV mono 16 kHz
echo -e "\nConvirtiendo a: $WAV_OUTPUT\n"
ffmpeg -y -i "$VIDEO_INPUT" -ac 1 -ar 16000 "$WAV_OUTPUT"
if [ $? -ne 0 ]; then
  echo -e "\nFallo durante la conversión a WAV.\n"
  deactivate
  exit 1
fi

# Ejecutar Whisper con salida en TSV
echo -e "\nEjecutando transcripción con Whisper:\n"
whisper "$WAV_OUTPUT" \
  --language Spanish \
  --model small \
  --output_format tsv \
  --output_dir "$REFINAMIENTOS_DIR" \
  --device cpu \
  --fp16 False

# Verificar si se ha generado correctamente el archivo .tsv
TSV_OUTPUT="${REFINAMIENTOS_DIR}/$(basename "${WAV_OUTPUT%.*}.tsv")"
if [ -f "$TSV_OUTPUT" ]; then
  echo -e "\nTranscripción completada correctamente."
  echo -e "Archivo generado: $TSV_OUTPUT\n"
else
  echo -e "\nNo se ha encontrado el archivo de salida esperado:"
  echo -e "$TSV_OUTPUT\n"
fi

# Desactivar el entorno virtual
deactivate
