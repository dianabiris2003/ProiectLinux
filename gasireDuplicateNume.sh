gasire_duplicate_nume() {

    echo "Se executa functia: gasire_duplicate_nume()" >> out.log
    local director="$1"

    #verificam daca sunt destule argumnete
    if [[ -z $director ]]; then
        echo "Nu sunt destule argumente" | tee -a out.log >&2
        return 1
    fi

    #verificam daca exista directorul
    if [[ ! -d "$director" ]]; then
        echo "Directorul nu exista" | tee -a out.log >&2
        return 1
    fi

    #Cautam fisierele si extragem doar numele acestora(fara cale)
    #Renuntam la extensie si le sortam in functie de nume
    #uniq -d este folosit pentru a identifica si lista doar elementele care se repeta(numele fisierelor)
    find "$director" -type f | sed 's|.*/||' | sed 's/\.[^.]*$//' | sort | uniq -d | while read -r nume; do
        echo "Duplicatele fara extensie cu numele: '$nume':"
        find "$director" -type f -name "*$nume*" -print
        echo "-----------------------------"
    done
    
    echo "Functia a fost executata!" >> out.log
}


gasire_duplicate_nume "$1"
