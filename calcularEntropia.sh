#!/bin/bash

# Comando: img="nombreDeLaImagen.Extensión"; xxd -p "$img" | fold -w2 | sort | uniq -c | awk '{ p=$1/total; sum += -p*log(p)/log(2) } END { print "'$img':", sum }' total=$(wc -c < "$img")

# Pedir la ruta de los archivos al usuario
read -p "Introduce la ruta del directorio con las imágenes: " ruta
echo -e "\n"

# Verificar que la ruta exista
if [ ! -d "$ruta" ]; then
    echo "La ruta especificada no existe."
    exit 1
fi

# Variables para almacenar la imagen con mayor entropía
max_entropy=0
max_entropy_image=""

# Iterar sobre cada archivo .jpg en la ruta especificada
for img in "$ruta"/*.jpg; do
    # Calcula la entropía del archivo actual
    entropy=$(xxd -p "$img" | fold -w2 | sort | uniq -c | awk '{ p=$1/total; sum += -p*log(p)/log(2) } END { print sum }' total=$(wc -c < "$img"))
    
    # Extraer solo el nombre del archivo
    img_name=$(basename "$img")
    
    # Mostrar el resultado para la imagen actual
    echo "La imagen '$img_name' tiene una entropía de $entropy."
    
    # Comprobar si esta imagen tiene la mayor entropía hasta ahora
    if (( $(echo "$entropy > $max_entropy" | bc -l) )); then
        max_entropy=$entropy
        max_entropy_image=$img_name
    fi
done

# Mostrar la imagen con la mayor entropía
echo -e "\n ---> La imagen '$max_entropy_image' tiene el valor más alto de entropía, con una magnitud total de $max_entropy bits.\n"

# Explicación sobre el valor de entropía obtenida
echo "Datos de interés:"
if (( $(echo "$max_entropy > 7.5" | bc -l) )); then
    echo "El valor de entropía es alto (cercano a 8 bits), lo que indica una alta aleatoriedad y variabilidad en los datos de la imagen '$max_entropy_image'."
    echo "Y es probable que contenga patrones complejos o esté comprimida, características comunes en datos cifrados o imágenes detalladas."
elif (( $(echo "$max_entropy > 6" | bc -l) )); then
    echo "La entropía es moderada (entre 6 y 7.5 bits), lo que sugiere cierta variabilidad en la imagen '$max_entropy_image'."
    echo "Esto suele indicar que la imagen tiene patrones reconocibles o menos detalles complejos en los datos."
else
    echo "El valor de entropía es bajo (menos de 6 bits), indicando una baja variabilidad en la imagen '$max_entropy_image'."
    echo "La imagen podría tener patrones más uniformes o contener áreas con colores similares."
fi
