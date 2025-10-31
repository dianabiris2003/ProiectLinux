#!/bin/bash

# functie pentru stergerea fisierelor mai vechi de 60 de zile  -- NU VA FI APELATA IN MENIU
sterge_fisiere_vechi() {

    echo "Se executa functia sterge_fisiere_vechi()" >> out.log
    director="$1"

    if [ ! -d "$director" ]; then
        echo "Eroare: Directorul '$director' nu exista." | tee -a out.log >&2
        return
    fi
    # cauta fisierele mai vechi de 60 de zile si le sterge
    find "$director" -type f -mtime +60 -exec rm -f {} \;
    echo "Fisierele mai vechi de 60 de zile au fost sterse din '$director'." | tee -a out.log 
    echo "Functia a fost executata!" >> out.log
}

# functie pentru programarea stergerii in fiecare luni la ora 20:00   -- va fi apelata in meniu: stergere_programata <nume_director>
stergere_programata() {
	
    echo "Se executa functia stergere_programata()" >> out.log
    director="$1"

    if [ ! -d "$director" ]; then
        echo "Eroare: Directorul '$director' nu exista." | tee -a out.log >&2
        return
    fi
    # salvam calea scriptului
    script_path="$PWD/$(basename "$0")"
    # specificam ce va fi scris in crontab (se va executa scriptul lunea la ora 20:00)
    cron_entry="0 20 * * 1 $script_path sterge_fisiere_vechi \"$director\""

    # Verifica daca cronjob-ul exista deja
    if ! crontab -l 2>/dev/null | grep -F "$cron_entry" >/dev/null; then
        (crontab -l 2>/dev/null; echo "$cron_entry") | crontab -
        echo "Cronjob adaugat: Sterge fisierele mai vechi de 60 de zile in fiecare luni la ora 20:00 din '$director'." | tee -a out.log
    else
        echo "Cronjob-ul exista deja." | tee -a out.log >&2
    fi
    echo "Functia a fost executata!" >> out.log
}
