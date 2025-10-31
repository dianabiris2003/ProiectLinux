#!/bin/bash

organizaredimensiune() {
    dir=$1  

    if [[ ! -d "$dir" ]]; then
        echo "Eroare: Directorul '$dir' nu exista." | tee -a out.log >&2
        exit 1
    fi

    echo "Organizam fisierele din directorul '$dir' dupa dimensiune:"

    # Afiseaza fisierele sortate dupa dimensiune in ordine descrescatoare
    find "$dir" -type f -exec du -h {} + | sort -rh | awk '{print $2}'
}



organizaredimensiune "$1"
