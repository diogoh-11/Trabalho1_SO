#!/bin/bash
. ./rm_old_files2.sh

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

if [ $# -ne 2 ] || ! [ -d "$dir_trabalho" ]; then
    echo ">> INVALID ARGUMENTS!!!"                                                                  # validação doa argumentos
    echo ">> Usage: $0 [-c] dir_trabalho dir_backup"
    exit 1

elif  ! [ -e "$dir_backup" ] || ! [ -d "$dir_backup" ]; then
    echo -e "\n>> WARNING: backup directory \"$dir_backup\" does not exist! Creating it..."         # caso não exista o diretorio de backup é criado um
    mkdir "$dir_backup"
fi

if [ -z "$( ls -A $dir_trabalho )" ]; then 
    echo -e "\n>> WARNING: source directory \"$dir_trabalho\" is empty!"                       # verificar se diretótio está vazio
    exit 0
fi

rm_old_files2 "$dir_trabalho" "$dir_backup" "$checking"            # remove os ficheiros que já não estao no dir_trabalho da backup

for file in "$dir_trabalho"/{*,.*}; do

    if [[ "$file" == "$dir_trabalho/." || "$file" == "$dir_trabalho/.." || "$file" == "$dir_trabalho/.*" || "$file" == "$dir_trabalho/*" ]]; then       # ignorar ".", ".." e ".*"
        continue
    fi

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
                echo -e "\n>> File \"$file\" was successfully updated!"            
            fi
        
        elif [[ "$backed_file" -nt "$file" ]]; then               # ve se o ficheiro no diretório de backup é mais recente que o ficheiro com o mesmo nome no diretório de trabalho
            if ! $checking; then
                echo -e "\n>> WARNING: backup entry \"$backed_file\" is newer than \"$file\"... [Should not happen!!!]"
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

