#!/bin/bash

# função que apaga do dir de backup os ficheiros que foram eliminados ou mudados de nome do dir de trabalho
# $1 = dir trabalho
# $2 = dir backup

rm_old_files(){
    dir_trabalho="$1"
    dir_backup="$2"
    checking="$3"

    for file in "$dir_backup"/*; do
        
        fname="${file##*/}"

        if ! [ -e "$fname" ]; then        # verifica se o ficherio ainda existe no dir de trabalho
            
            if $checking; then
                echo "rm $dir_backup/$fname fff"          # printa os comandos estando no modo checking
            else
                rm "$dir_backup/$fname"              # executa os comandos não estando no modo checking
            fi
        fi

    done
}