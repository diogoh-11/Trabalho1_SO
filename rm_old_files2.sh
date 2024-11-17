#!bin/bash

# $1 = dir_trabalho
# $2 = dir backup

rm_old_files2(){

    dir_trabalho="$1"
    dir_backup="$2"
    checking="$3"
    write_to_file=false
    
    if [ $# -eq 4 ]; then
        temp_file="$4"                          # caso em que funcao recebe nome de ficheiro temporario para poder devolver ambos os valores
        write_to_file=true
    fi
    
    num_deleted_files=0
    bytes_deleted=0

    #if ! [ -z "$( ls -A "$dir_backup" )" ]; then             # garante q o dir n está vazio

        for item in "$dir_backup"/{*,.*}; do

            if [[ "$item" == "$dir_trabalho/." || "$item" == "$dir_trabalho/.." || "$item" == "$dir_trabalho/.*" || "$item" == "$dir_trabalho/*" ]]; then       # ignorar ".", ".." e ".*"
                continue
            fi

            if [ -f "$item" ]; then
                file="$item"
                file_size=$(wc -c < "$file") 
                fname="${file##*/}"

                if ! [ -e "$dir_trabalho/$fname" ]; then        # verifica se o ficherio ainda existe no dir de trabalho
                    
                    if $checking; then
                        echo "rm $dir_backup/$fname"            # printa os comandos estando no modo checking
                    else
                        file_size=$(wc -c < "$file")
                        rm "$dir_backup/$fname"                 # executa os comandos não estando no modo checking
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
                        echo "rm -r $dir"                           # printa os comandos estando no modo checking
                    else
                        dir_size=$(du -sb "$dir" | cut -f1)         # du retorna o nº de bytes e o nome do dir, então usamos o cut para extrair desse resultado apenas o valore de bytes
                        file_count=$(find "$dir" -type f | wc -l)   # Conta o número de arquivos dentro do diretório
                        ((bytes_deleted+=dir_size))                 # Soma o tamanho do diretório aos bytes deletados
                        ((num_deleted_files+=file_count))

                        rm -r "$dir"                                # executa os comandos não estando no modo checking
                        echo -e "\n>> Removed no longer existing directory \"$dir\" from \"$dir_backup\"."
                    fi
                fi
            fi
        done
    #fi

    if $write_to_file; then
        echo "$num_deleted_files" "$bytes_deleted" > "$temp_file"       # escrever valores em ficheiro temporário para serem lidos no script
    fi
}
