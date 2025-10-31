#!/bin/bash

cautare_dupa_permisiuni() {
    dir=$1

    if [[ ! -d "$dir" ]]; then
        echo "Eroare: Directorul '$dir' nu exista." | tee -a out.log >&2
        exit 1
    fi

    echo "Introduceti permisiunile dorite in cuvinte (ex: read, write, execute):"
    read -r perms
    perm_code=""
    case "$perms" in
        read) perm_code="r" ;;
        write) perm_code="w" ;;
        execute) perm_code="x" ;;
        read,write) perm_code="rw" ;;
        read,execute) perm_code="rx" ;;
        write,execute) perm_code="wx" ;;
        read,write,execute) perm_code="rwx" ;;
        *)
            echo "Eroare: Permisiuni invalide. Folositi read, write sau execute." | tee >(cat >&2) >> out.log
            exit 1
            ;;
    esac

    echo "Cautam fisierele din '$dir' cu permisiunile '$perms':" | tee -a out.log >&2
    # Gasim fisierele care au permisiunile specificate
    find "$dir" -type f -perm -u=$perm_code
}

cautare_dupa_permisiuni "$1"
