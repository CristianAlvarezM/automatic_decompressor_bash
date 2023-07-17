#!/bin/bash

function ctrl_c(){
  echo e- "\n\n [!]Saliendo..."
  exit 1
}

#Ctrl+C
trap ctrl_c INT

for port in $(seq 1 65535); do
  (echo '' > /dev/tcp/127.0.0.1/$port) 2>/den/null && echo "[+] $port - OPEN" &
done; wait