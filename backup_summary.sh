#!/bin/bash
. ./rm_old_files2.sh
. ./in_array.sh

checking=false 
tfile=" "                               # valor default para nome do ficheiro para que seja criada uma array vazia no caso de n ter sido dado input tfile
regexpr="\w+"                           # expressao regular que aceita todos os nomes de ficheiros, garantindo que se não for dada uma expressão regular, todos os ficheiros são atualizados     
declare -a dont_update                  # declarar array vazia que servirá para armazenar nomes de ficheiros a não atualizar no caso de ser passado algum pelo input tfile

while getopts "cb:r:" option; do        # itera sobre as opções passadas na linha de comandos e armazena em option 
    case $option in
        c)
            checking=true               # ativa modo checking
            ;;
        b)
            tfile="$OPTARG"                                     # guarda em tfile o nome do ficheiro passado
            if [ -f "$tfile" ] && ! [ -z "$tfile" ]; then       # garante que é um ficheiro e não está vazio antes de iterar pelos ficheiros nele escrito e guardar na array
                index=0

                while read -r line; do 
                    dont_update[$index]="$line"                 # coloca no array "dont_update" o nome dos ficheiros que não serão atualizados no backup
                    index=$(($index+1))
                done < "$tfile"
            fi
            ;;
        r)  
            regexpr="$OPTARG"                                   # guarda em regexpr a expressão regular passada
            ;;

        *)
            echo "Usage: $0 [-c] [-b tfile] [-r regexpr] dir_trabalho dir_backup"   # output caso haja algo inválido 
            exit
            ;;
    esac
done

shift $((OPTIND - 1))               # remove os argumentos iterados no loop anterior, ficando só com os diretórios
dir_trabalho="$1"                   # diretório de trabalho passado
dir_backup="$2"                     # diretório de backup passado

errors=0
warnings=0
updated=0
copied=0
untouched=0
bytes_copied=0
bytes_deleted=0
bytes_untouched=0

if [ $# -ne 2 ] || ! [ -d "$dir_trabalho" ] || ! [ -d "$dir_backup" ]; then
    echo ">> INVALID ARGUMENTS!!!"                                              # fazer validação dos argumentos passados
    echo ">> Usage: $0 [-c] [-b tfile] [-r regexpr] dir_trabalho dir_backup"
    ((errors+=1))
    exit 1
fi

rm_old_files2 $dir_trabalho $dir_backup $checking            # remove os ficheiros/diretórios que já não estou no diretório de trabalho
deleted=$?


for item in "$dir_trabalho"/{*,.*}; do                       # iterar por todos os itens do diretório de trabalho, incluido os ficheiros escondidos

    if [[ "$item" == "$dir_trabalho/." || "$item" == "$dir_trabalho/.." || "$item" == "$dir_trabalho/.*" || "$item" == "$dir_trabalho/*" ]]; then       # ignorar ".", ".." e ".*"
        continue
    fi

    if [ -f "$item" ]; then                                             # caso item seja um ficheiro
        file="$item"
        fname="${file##*/}"                                             # tirar nome do ficheiro
        file_size=$(wc -c < "$file") 
        in_array "$file" "${dont_update[@]}"                            # verificar se esse ficherio consta na list de ficherios a não atualizar
        ret_val=$?                                                      # valor de retorno da função (1: está no array; 0: não está no array)
        
        if [ "$ret_val" -eq 0 ] && [[ "$file" =~ $regexpr ]]; then      # garantir que ficherio n está no array e valida a expressão regular que não sendo passada nenhuma será "\w+" e aceitará qq ficheiro
            
            if [ -e "$dir_backup/$fname" ]; then                        # verifica se existe no diretório de backup um ficheiro com o mesmo nome
                backed_file=$dir_backup/$fname

                if [[ "$file" -nt "$backed_file" ]]; then               # ve se o ficheiro no diretório de trabalho é mais recente que o ficheiro com o mesmo nome no diretório de backup
                    
                    if $checking; then
                        echo "rm $backed_file"                          # printa os comandos estando no modo checking
                        echo "cp -a $file $dir_backup"
                    
                    else
                        rm "$backed_file"                                                           # remove ficheiro antigo
                        ((bytes_deleted+=file_size))
                        cp -a "$file" "$dir_backup"                                                 # copia ficheiro mais recente
                        ((bytes_copied+=file_size))
                        echo -e "\n>> Removed older version of \"$file\" from \"$dir_backup\"."
                        echo -e ">> Copyed \"$file\" to \"$dir_backup\"."
                        ((updated+=1))
                    fi
                
                elif [[ "$backed_file" -nt "$file" ]]; then               # ve se o ficheiro no diretório de backup é mais recente que o ficheiro com o mesmo nome no diretório de trabalho
                    if ! $checking; then
                        ((warnings+=1))
                        echo -e "\n>> WARNING: backup entry \"$backed_file\" is newer than \"$file\"... [Should not happen!!!]"
                    fi

                else    
                    if ! $checking; then
                        ((untouched+=1))
                        ((bytes_untouched+=file_size))
                        echo -e "\n>> File \"$file\" doesn't need backing up!"      # imprimir que n foi feita alteração ao ficheiro porque data de modificação é a mesma ou ficheiro no diretório de backup está mais atualizado
                    fi
                fi

            else                                                                    # não existe no diretório de backup um ficheiro com o mesmo nome
        
                if $checking; then
                    echo "cp -a $file $dir_backup"                                  # printa os comandos estando no modo checking
        
                else
                    cp -a "$file" "$dir_backup"                                     # executa os comandos não estando no modo checking
                    ((bytes_copied+=file_size))
                    ((copied+=1))
                    echo -e "\n>> Copyed \"$file\" to \"$dir_backup\"."
                fi
            fi  
        else 
            if ! $checking; then
                ((untouched+=1))
                ((bytes_untouched+=file_size))
                echo -e "\n>> File \"$file\" will not be updated due to user input (tfile or regex)!"   # nome do ficherio conta na lista de ficherios a não alterar ou não aceita expressão regular passada
            fi
        fi

    else                                                                    # caso em que "item" é um diretório  precisamos tratar de fazer backup desse diretório recorrendo à chamada recursiva do script nesse novo diretório de trabalho e backup
        dir="$item"     
        subdir_name="${dir##*/}"                                            # extrair nome do diretório
            
        if [ -e "$dir_backup/$subdir_name" ]; then                          # verifica se existe no diretório de backup um diretório com o mesmo nome
            backed_dir=$dir_backup/$fname
            
            if $checking; then                                                                                  # imprimir comandos no modo checking. Imprimimos a forma como chamariamos o script porque não conseguimos por vezes chamar recursivamente o script com o "-c" pelo facto de os diretórios não existitem ainda
                echo "$0 -c -b $tfile -r $regexpr $dir_trabalho/$subdir_name $dir_backup/$subdir_name"
            
            else    
                echo -e "\n>> Entered directory \"$dir\". Starting backing up..."                               # chamar script sobre os novos diretórios
                $0 -b "$tfile" -r "$regexpr" "$dir_trabalho/$subdir_name" "$dir_backup/$subdir_name"
            fi
        
        else                                                                                                    # diretório não existe          
            if $checking; then
                echo "mkdir $dir_backup/$subdir_name"                                                           # imprimir comandos no modo checking. Imprimimos a forma como chamariamos o script porque não conseguimos por vezes chamar recursivamente o script com o "-c" pelo facto de os diretórios não existitem ainda
                echo "$0 -c -b $tfile -r $regexpr $dir_trabalho/$subdir_name $dir_backup/$subdir_name"

            else
                mkdir "$dir_backup/$subdir_name"                                                                # criar diretório no diretório de backup e chamar script sobre esses novos diretórios
                echo -e "\n>> Created directory \"$dir_backup/$subdir_name\" in \"$dir_backup\""
                $0 -b "$tfile" -r "$regexpr" "$dir_trabalho/$subdir_name" "$dir_backup/$subdir_name"
            fi
        fi  
    fi
        
done

if ! $checking; then
    echo -e "\n>> While backuping $dir_trabalho: $errors Errors; $warnings Warnings; $updated Updated; $copied Copied ($bytes_copied B); $untouched Untouched ($bytes_untouched B); $deleted Deleted ($bytes_deleted B)"
fi



