#!/bin/bash

# Colores
verde='\033[0;32m'
rojo='\033[0;31m'
azul='\033[0;34m'
reset='\033[0m'

# Presentación
echo ""
echo -e "${azul}--------------------------------------${reset}"
echo -e "\033[1mEXTRACTOR DE COOKIES EN ARCHIVOS HTTP\033[0m"
echo -e "${azul}--------------------------------------${reset}"
echo ""
echo -e "Este programa extrae automáticamente las cookies de autenticación desde un archivo con"
echo -e "una petición HTTP completa (exportada desde Burp/ZAP/etc), y genera dos archivos separados:"
echo -e "  - [nombre del archivo original]-COOKIE-AspNetCore_Identity_Application"
echo -e "  - [nombre del archivo original]-COOKIE-AspNetCore_Antiforgery_dKmiBYugJkg\n"
echo -e "Es obligatorio introducir la \033[1mRUTA ABSOLUTA\033[0m del archivo de entrada."
echo -e "Usa el comando: ${verde}realpath [nombre del archivo original]${reset}"
echo ""
echo -e "${azul}--------------------------------------${reset}"

# Solicitar ruta absoluta del archivo
read -p "Introduce la ruta absoluta del archivo con la petición HTTP: " file_path

# Validar ruta absoluta
if [[ "$file_path" != /* ]]; then
  echo -e "\n${rojo}[ERROR]${reset} La ruta debe ser absoluta y comenzar con '/'."
  exit 1
fi

# Verificar existencia del archivo
if [[ ! -f "$file_path" ]]; then
  echo -e "\n${rojo}[ERROR]${reset} No se ha encontrado el archivo: $file_path"
  echo "Asegúrate de haber escrito correctamente la ruta absoluta."
  exit 1
fi

# Extraer nombres
file_name="$(basename "$file_path")"
base_name="${file_name%.*}"
dir_path="$(dirname "$file_path")"

# Extraer línea de cookies
cookie_line=$(grep -i '^Cookie:' "$file_path" | sed 's/^Cookie:[ ]*//' | tr -d '\r\n')

if [[ -z "$cookie_line" ]]; then
  echo -e "\n${rojo}[ERROR]${reset} No se encontró ninguna cabecera Cookie en el archivo."
  exit 2
fi

# Extraer valores de las cookies
identity_value=$(echo "$cookie_line" | grep -oP '\.AspNetCore\.Identity\.Application=\K[^;]+')
antiforgery_value=$(echo "$cookie_line" | grep -oP '\.AspNetCore\.Antiforgery\.dKmiBYugJkg=\K[^;]+')

# Generar nombres de archivos
identity_file="${dir_path}/${base_name}-COOKIE-AspNetCore_Identity_Application"
antiforgery_file="${dir_path}/${base_name}-COOKIE-AspNetCore_Antiforgery_dKmiBYugJkg"

# Guardar resultados en los archivos
if [[ -n "$identity_value" ]]; then
  echo "$identity_value" > "$identity_file"
  echo -e "\n${verde}[OK]${reset} Cookie '.AspNetCore.Identity.Application' exportada en: \033[1m$identity_file\033[0m"
else
  echo -e "\n${rojo}[Error]${reset} No se encontró la cookie '.AspNetCore.Identity.Application'"
fi

if [[ -n "$antiforgery_value" ]]; then
  echo "$antiforgery_value" > "$antiforgery_file"
  echo -e "${verde}[OK]${reset} Cookie '.AspNetCore.Antiforgery.dKmiBYugJkg' exportada en: \033[1m$antiforgery_file\033[0m"
else
  echo -e "${rojo}[Error]${reset} No se encontró ninguna cookie '.AspNetCore.Antiforgery.dKmiBYugJkg'"
fi

