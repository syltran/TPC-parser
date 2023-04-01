make
> rapport_tests.txt

score=0
nb_tests=0

for file in test/*/*
do 
    # echo $file
    ./bin/tpcas < $file
    val=$? # récupère le code de retour de yyparse() avec $?
    echo $file ":" $val >> rapport_tests.txt

    if [ $(egrep "test/good/*" <<< "${file}") ] # teste si le fichier file est dans test/good
    then
        if [ $val -eq 0 ] # s'il n'y a pas d'erreur lexicale ni syntaxique 
        then
            score=$(($score+1))
        fi
    else # le fichier file est dans test/syn-err
        if [ $val -eq 1 ] # s'il y a une erreur
        then
            score=$(($score+1))
        fi
    fi

    nb_tests=$(($nb_tests+1))
done

echo "final score :" $score "/" $nb_tests >> rapport_tests.txt


# Pour exécuter un script shell :
# chmod +x nom_du_script.sh
# ./nom_du_script.sh