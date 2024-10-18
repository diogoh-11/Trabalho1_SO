#!/bin/bash
checking=false

while getopts "c" option; do
    case $option in
        c)
            checking=true
            ;;
        *)
            echo "Usage: $0 [-c] dir_trabalho dir_backup"
            exit
            ;;
    esac
done

#validação dos argumentos:
shift $((OPTIND - 1))
dir_trabalho="$1"
dir_backup="$2"

if [ $# -gt 2 ] || ! [ -d $dir_trabalho ] || ! [ -d $dir_backup ]; then
    echo "ARGUMENTOS INVÁLIDOS!!!"
    echo "Usage: $0 [-c] dir_trabalho dir_backup"
    exit    
fi

for file in "$dir_trabalho"/*; do
    if [ -f "$file" ]; then  
        fname="${file##*/}"
        echo "File name: $fname"
        #Ideia: criar 2 funções, uma que verifique se ja existe no dir de backup um ficherio com o mesmo nome
        # outra que compare as os dois ficheiros com o mesmo nome e retorne aquele com a data de modificação mais recente
        # ??? prompt a perguntar se deseja substitui ficheiro 
    fi
done

