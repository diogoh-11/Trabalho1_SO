#!bin/bash

# $1 = dir_trabalho
# $2 = dir backup

rm_old_files2(){
    dir_trabalho="$1"
    dir_backup="$2"
    checking="$3"

    if ! [ -z "$( ls -A $dir_backup )" ]; then             # garante q o dir n está vazio

        for item in "$dir_backup"/{*,.*}; do

            if [ -f "$item" ]; then
                fname="${item##*/}"

                if ! [ -e "$dir_trabalho/$fname" ]; then        # verifica se o ficherio ainda existe no dir de trabalho
                    
                    if $checking; then
                        echo "rm $dir_backup/$fname"           # printa os comandos estando no modo checking
                    else
                        rm "$dir_backup/$fname"              # executa os comandos não estando no modo checking
                        echo -e "\n>> Removed no longer existing file \"$fname\" from \"$dir_backup\"."
                    fi
                fi

            elif [ -d "$item" ]; then
                fname="${item##*/}"

                if ! [ -e "$dir_trabalho/$fname/" ]; then        # verifica se o diretorio ainda existe no dir de trabalho
                    
                    if $checking; then
                        echo "rm -r $dir_backup/$fname"           # printa os comandos estando no modo checking
                    else
                        rm -r "$dir_backup/$fname"              # executa os comandos não estando no modo checking
                        echo -e "\n>> Removed no longer existing file \"$fname\" from \"$dir_backup\"."
                    fi
                fi
            fi
        done
    fi
}
