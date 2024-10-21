#!/bin/bash
. ./rm_old_files.sh

checking=false 
tfile="notfile"
regexpr="noregularExp"                                            # variavel para detetar o uso de -r      
declare -a dont_update  # Standard indexed array

while getopts "cb:r:" option; do                           # itera sobre as opções passadas na linha de comandos e armazena em option 
    case $option in
        c)
            checking=true                                  # modo checking 
            ;;
        b)
            tfile="$OPTARG"                             # Lê o ficheiro ou diretorio passado que contem nome dos ficheiros que n devem ser atualizados
            if [ -f "$tfile" ] && ! [ -z "$tfile" ]; then
                index=0

                while read -r line; do 
                    dont_update[$index]="$line"         # coloca num array "dont_update" o nome dos ficheiros que não serão atualizados no backup
                    index=$(($index+1))
                done < "$tfile"
            fi
            ;;
        r)  
            regexpr="$OPTARG"                           # Lê a expressão regular passada
            ;;

        *)
            echo "Usage: $0 [-c] [-b tfile] [-r regexpr] dir_trabalho dir_backup"   # argumentos inválidos
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
        
    fname="${file##*/}"                                     # remove o prefixo do caminho deixando apenas o nome do arquivo

    if [ "$fname" = "$tfile" ] ||  [ "$tfile" != "notfile" ]; then
        continue;   
    fi                                

    
    if [[ "$fname" =~ "$regexpr"  ||  "$regexpr" =~ "noregularExp" ]] ; then      # vê se a expressão regular é igual se encontra no ficheiro dado
        echo "$fname corresponde à expressão regular."

        if [ -e "$dir_backup/$fname" ]; then                    # verifica se existe no diretório de backup um ficheiro com o mesmo nome
            backed_file=$dir_backup/$fname
            if [ "$fname" -nt "$backed_file" ]; then                # ve se o ficheiro no dir trabalho é mais recente que o ficheiro com o mesmo nome no dir de backup || nt--> newer than
                if $checking; then
                    echo "rm -r \"$backed_file\""                      # printa os comandos estando no modo checking
                    echo "cp -a \"$fname\" \"$dir_backup\""
                else                                            # executa os comandos se for um diretorio ou um ficheiro   
                    rm -r "$backed_file"              
                    cp -a "$fname" "$dir_backup"       
                fi
            fi


        else                                                    # não existe no dir de backup um ficherio com o mesmo nome
            if $checking; then
                echo "cp -a \"$fname\" \"$dir_backup\""         # printa os comandos estando no modo checking
            else
                cp -a "$fname" "$dir_backup"                    # copia o diretorio ou ficheiro
            fi
        fi
    fi

done