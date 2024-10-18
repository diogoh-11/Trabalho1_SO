#!/bin/bash
. ./rm_old_files.sh

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

rm_old_files $dir_trabalho $dir_backup $checking

for file in "$dir_trabalho"/*; do
        
    fname="${file##*/}"

    if [ -e "$dir_backup/$fname" ]; then        # verifica se existe no diretório de backup um ficheiro com o mesmo nome
        backed_file=$dir_backup/$fname
        if [ $fname -nt $backed_file ]; then    # ve se o ficheiro no dir trabalho é mais recente que o ficherio com o mesmo nome no dir de backup
            if $checking; then
                echo "rm $backed_file"          # printa os comandos estando no modo checking
                echo "cp -a $fname $dir_backup"
            else
                rm "$backed_file"               # executa os comandos não estando no modo checking
                cp -a "$fname" "$dir_backup"
            fi
        fi

    else                                        # não existe no dir de backup um ficherio com o mesmo nome
        if $checking; then
            echo "cp -a $fname $dir_backup"     # printa os comandos estando no modo checking
        else
            cp -a "$fname" "$dir_backup"          # executa os comandos não estando no modo checking
        fi
    fi

done

