#!/bin/bash

# Colores
verde='\033[0;32m'
rojo='\033[0;31m'
azul='\033[0;34m'
reset='\033[0m'

# Mostrar mensaje de presentación e instrucciones
echo ""
echo -e "${azul}------------------------------------------${reset}"
echo -e "\033[1mCONVERSOR DE PETICIONES HTTP/2 A HTTP/1.1\033[0m${reset}"
echo -e "${azul}------------------------------------------${reset}"
echo ""
echo -e "Este programa convierte un archivo de solicitud HTTP exportado desde herramientas
como Burp Suite u OWASP ZAP que utilice el protocolo HTTP/2, modificando su línea
inicial para que resulte compatible con SQLmap"
echo ""
echo "Requisitos:"
echo "- El archivo debe contener la petición completa en texto plano (con o sin extensión)"
echo "- La primera línea debe comenzar por 'GET /...' o 'POST /...' y terminar en 'HTTP/2'"
echo -e "- Se debe proporcionar la \033[1mRUTA ABSOLUTA\033[0m del archivo
  Puede obtenerse ejecutando el comando: realpath <nombre del archivo>"
echo ""
echo "Ejemplo:"
echo -e "  ${verde}┌──(${azul}mj㉿viewnext${verde})─[${reset}\033[1m~/Documents/Audits/TI-PORTALVULNERABILIDADES/script\033[0m${verde}]${reset}"
echo -e "  ${verde}└─${azul}\$${reset} realpath LOADTAGS"
echo -e "  /home/mj/Documents/Audits/TI-PORTALVULNERABILIDADES/Peticiones/LOADTAGS"
echo ""
echo -e "${azul}------------------------------------------\n${reset}"

read -p "Introduce la ruta absoluta del archivo HTTP/2 que deseas convertir: " file_path

# Verificar que el archivo existe
if [[ ! -f "$file_path" ]]; then
  echo -e "\n${rojo}[ERROR]${reset} No se ha encontrado el archivo especificado: $file_path"
  echo "Asegúrate de haber introducido la ruta absoluta correctamente"
  exit 1
fi

# Extraer directorio y nombre base sin extensión
dir_path="$(dirname "$file_path")"
file_name="$(basename "$file_path")"
base_name="${file_name%.*}"  # sin extensión

# Obtener primera línea
first_line="$(head -n 1 "$file_path")"

# Detectar método, ruta y versión
http_method="$(echo "$first_line" | awk '{print $1}')"
http_path="$(echo "$first_line" | awk '{print $2}')"
http_version="$(echo "$first_line" | awk '{print $3}')"

# Validar formato esperado
if [[ "$http_version" != "HTTP/2" ]] || [[ ! "$http_method" =~ ^(GET|POST)$ ]]; then
  echo -e "\n${rojo}[ERROR]${reset} La primera línea no es válida.
  Se esperaba 'GET|POST /... HTTP/2'\n"
  echo "No se realizará ninguna modificación"
  exit 1
fi

# Extraer Host
host_line="$(grep -i '^Host:' "$file_path")"
host="$(echo "$host_line" | cut -d':' -f2- | tr -d '[:space:]')"

if [[ -z "$host" ]]; then
  echo -e "\n${rojo}[ERROR]${reset} No se ha encontrado la cabecera 'Host:' en el archivo"
  exit 1
fi

# Construir nueva primera línea
new_first_line="${http_method} https://${host}${http_path} HTTP/1.1"

# Generar nombre de archivo de salida: GET-LOADTAGS-HTTP1
output_path="${dir_path}/${base_name}-${http_method}-HTTP1"

# Crear nuevo archivo con la línea convertida
{
  echo "$new_first_line"
  tail -n +2 "$file_path"
} > "$output_path"

# Mensaje final
echo -e "\n${verde}[OK]${reset} Se ha convertido la petición ${http_method} satisfactoriamente"
echo -e "El archivo se ha guardado en: \033[1m$output_path\033[0m${reset}"
