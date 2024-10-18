#!/bin/bash
checking=false

while getopts "c" option; do
    case $option in
        c)
            checking=true
            ;;
        *)
            echo "Usage: $0 [-c] dir_trabalho dir_backup"
            ;;
    esac
done

#validação dos argumentos:
shift $((OPTIND - 1))
dir_trabalho="$1"
dir_backup="$2"

if ! [ -d $dir_trabalho ] || ! [ -d $dir_backup ]; then
    echo "Os agrumentos passados não são diretórios!"
    echo "Usage: $0 [-c] dir_trabalho dir_backup"
    exit    
fi

