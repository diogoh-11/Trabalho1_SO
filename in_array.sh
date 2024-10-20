#!/bin/bash
# Função que recebe o array com os nomes dos ficheiros a nao alterar
# e o nome do ficheiro que esta a ser iterado e verifica se 
#esse ficherio conta nessa lista

in_array(){
    local check=$1      # The first argument is the value to check
    shift               # Shift the arguments to access the array
    local array=("$@")  # Remaining arguments are the array elements
    
    for item in ${array[@]}; do
        if [ "$item" == "$check" ]; then
            return 1
        fi
    done

    return 0
}