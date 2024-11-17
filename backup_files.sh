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

if [ "$#" -ne 2 ]; then
    echo ">> INVALID ARGUMENTS!!!"                                                          # Validar número de argumentos igual a 2
    echo "Usage: $0 [-c] [-b tfile] [-r regexpr] dir_trabalho dir_backup"
    exit 1
fi

if [ ! -d "$dir_trabalho" ]; then
    echo ">> ERROR: Source directory \"$dir_trabalho\" does not exist!"                       # Verificar se a diretoria de trabalho passada existe como diretoria
    exit 1

elif [ ! -r "$dir_trabalho" ]; then
    echo ">> ERROR: Source directory \"$dir_trabalho\" does not have read permissions!"       # Garantir que diretoria de trabalho possui permissões de leitura para q se possam acessar os ficheiros
    exit 1
fi

if [ ! -e "$dir_backup" ]; then
    echo ">> WARNING: Backup directory \"$dir_backup\" does not exist. Creating it..."      # Criar diretoria de backup se não existir
    mkdir "$dir_backup"

elif [ ! -d "$dir_backup" ]; then
    echo ">> ERROR: \"$dir_backup\" exists but is not a directory!"                         # diretoria passada como diretoria de backup não é realmente uma diretoria
    exit 1
fi

if [ ! -w "$dir_backup" ] || [ ! -x "$dir_backup" ]; then
    echo ">> ERROR: Backup directory \"$dir_backup\" does not have sufficient permissions (write and execute)."
    exit 1
fi

rm_old_files2 "$dir_trabalho" "$dir_backup" "$checking"            # remove os ficheiros que já não estao no dir_trabalho da backup

for file in "$dir_trabalho"/{*,.*}; do

    if [[ "$file" == "$dir_trabalho/." || "$file" == "$dir_trabalho/.." || "$file" == "$dir_trabalho/.*" || "$file" == "$dir_trabalho/*" ]]; then       # ignorar ".", ".." e ".*"
        continue
    fi

    if [ ! -r "$file" ]; then
        echo ">> ERROR: File \"$file\" does not have read permissions. Skipping..."
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
                echo  "cp -a $file $backed_file"            
            fi
        
        elif [[ "$backed_file" -nt "$file" ]]; then               # ve se o ficheiro no diretório de backup é mais recente que o ficheiro com o mesmo nome no diretório de trabalho
            if ! $checking; then
                echo -e "WARNING: backup entry $backed_file is newer than $file; Should not happen"
            fi
        
        
        else   
            if ! $checking; then
                #echo -e "File \"$file\" doesn't need backing up!"      # imprimir que n foi feita alteração ao ficheiro
                continue
            fi
        fi

    else                                                                    # não existe no dir de backup um ficherio com o mesmo nome
        
        if $checking; then
            echo "cp -a $file $dir_backup"                                  # printa os comandos estando no modo checking
        
        else
            cp -a "$file" "$dir_backup"                                     # executa os comandos não estando no modo checking
            echo -e "cp -a $file $backed_file"
        fi
    fi

done

