#!/bin/bash

#Functie care preia ca argument numele directorului in care se gasesc fisierele dorite si numele destinatiei in care vrea utilizatorul sa mute fisierele 
# folosim xargs si mutam toate fisierele care au fost gasite folosind mv in destinatie
mutare_fisier_local() {
    echo "Se executa functia: mutare_fisier_local()" >> out.log
    sursa="$1"
    destinatie="$2"
    
    # Verificam dacă sursa exista si este un director
    if [ ! -d "$sursa" ]; then
        echo "Locatia sursa $sursa nu exista pe acest dispozitiv." | tee -a out.log >&2
        return 1
    fi

    # Verificam daca destinatia exista, daca nu, o cream
    if [ ! -d "$destinatie" ]; then
        echo "Locatia destinatie $destinatie nu exista pe acest dispozitiv." | tee -a out.log
        if mkdir -p "$destinatie"; then
            echo "Locatia destinatie $destinatie a fost creata cu succes." | tee -a out.log
        else
            echo "Eroare la crearea directorului $destinatie" | tee -a out.log >&2
            return 1
        fi
    else
        echo "Locatia destinatie $destinatie exista deja pe acest dispozitiv." | tee -a out.log
    fi

    # folosim realpath pentru a extrage calea absoluta atat [entru sursa cat si pentru destinatie 
    # verificam daca cele doua sunt acelasi lucru pentru a evita eroarea cauzata de suprascrierea fisierelor 
    cale_absoluta_sursa=$(realpath "$sursa")
    cale_absoluta_destinatie=$(realpath "$destinatie")
    
    if [ "$cale_absoluta_sursa" = "$cale_absoluta_destinatie" ]; then 
    	echo "Eroare: sursa si destinatia sunt identice. Introduceti o destinatie diferita de sursa "  | tee -a out.log >&2
    	return 1
    fi 
    # extragem in nume_script numele scriptului 
    # folosim $0 pentru a extrage calea curenta spre script , iar folosind basename extragem doar numele propriu zis
    # folosim grep -v pentru a exclude din fisiere scriptul curent
    nume_script="$(basename "$0")"
    find "$sursa" -type f -print0 | grep -z -v "$nume_script" | xargs -0 -I {} mv {} "$destinatie" \
        && echo "Fisierele au fost mutate cu succes in $destinatie." | tee -a out.log \
        || echo "Eroare la mutarea fisierelor în $destinatie." | tee -a out.log >&2
}


#Functie care asigura atat configurarea git ului cat si a Github ului 
configurare_git(){
    #realizeaza configurarea locala a user ului si a email ului 
    echo "Introduceți username-ul pentru Git:"
    read -r user
    
    echo "Introduceți email-ul pentru Git:"
    read -r email
    
     if git config --global user.name "$user" && git config --global user.email "$email"; then
        echo "Configurarea globala a utilizatorului și a email-ului pentru Git a fost realizată cu succes." | tee -a out.log
    else
        echo "Eroare la configurarea globala a utilizatorului sau email-ului." | tee -a out.log >&2
        return 1
    fi
    
    # Verificam daca directorul curent este un repository Git valid
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Repository-ul git este deja inițializat." | tee -a out.log 
    else
        git init && echo "Repository-ul git a fost initializat cu succes." | tee -a out.log  || echo "Eroare la initializarea repository-ului." | tee -a out.log >&2
    fi
      # Verificare și configurare remote pentru GitHub
    if git remote get-url origin >/dev/null 2>&1; then
        echo "Remote-ul pentru GitHub e configurat: $(git remote get-url origin)" | tee -a out.log 
    else
        echo "Remote-ul pentru GitHub nu este inca configurat." | tee -a out.log 
        echo "Introduceti URL-ul repository-ului dumneavoastra de GitHub : " 
        read link_GitHub
        git remote add origin "$link_GitHub" && echo "Remote-ul GitHub a fost configurat cu succes." ||  echo "Au fost intampinate probleme la configurarea remote-ului GitHub."
    fi
    
    # Verificare autentificare GitHub
    branch=$(git branch --show-current)
    if [ -z "$branch" ]; then
        echo "Nu exista un branch curent." | tee -a out.log
        git checkout -b main && echo "Branch ul main a fost creat cu succes " | tee -a out.log ||  echo "Branch-ului 'main' nu a putut fi creat." | tee -a out.log >&2
        branch="main"
    fi
    # se simuleaza un push pentru git fara a l realiza 
    # daca simularea esueaza inseamna ca este necesara autentificarea
    if ! git push --dry-run origin "$branch" >/dev/null 2>&1; then
        echo "Este necesar sa va autentificati pe GitHub. Configurati un token personal pe platforma de Github" | tee -a out.log 
        return 1
    fi
    echo "Repository-ul este configurat corect pentru GitHub." | tee -a out.log 
}


#Functie care adauga fisierul specificat de utilizator in git , dar si sincronizarea intr o locatie externa (GitHub)
adaugare_fisier_in_git(){
   configurare_git
   fisier=$1
   if [ ! -f "$fisier" ]; then
       echo "Fisierul $fisier nu exista."  | tee -a out.log >&2
       touch "$fisier" && echo "Fisierul $fisier a fost creat cu succes" | tee -a out.log || echo "Eroare la crearea fișierului $fisier" | tee -a out.log >&2
   fi
   #verificam daca fisierul se gaseste deja in Git 
   if git ls-files --error-unmatch "$fisier" >/dev/null 2>&1; then
       if git diff --quiet "$fisier"; then
           echo "Fisierul $fisier exista deja in Git. Acesta nu a fost actualizat, astfel nu necesita readaugare in Git" | tee -a out.log
       else
           echo "Fișierul $fisier exista deja in Git, dar a fost modificat local. Actualizam $fisier în Git" | tee -a out.log
           git add "$fisier" && echo "Fisierul a fost adaugat cu succes in staging area " | tee -a out.log || echo "Au fost intampinate probleme la adaugarea in staging area " | tee -a out.log >&2
           git commit -m "Actualizare fisier $fisier" | tee -a out.log  || echo "Commit ul nu poate fi realizat." | tee -a out.log >&2
       fi
   else
       git add "$fisier"
       git commit -m "Am adaugat fisierul $fisier in Git" | tee -a out.log  || echo "Commit ul nu poate fi realizat." | tee -a out.log >&2
   fi
   ## obtinem branch ul curent
   branch_curent=$(git branch --show-current)
   if [ -z "$branch_curent" ]; then
       echo "Nu exista un branch curent activ." | tee -a out.log 
       ## cream un branch numit main si ne mutam pe acesta folosind comanda git checkout -b 
       ## puteam folosi pentru a crea branch si comanda git branch insa nu ne si muta pe aceasta
       git checkout -b main && echo "Branch ul main a fost creat cu succes" | tee -a out.log ||  echo "Branch-ului 'main' nu a putut fi creat " | tee -a out.log >&2
       branch_curent="main"
   fi
   git push -u origin "$branch_curent" && echo "Fisierul $fisier a fost adăugat cu succes în Git si sincronizat cu GitHub." | tee -a out.log ||  echo "Eroare la sincronizarea cu GitHub." | tee -a out.log >&2
}


mutare_fisier_local /home/student/Desktop/testare2 /home/student/Desktop/testare2
