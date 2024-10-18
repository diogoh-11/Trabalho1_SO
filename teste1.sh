#!/bin/bash

# Using getopts to handle custom flags
while getopts "ab:c:" option; do  # The colon after 'b' means it expects an argument.
  case $option in
    a) 
        echo "Hello!"  # If -a is passed
        ;;
    b)
        echo "The value passed with -b is: $OPTARG"  # If -b is passed with a value
        ;;
    c)
        echo "The value passed with -c is: $OPTARG"  # If -c is passed with a value
        ;;
    *)
      echo "Usage: $0 [-a] [-b value]"  # Display usage if an unrecognized flag is passed
      ;;
  esac
done

# função que compara dois ficherios com o mesmo nome e retorna aquele que é mais recente
comp_files(){
    file1=$1; file2=$2
    date_file1=$(date -r $file1 "+%m-%d-%Y %H:%M:%S")
    date_file2=$(date -r $file2 "+%m-%d-%Y %H:%M:%S")
    echo "$date_file1"
    echo "$date_file2"
}

comp_files $1 $2

