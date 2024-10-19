#!/bin/bash
. ./rm_old_files.sh

checking=false

while getopts "c" option; do                                # itera sobre as opções passadas na linha de comandos e armazena em option 
    case $option in
        c)
            checking=true                                   # modo checking 
            ;;
        *)
            echo "Usage: $0 [-c] dir_trabalho dir_backup"   # modo de execução
            exit
            ;;
    esac
done

#validação dos argumentos:
shift $((OPTIND - 1))                                       # remove os argumentos iterados no loop anterior ou seja fica só com os diretorios
dir_trabalho="$1"
dir_backup="$2"

if [ $# -gt 2 ] || ! [ -d $dir_trabalho ] || ! [ -d $dir_backup ]; then
    echo "ARGUMENTOS INVÁLIDOS!!!"
    echo "Usage: $0 [-c] dir_trabalho dir_backup"
    exit    
fi

rm_old_files $dir_trabalho $dir_backup $checking            # remove os ficheiros que já não estou no dir_trabalho da backup

for file in "$dir_trabalho"/*; do
        
    fname="${file##*/}"                         # remove o prefixo do caminho deixando apenas o nome do arquivo

    if [ -e "$dir_backup/$fname" ]; then        # verifica se existe no diretório de backup um ficheiro com o mesmo nome
        backed_file=$dir_backup/$fname
        if [ $fname -nt $backed_file ]; then    # ve se o ficheiro no dir trabalho é mais recente que o ficheiro com o mesmo nome no dir de backup || nt--> newer than
            if $checking; then
                echo "rm $backed_file"          # printa os comandos estando no modo checking
                echo "cp -a $fname $dir_backup"
            else
                rm "$backed_file"               # executa os comandos não estando no modo checking
                cp -a "$fname" "$dir_backup"    # -a preserva permissões/data modificação
            fi
        fi

    else                                        # não existe no dir de backup um ficherio com o mesmo nome
        if $checking; then
            echo "cp -a $fname $dir_backup"     # printa os comandos estando no modo checking
        else
            cp -a "$fname" "$dir_backup"        # executa os comandos não estando no modo checking
        fi
    fi

done

