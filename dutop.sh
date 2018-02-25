#!/bin/env bash

# tworzy zestawienie najwiekszych plików w katalogu
# dutop.sh katalog liczba_wynikow (domyslnie 10) 

DIR=${1%/}
HEAD_CNT=${2:-10}
du -s --block-size=MB $DIR/* | sort -rn -k1 | head -n $HEAD_CNT
