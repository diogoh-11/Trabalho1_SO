#!bin/bash

# $1 = dir_trabalho
# $2 = dir backup

rm_old_files2(){
    dir_trabalho="$1"
    dir_backup="$2"
    checking="$3"
    num_deleted_files=0;

    if ! [ -z "$( ls -A $dir_backup )" ]; then             # garante q o dir n está vazio

        for item in "$dir_backup"/{*,.*}; do

            if [[ "$item" == "$dir_trabalho/." || "$item" == "$dir_trabalho/.." || "$item" == "$dir_trabalho/.*" ]]; then 
                continue
            fi

            if [ -f "$item" ]; then
                file="$item"
                fname="${file##*/}"

                if ! [ -e "$dir_trabalho/$fname" ]; then        # verifica se o ficherio ainda existe no dir de trabalho
                    
                    if $checking; then
                        echo "rm $dir_backup/$fname"           # printa os comandos estando no modo checking
                    else
                        file_size=$(wc -c < "$file")
                        rm "$dir_backup/$fname"              # executa os comandos não estando no modo checking
                        ((bytes_deleted+=file_size))
                        ((num_deleted_files+=1))
                        echo -e "\n>> Removed no longer existing file \"$file\" from \"$dir_backup\"."
                    fi
                fi

            elif [ -d "$item" ]; then
                dir=$item
                dir_name="${dir##*/}"

                if ! [ -e "$dir_trabalho/$dir_name" ]; then        # verifica se o diretorio ainda existe no dir de trabalho
                    
                    if $checking; then
                        echo "rmdir $dir"           # printa os comandos estando no modo checking
                    else
                        dir_size=$(du -sb "$dir" | cut -f1)
                        file_count=$(find "$dir" -type f | wc -l)  # Conta o número de arquivos dentro do diretório
                        ((bytes_deleted+=dir_size))  # Soma o tamanho do diretório aos bytes deletados
                        ((num_deleted_files+=file_count))

                        rm -r "$dir"              # executa os comandos não estando no modo checking
                        echo -e "\n>> Removed no longer existing directory \"$dir\" from \"$dir_backup\"."
                    fi
                fi
            fi
        done
    fi

    return $num_deleted_files   #se num de ficheiros eliminados for maior que 255 n retorno o valor desejado!
}
