#!/bin/bash

dir_trabalho="$1"
dir_backup="$2"
igual="true"

checkrec(){

    local dir1="$1"
    local dir2="$2"
    local difere="false"
    

    for item1 in "$dir1"/{*,.*}; do
        if [ -f "$item1" ];then
            #Verifica se o item existe na diretoria de backup
            item2="$dir2/$(basename "$item1")"
            if [ -f "$item2" ];then
                #Compara os checksums dos arquivos
                if [ "$(md5sum "$item1" | awk '{ print $1 }')" != "$(md5sum "$item2" | awk '{ print $1 }')" ]; then
                    echo ""$item1" "$item2" differ."
                    difere="true"
                fi
            else
                echo ""$item1" not in "$dir_backup""
                difere="true"
            fi

        elif [ -d "$item1" ]  ; then
            #Chamar a função recursivamente se for diretorio
            item2="$dir2/$(basename "$item1")"
            if [ -d "$item2" ];then
                checkrec "$item1" "$item2"
            else
                echo ""$item1" not in "$dir_backup""
                difere="true"
            fi
        fi
    done

    #Atualiza a variavel igual
    if [ "$difere" == "true" ];then
        igual="false"
    fi
}
#Chama a função para comparar o dir_trabalho com backup
checkrec "$dir_trabalho" "$dir_backup"

if [ "$igual" = "true" ]; then
    echo "As diretorias são iguais"
fi

