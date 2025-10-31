#!/bin/bash

restaurare_fisiere() {

  echo "Se executa functia restaurare_fisiere()" >> out.log
  # Directorul cos_gunoi
  cos_gunoi="cos_gunoi"

  # Directorul unde vor fi mutate fisierele restaurate
  fisiere_restaurate="fisiere_restaurate"

  # Verificam daca exista directorul cos de gunoi
  if [ ! -d "$cos_gunoi" ]; then
    echo "Directorul '$cos_gunoi' nu exista!" | tee -a out.log >&2
    exit 1
  fi

  # Cream directorul fisiere_restaurate daca nu exista
  mkdir -p "$fisiere_restaurate"

  # Cerem utilizatorului sa specifice fisierul sau tipul de fisiere
  echo "Introduceti numele fisierului sau un sablon (ex: *.txt):"
  read -r input

  # Verificam daca exista fisiere care corespund sablonului
  fisiere_de_mutat=$(find "$cos_gunoi" -type f -name "$input")

  # Verificam daca exista fisiere gasite
  if [ -z "$fisiere_de_mutat" ]; then
    echo "Nu au fost gasite fisiere care sa corespunda sablonului '$input'." | tee -a out.log >&2
    exit 0
  fi

  # Mutam fisierele care corespund sablonului
  for fisier in $fisiere_de_mutat; do
    # Preluam numele fisierului, fara calea completa
    nume_fisier=$(basename "$fisier")
    
    # Efectuam mutarea
    mv "$fisier" "$fisiere_restaurate/$nume_fisier"
    echo "Fisier mutat: $nume_fisier -> $fisiere_restaurate" | tee -a out.log
  done
  
  echo "S-a incheiat executia!" >> out.log
}

