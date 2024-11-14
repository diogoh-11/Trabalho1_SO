#!/bin/bash

dir_trabalho="$1"
dir_backup="$2"
igual="true"

checkrec(){

    local dir1="$1"
    local dir2="$2"                                     # Definir variáveis locais
    local differ="false"
    

    for item2 in "$dir2"/{*,.*}; do
        
        if [ -f "$item2" ];then                         # Verifica se o item na diretoria de backup é um ficheiro existente
            item1="$dir1/$(basename "$item2")"          # A partir do ficherio item2 da diretoria de backup, definimos item1 como o ficherio que deveria estar na diretoria de trabalho 
            
            if [ -f "$item1" ];then                     # Verifica se ficheiro item1 existe na dir1 (diretoria de trabalho)

                if [ "$(md5sum "$item2" | awk '{ print $1 }')" != "$(md5sum "$item1" | awk '{ print $1 }')" ]; then         # usar o comando md5sum com auxilio de awk para retirar apenas a informação relevante e verificar se os ficherios diferem
                    echo -e "\n>> \""$item2"\" \""$item1"\" differ."                                                        # ficherio em diretoria de backup é diferente do que o ficherio na diretoria de trabalho
                    differ="true"                                                                                           # atribuir à variável "differ" o valor true, visto que os ficheiros são diferentes
                fi
            
            else                                                            # Caso em que o ficheiro que está na diretoria de backup não existe na diretoria de trabalho
                echo -e "\n>> \""$item2"\" not in \""$dir_trabalho"\""      # Imprimir mensagem relevante
                differ="true"                                               # atribuir à variável "differ" o valor true, visto que o ficheiro não existe na diretoria de trabalho
            fi

        elif [ -d "$item2" ]  ; then                                        # Caso em que o item do diretorio de backup é uma diretoria, será necessario chamar a função recurssivamente

            item1="$dir1/$(basename "$item2")"                              # Suposto nome/path do diretorio que se deveria encontrar na diretoria de trabalho
            
            if [ -d "$item1" ];then                                         # Verificar se existe na forma de diretorio o item1 acima definido
                checkrec "$item1" "$item2"
            
            else
                echo -e "\n>> \""$item2"\" not in \""$dir_trabalho"\""      # Imprimir mensagem caso diretoria na diretoria de backup não se encontre na diretoria de trabalho 
                differ="true"                                               # Atribuir à variável "differ" o valor true, visto que a diretoria não existe na diretoria de trabalho   
            fi
        fi
    done

    if $differ;then
        igual="false"                   # Atualizar variàvel que representa a igualdade dos diretorios
    fi
}

checkrec "$dir_trabalho" "$dir_backup"  #Chamar a função para comparar o dir_backup com dir_trabalho

if $igual; then
    echo -e ">> All correspondent items in dir_backup are in dir_trabalho !!!"    # Diretorias de trabalho e backup são iguais
fi

