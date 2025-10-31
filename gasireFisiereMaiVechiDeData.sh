#!/bin/bash

# Converteste data introdusa de utilizator in formatul standard yyyy-mm-dd si verifica daca o data este valida si se potriveste cu o data calendaristica acceptata
convert_data() {

  echo "Se executa functia: convert_data()" >> out.log
  local data="$1"
  
  if [[ $data =~ ^[0-9]{4}/[0-9]{2}/[0-9]{2}$ ]]; then
    echo "$data" | sed 's@/@-@g'
  elif [[ $data =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "$data"
  elif [[ $data =~ ^[0-9]{4}\.[0-9]{2}\.[0-9]{2}$ ]]; then
    echo "$data" | sed 's@\.@-@g'
  elif [[ $data =~ ^[0-9]{2}/[0-9]{2}/[0-9]{4}$ ]] || [[ $data =~ ^[0-9]{2}-[0-9]{2}-[0-9]{4}$ ]] || [[ $data =~ ^[0-9]{2}\.[0-9]{2}\.[0-9]{4}$ ]]; then
    local delim="/"
    
    # Determinam delimitatorul
    if [[ $data =~ "-" ]]; then 
      delim="-"
    elif [[ $data =~ \. ]]; then 
      delim="."
    fi

    # Extragem ziua luna anul
    ziua=$(echo "$data" | awk -F"$delim" '{print $1}' | sed 's/^0*//')
    luna=$(echo "$data" | awk -F"$delim" '{print $2}' | sed 's/^0*//')
    anul=$(echo "$data" | awk -F"$delim" '{print $3}')

    # Verificam conditii de baza
    if (( ziua == 0 || luna == 0 )); then
      echo "Ziua sau luna nu pot fi 0!" | tee -a out.log >&2
      exit 1
    elif (( ziua > 12 && luna <= 12 )); then
      ziua_noua=$ziua
      luna_noua=$luna
    elif (( ziua <= 12 && luna > 12 )); then
      ziua_noua=$luna
      luna_noua=$ziua
    elif (( ziua <= 12 && luna <= 12 )); then
      ziua_noua=$ziua
      luna_noua=$luna
    else
      echo "Nu exista asemenea data in calendar" | tee -a out.log >&2
      exit 1
    fi

    # Verificam datele calendaristice sa fie ca in calendar
    if (( ziua_noua > 31 )); then
      echo "Nu exista asemenea data in calendar" | tee -a out.log >&2
      exit 1
    elif (( ziua_noua == 31 && luna_noua != 1 && luna_noua != 3 && luna_noua != 5 && luna_noua != 7 && luna_noua != 8 && luna_noua != 10 && luna_noua != 12 )); then
      echo "Nu exista asemenea data in calendar!" | tee -a out.log >&2
      exit 1
    elif (( ziua_noua == 30 && luna_noua != 4 && luna_noua != 6 && luna_noua != 9 && luna_noua != 11 )); then
      echo "Nu exista asemenea data in calendar!" | tee -a out.log >&2
      exit 1
    elif (( ziua_noua == 29 && luna_noua == 2 && ! ((anul % 4 == 0 && (anul % 100 != 0 || anul % 400 == 0))))); then
      echo "Nu exista asemenea data in calendar!" | tee -a out.log >&2
      exit 1
    else
      printf "%04d-%02d-%02d\n" "$anul" "$luna_noua" "$ziua_noua" | tee -a out.log
    fi
  else
    echo "Format invalid. " | tee -a out.log >&2
    exit 1
  fi
  
  echo "Functia a fost executata!" >> out.log
}

# Calculam data corespunzatoare duratei de timp introduse de utilizator
calculam_data() {
  
  echo "Se executa functia: calculam_data()" >> out.log
  local input=$1
  
  # Verificam dacă input-ul este valid
  if [[ $input =~ ^[0-9]+[dwmy]$ ]]; then
    local unit=${input: -1}
    local value=${input%?}
    local offset
    
    case $unit in
      d) offset="${value} days ago" ;;
      w) offset="$(($value * 7)) days ago" ;;
      m) offset="${value} months ago" ;;
      y) offset="${value} years ago" ;;
      *) echo "Unitate de timp invalida" | tee -a out.log >&2; return 1 ;;
    esac

    # Calculam data
    local target_date=$(date -d "$offset" +%Y-%m-%d)
    echo "$target_date"
    return 0
  else
    echo "Format invalid." | tee -a out.log >&2
    return 1
  fi
  
  echo "Functia a fost executata!" >> out.log
}

# Gasim fisierele care indeplinesc conditiile
gasire_fisiere() {
  dir="$1"

  # Verificam daca directorul este valid
  if [[ ! -d "$dir" ]]; then
    echo "Director invalid: $dir" | tee -a out.log >&2
    exit 1
  fi

  echo  "Introduceti data calendaristica dorita sau durata de timp cu sufixul corespunzator(d,w,m,y) ."
  echo
  echo "In cazul ati ales o data calendaristica in  care atat ziua cat si luna sunt mai mici decat 12 sa tineti cont ca formatul default va fi de forma DD/MM/YYYY. Multumesc"

  read input

  if [[ $input =~ ^[0-9]{4}[-/.][0-9]{2}[-/.][0-9]{2}$ ]] || [[ $input =~ ^[0-9]{2}[-/.][0-9]{2}[-/.][0-9]{4}$ ]]; then
    data=$(convert_data "$input")
  elif [[ $input =~ ^[0-9]+[dwmy]$ ]]; then
    data=$(calculam_data "$input")
  else
    echo "Input invalid." | tee -a out.log >&2
    exit 1
  fi

  echo "Se cauta fisiere mai vechi de $data"

  # Folosim find pentru a căuta fișierele mai vechi de data specificata
  # cu ajutorul lui -not -newermt aflam daca fisierul nu este mai nou modificat decat data introdusa
  find "$dir" -type f -not -newermt "$data"
}
