#!/bin/env bash

# tworzy zestawienie najwiekszych plików w katalogu
# dutop.sh katalog liczba_wynikow (domyslnie 10) 

DIR=${1%/}
HEAD_CNT=${2:-10}
UNIT=${3:-M}

top=$(du -s --block-size=${UNIT} $DIR/* | sort -rn -k1 | head -n $HEAD_CNT)

printf '%s' "$top"

sum=$(echo "$top" | awk -F ${UNIT} '{print $1}' | awk '{ sum += $1 } END { print sum }')

printf '\n\nRazem: %s%s\n' "$sum" "$UNIT"
