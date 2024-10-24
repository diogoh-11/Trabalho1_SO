# Trabalho1_SO
https://medium.com/@wujido20/handling-flags-in-bash-scripts-4b06b4d0ed04
https://linuxize.com/post/bash-functions/
https://www.uptimia.com/questions/how-to-compare-file-dates-in-bash
https://superuser.com/questions/352289/bash-scripting-test-for-empty-directory
https://www.masteringunixshell.net/qa40/bash-how-to-pass-array-to-function.html

# Ativa a opção para pegar arquivos e pastas ocultas
        shopt -s dotglob

# Desativa a opção para pegar arquivos e pastas ocultas
        shopt -u dotglob

touch 1
touch 2
touch 3
touch 4
touch 5
touch 6
touch 7
mkdir d1
mkdir d2
cd d1
touch a
touch b
touch c
cd ..
cd d2
mkdir d21
touch d
touch e
touch f
cd d21
touch 11
touch 12
touch 13
mkdir k
cd k
touch k1
touch k2
touch k3
cd ..
touch .hiddenf