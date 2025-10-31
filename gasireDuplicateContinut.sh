gasire_duplicate() {
    echo "Se executa functia: gasire_duplicate()" >> out.log
    local director=$1 

    #verificam daca avem argumente
    if [[ -z $director ]]; then
        echo "Nu sunt destule argumente" | tee -a out.log >&2
        return 1
    fi

    #verificam daca directorul introdus exista
    if [[ ! -d $director ]]; then
        echo "Directorul nu exista" | tee -a out.log >&2
        return 1
    fi

    #Cautam fisierele duplicate si le afisam mesaj cand se intalnesc
    #Parcurgem fisierele din director, verificand daca sunt fisiere si le comparam intre ele cu ajutorul lui cmp, cu conditia ca fisierul sa fie diferit de sine insusi
    find "$director" -type f | while read -r file1; do
        find "$director" -type f | while read -r file2; do
            if [ "$file1" != "$file2" ] && cmp -s "$file1" "$file2"; then
                echo "Fisierul $file1 are acelasi continut ca fisierul $file2" | tee -a out.log
            fi
        done
    done
    
    echo "Functia a fost executata!" >> out.log
}

gasire_duplicate "$1"
