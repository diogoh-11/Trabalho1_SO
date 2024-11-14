#!/bin/bash
# Função que recebe o array com os nomes dos ficheiros/diretoria a nao alterar
# e o nome do ficheiro/diretoia que esta a ser iterado e verifica se 
# esse ficherio conta nessa lista

in_array(){
    local check=$1                              # Primeiro argumento é o valore de check (valor que queremos ver se se encontra no array)
    shift                                       # Shift para acessar os argumentos do array
    local array=("$@")                          # Os argumentos restantes são os valores do array
    
    for item in ${array[@]}; do                 # Iterar pelos itens do array
        if [ "$item" == "$check" ]; then        # Caso em que o item iterado coincide com o valor que foi dado como input
            return 1                            # retornar  1 (valor input consta no array)
        fi
    done

    return 0                                    # retornar  0 (valor input NÃO consta no array)
}