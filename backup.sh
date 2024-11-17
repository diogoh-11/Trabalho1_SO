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
                    if [ -e "$line" ] && [ -r "$file" ]; then                                     # garantir que ficheiro/diretório existe para que se possa usar "realpath"
                        dont_update[$index]=$(realpath "$line")                 # coloca no array "dont_update" path absoluto dos ficheiros que não serão atualizados no backup
                        index=$(($index+1))
                    fi
                done < "$tfile"
            
            elif [ "$tfile" == " " ]; then
                continue
                                                                            # imprimir warning caso tfile n exiista
            else
                echo -e "WARNING: tfile \"$tfile\" does not exist!"

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

rm_old_files2 "$dir_trabalho" "$dir_backup" "$checking"            # remove os ficheiros/diretórios que já não estou no diretório de trabalho


for item in "$dir_trabalho"/{*,.*}; do                       # iterar por todos os itens do diretório de trabalho, incluido os ficheiros escondidos

    if [[ "$item" == "$dir_trabalho/." || "$item" == "$dir_trabalho/.." || "$item" == "$dir_trabalho/.*" || "$item" == "$dir_trabalho/*" ]]; then       # ignorar ".", ".." e ".*"
        continue
    fi

    absolute_path=$(realpath "$item")                               # obter path absoluto do ficherio/diretorio para poder verficar se consta na array "dont_update"
    in_array "$absolute_path" "${dont_update[@]}"                   # verificar se esse ficherio/diretorio consta na list de ficherios/diretorios a não atualizar
    ret_val=$?                                                      # valor de retorno da função (1: está no array; 0: não está no array)
       
    if [ -f "$item" ]; then                                             # caso item seja um ficheiro
        file="$item"
        fname="${file##*/}"                                             # tirar nome do ficheiro

        if [ ! -r "$file" ]; then
            echo ">> ERROR: File \"$file\" does not have read permissions. Skipping."
        continue
    fi
        
        if [ "$ret_val" -eq 0 ] && [[ "$file" =~ $regexpr ]]; then      # garantir que ficherio n está no array e valida a expressão regular que não sendo passada nenhuma será "\w+" e aceitará qq ficheiro
            
            if [ -e "$dir_backup/$fname" ]; then                        # verifica se existe no diretório de backup um ficheiro com o mesmo nome
                backed_file=$dir_backup/$fname

                if [[ "$file" -nt "$backed_file" ]]; then               # ve se o ficheiro no diretório de trabalho é mais recente que o ficheiro com o mesmo nome no diretório de backup
                    
                    if $checking; then
                        echo "rm $backed_file"                          # printa os comandos estando no modo checking
                        echo "cp -a $file $dir_backup"
                    
                    else
                        rm "$backed_file"                                                           # remove ficheiro antigo
                        cp -a "$file" "$dir_backup"                                                 # copia ficheiro mais recente
                        #echo -e "\n>> File \"$file\" was successfully updated!"
                        echo "cp -a $file $dir_backup/$fname"
                    fi
                
                elif [[ "$backed_file" -nt "$file" ]]; then               # ve se o ficheiro no diretório de backup é mais recente que o ficheiro com o mesmo nome no diretório de trabalho
                    echo -e "WARNING: backup entry \"$backed_file\" is newer than \"$dir_trabalho/$file\"... [Should not happen!!!]"
                
                else    
                    if ! $checking; then
                        #echo -e "\n>> File \"$file\" doesn't need backing up!"      # imprimir que n foi feita alteração ao ficheiro porque data de modificação é a mesma ou ficheiro no diretório de backup está mais atualizado
                        continue
                    fi
                fi

            else                                                                    # não existe no diretório de backup um ficheiro com o mesmo nome
        
                if $checking; then
                    echo "cp -a $file $dir_backup"                                  # printa os comandos estando no modo checking
        
                else
                    cp -a "$file" "$dir_backup"                                     # executa os comandos não estando no modo checking
                    #echo -e "\n>> Copyed \"$file\" to \"$dir_backup\"."
                    echo "cp -a $file $dir_backup/$fname"
                fi
            fi  
        else 
            #echo -e "\n>> File \"$file\" will not be updated due to user input (tfile or regex)!"   # nome do ficherio conta na lista de ficherios a não alterar ou não aceita expressão regular passada
            continue
        fi

    else                                                                    # caso em que "item" é um diretório  precisamos tratar de fazer backup desse diretório recorrendo à chamada recursiva do script nesse novo diretório de trabalho e backup
        dir="$item"     
        subdir_name="${dir##*/}"                                            # extrair nome do diretório

        if [ ! -r "$dir" ] || [ ! -x "$dir" ]; then
            echo ">> ERROR: Directory \"$dir\" does not have sufficient permissions (read and execute). Skipping."
            continue
        fi
         
        if [ "$ret_val" -eq 0 ]; then 
            
            if [ -e "$dir_backup/$subdir_name" ]; then                          # verifica se existe no diretório de backup um diretório com o mesmo nome
                backed_dir=$dir_backup/$fname
                
                if $checking; then                                                                                  # imprimir comandos no modo checking. Imprimimos a forma como chamariamos o script porque não conseguimos por vezes chamar recursivamente o script com o "-c" pelo facto de os diretórios não existitem ainda
                    echo "$0 -c -b $tfile -r $regexpr $dir_trabalho/$subdir_name $dir_backup/$subdir_name"
                
                else    
                    #echo -e "\n>> Entered directory \"$dir\". Starting backing up..."                               # chamar script sobre os novos diretórios
                    $0 -b "$tfile" -r "$regexpr" "$dir_trabalho/$subdir_name" "$dir_backup/$subdir_name"
                fi
            
            else                                                                                                    # diretório não existe          
                if $checking; then
                    echo "mkdir $dir_backup/$subdir_name"                                                           # imprimir comandos no modo checking. Imprimimos a forma como chamariamos o script porque não conseguimos por vezes chamar recursivamente o script com o "-c" pelo facto de os diretórios não existitem ainda
                    echo "$0 -c -b $tfile -r $regexpr $dir_trabalho/$subdir_name $dir_backup/$subdir_name"

                else
                    mkdir "$dir_backup/$subdir_name"                                                                # criar diretório no diretório de backup e chamar script sobre esses novos diretórios
                    echo "mkdir $dir_backup/$subdir_name"
                    #echo -e "\n>> Created directory \"$dir_backup/$subdir_name\" in \"$dir_backup\""
                    $0 -b "$tfile" -r "$regexpr" "$dir_trabalho/$subdir_name" "$dir_backup/$subdir_name"
                fi
            fi 
        else 
            if ! $checking; then
                #echo -e "\n>> Directory \"$dir\" will not be updated due to user input (tfile)!"   # nome do diretorio conta na lista de ficherios/diretorios a não alterar 
                continue
            fi        
        fi
    fi
        
done




