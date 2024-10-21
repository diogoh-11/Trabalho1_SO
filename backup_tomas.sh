#!/bin/bash
. ./rm_old_files.sh
. ./in_array.sh

checking=false 
tfile="no_tfile"
regexpr="\w+"        # expressao regular q aceita todos os nomes de ficheiros ou seja a n ser q seja dada como input uma outra expressao regular todos os ficheiros vão ser transferidos     
declare -a dont_update  # Standard indexed array
sub_directoryies=()

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

for ((i = 0; i < ${#dont_update[@]}; i++)); do              # debug
    echo "$i: ${dont_update[i]}"
done

if [ $# -ne 2 ] || ! [ -d "$dir_trabalho" ] || ! [ -d "$dir_backup" ]; then
    echo ">> INVALID ARGUMENTS!!!"
    echo ">> Usage: $0 [-c] [-b tfile] [-r regexpr] dir_trabalho dir_backup"
    exit 1
fi

    
#rm_old_files $dir_trabalho $dir_backup $checking $dont_update $tfile $regexpr           # remove os ficheiros que já não estou no dir_trabalho da backup

for item in "$dir_trabalho"/{*,.*}; do

    if [ -f "$item" ]; then 
        file="$item"
        fname="${file##*/}"
        in_array "$file" "${dont_update[@]}" 
        ret_val=$?
        
        if [ "$ret_val" -eq 0 ] && [[ "$file" =~ $regexpr ]]; then 
            if [ -e "$dir_backup/$fname" ]; then        # verifica se existe no diretório de backup um ficheiro com o mesmo nome
                backed_file=$dir_backup/$fname

                if [[ "$file" -nt "$backed_file" ]]; then    # ve se o ficheiro no dir trabalho é mais recente que o ficherio com o mesmo nome no dir de backup
                    
                    if $checking; then
                        echo "rm $backed_file"          # printa os comandos estando no modo checking
                        echo "cp -a $file $dir_backup"
                    
                    else
                        rm "$backed_file"               # executa os comandos não estando no modo checking
                        cp -a "$file" "$dir_backup"
                        echo -e "\n>> Removed older version of \"$file\" from \"$dir_backup\"."
                        echo -e ">> Copyed \"$file\" to \"$dir_backup\"."
                    fi
                
                else    
                    if ! $checking; then
                        echo -e "\n>> File \"$file\" doesn't need backing up!"      # imprimir que n foi feita alteração ao ficheiro
                    fi
                fi

            else                                        # não existe no dir de backup um ficherio com o mesmo nome
        
                if $checking; then
                    echo "cp -a $file $dir_backup"     # printa os comandos estando no modo checking
        
                else
                    cp -a "$file" "$dir_backup"          # executa os comandos não estando no modo checking
                    echo -e "\n>> Copyed \"$file\" to \"$dir_backup\"."
                fi
            fi  
        else 
            continue
            #echo -e "\n>> Ficheiro \"$file\" não será atualizado por input utilizador!"  
        fi
    else   # se for diretorio chamar script recursivamente sobre esse diretorio
        sub_dir=$item
        echo "-------------------------------------$sub_dir"
        sub_directories+=("$sub_dir")
        continue
    fi
done

for subdir in "${sub_directories[@]}"; do
    subdir_name="${subdir##*/}"
    echo "$subdir_name"
    echo "created subdir $dir_backup/$subdir_name"
    mkdir "$dir_backup/$subdir_name"
    echo "entered subdir $dir_backup/$subdir_name"
    $0 -c -b "$tfile" -r "$regexpr" "$dir_trabalho/$subdir_name" "$dir_backup/$subdir_name"

done
