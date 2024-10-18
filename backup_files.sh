#!/bin/bash

while getopts "c" option; do
    case $option in
        c)
            echo "Opção de checking ativa!"
            ;;
        *)
            echo "Usage: $0 [-c] dir_trabalho dir_backup"
            ;;
    esac
done

#validação dos argumentos:

#if [-d ]