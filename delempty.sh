#!/bin/bash

# Un script que se encarga de eliminar todos los archivos vacíos de un directorio
# [directorio] [profundidad]
# Profundidad máxima por defecto

tempdir=$(mktemp -d)

# Si el directorio temporal se pudo crear, crear un archivo temporal dentro
if [ -d $tempdir ]; then
    trap "rm -rf $tempdir" EXIT # Asegurarse de que se borra cuando el script termina
    temp=$(mktemp "$tempdir/tempfile.XXXXXX")
else
    echo "No se pudo crear un directorio temporal. Abortando..."
    exit 2
fi

if [ $# -lt 1 ]; then
    echo "Número inválido de argumentos"
    echo "Por favor, especifica un directorio, o 'pwd' para el mismo directorio que el script"
    exit 1
else
    if [ -d $1 ]; then
        directorio=$1
    else
        if [ $1 == "pwd" ]; then
            directorio=$(pwd)
        else
            echo "Directorio inválido o no existe"
            exit 1
        fi
    fi
fi


if [ "$2" == "" ]; then
    find "$directorio" -type f -empty > $temp
    echo "Archivos vacíos encontrados:"
    cat $temp
    echo ""

    # Bloque que elimina todos los archivos encontrados
    while read -r file; do
        # Buscar lineas vacías o archivos faltantes
        [[ -z $file || ! -f $file ]] && continue

        # Eliminar el archivo
        rm -f "$file"
        echo -e "Se eliminó: $file"
    done < "$temp"
    echo "Todos los archivos se eliminaron"
else
    if [ $2 -lt "26" ]; then
        find "$directorio" -maxdepth $2 -type f -empty > $temp
        echo "Archivos vacíos encontrados:"
        cat $temp
        echo ""

        # Bloque que elimina todos los archivos encontrados
        while read -r file; do
            # Buscar lineas vacías o archivos faltantes
            [[ -z $file || ! -f $file ]] && continue

            # Eliminar el archivo
            rm -f "$file"
        done < "$temp"
        echo "Todos los archivos se eliminaron"
    else
        echo "Por seguridad, el nivel de recursividad no puede ser mayor a 25"
    fi
fi

exit 0
