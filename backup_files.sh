#!/bin/bash
. ./rm_old_files.sh

checking=false

while getopts "c" option; do                                # itera sobre as opções passadas na linha de comandos e armazena em option 
    case $option in
        c)
            checking=true                                   # modo checking 
            ;;
        *)
            echo "Usage: $0 [-c] dir_trabalho dir_backup"   # argumentos inválidos
            exit
            ;;
    esac
done

#validação dos argumentos:
shift $((OPTIND - 1))                                       # remove os argumentos iterados no loop anterior ou seja fica só com os diretorios
dir_trabalho="$1"
dir_backup="$2"

if [ $# -ne 2 ] || ! [ -d "$dir_trabalho" ] || ! [ -d "$dir_backup" ]; then
    echo ">> INVALID ARGUMENTS!!!"
    echo ">> Usage: $0 [-c] dir_trabalho dir_backup"
    exit 1
fi

if [ -z "$( ls -A $dir_trabalho )" ]; then 
    echo "No files in $dir_trabalho!"                       # verificar se diretótio está vazio
    exit 0
fi

rm_old_files $dir_trabalho $dir_backup $checking            # remove os ficheiros que já não estao no dir_trabalho da backup

for file in "$dir_trabalho"/{*,.*}; do

    fname="${file##*/}"

    if [ -e "$dir_backup/$fname" ]; then                    # verifica se existe no diretório de backup um ficheiro com o mesmo nome
        backed_file=$dir_backup/$fname

        if [[ "$file" -nt "$backed_file" ]]; then           # ve se o ficheiro no dir trabalho é mais recente que o ficherio com o mesmo nome no dir de backup
            
            if $checking; then
                echo "rm $backed_file"                      # printa os comandos estando no modo checking
                echo "cp -a $file $dir_backup"
            
            else
                rm "$backed_file"                           # executa os comandos não estando no modo checking
                cp -a "$file" "$dir_backup"
                echo -e "\n>> Removed older version of \"$file\" from \"$dir_backup\"."
                echo -e ">> Copyed \"$file\" to \"$dir_backup\"."
            fi
        
        else    
            if ! $checking; then
                echo -e "\n>> File \"$file\" doesn't need backing up!"      # imprimir que n foi feita alteração ao ficheiro
            fi
        fi

    else                                                                    # não existe no dir de backup um ficherio com o mesmo nome
        
        if $checking; then
            echo "cp -a $file $dir_backup"                                  # printa os comandos estando no modo checking
        
        else
            cp -a "$file" "$dir_backup"                                     # executa os comandos não estando no modo checking
            echo -e "\n>> Copyed \"$file\" to \"$dir_backup\"."
        fi
    fi

done

