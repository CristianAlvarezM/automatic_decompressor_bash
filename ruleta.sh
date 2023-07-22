#!/bin/bash
 
#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
 
function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${redColour}\n"
  tput cnorm; exit 1
}
 
# Ctrl+C
trap ctrl_c INT
 
function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}${purpleColour} $0${endColour}\n"
  echo -e "\t${blueColour}-m)${endColour}${grayColour} Dinero con el que se desea jugar${grayColour}"
  echo -e "\t${blueColour}-t)${endColour}${grayColour} Técnica a ultilizar${grayColour}${purpleColour} (martingala / inverseLabrouchere)${endColour}\n"
  exit 1
}

function martingala(){
  echo -e "\n${yellowColour}[+]${endColur}${grayColour} Dinero actual:${endColour}${yellowColour} $money$ ${endColour}"
  echo -ne "${yellowColour}[+]${endColour}${grayColour} ¿Cuánto dinero quieres apostar? -> ${endColour}" && read initial_bet
  echo -ne "${yellowColour}[+]${endColour} ${grayColour}¿A qué deseas apostar continuamente (par/impar)? -> ${endColour}" && read par_impar
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Vamos a jugar con una cantidad inicial de${endColour}${yellowColour} $initial_bet$ ${endColour}${grayColour}a${endColour} ${yellowColour}$par_impar${endColour}"

backup_bet=$initial_bet
play_counter=1
jugadas_malas=""

#  max_dinero_ganado=0 "Esto es para saber el tope de dinero que se ganó"

tput civis # Ocultar cursor
while true; do
  money=$(($money-$initial_bet))
# echo -e "\n${yellowColour}[+]${endColour}${grayColour} Acabas de apostar${endColour} ${yellowColour}$initial_bet$ ${endColour}${grayColour} y tienes${endColour}${yellowColour} $money$ ${endColour}"
  random_number="$(($RANDOM % 37))"
#  echo -e "${yellowColour}[+]${endColour}${grayColour} Ha Salido el número ${endColour}${yellowColour}$random_number${endColour}"
  if [ ! "$money" -le 0 ]; then
    if [ "$par_impar" == "par" ]; then
      if [ "$(($random_number % 2))" -eq 0 ]; then
        if [ "$random_number" -eq 0 ]; then
#         echo -e "${redColour}[!] Ha salido el número 0, por lo tanto has perdido${endColour}"
          initial_bet=$(($initial_bet*2))
          jugadas_malas+="$random_number "
#         echo -e "${yellowColour}[+]${endColour}${yellowColour} Ahora mismo tiene${endColour}${yellowColour} $money$ ${endColour}"  
        else
#         echo -e "${yellowColour}[+]${endColour}${greenColour} El número que ha salido es par, ¡ganas!${endColour}"
          reward=$(($initial_bet*2))
#         echo -e "${yellowColour}[+]${endColour}${grayColour} Ganas un total de ${endColour}${yellowColour}$reward$ ${endColour}"
          money=$(($money+$reward))
#         echo -e "${yellowColour}[+]${endColour}${grayColour} Tienes${endColour}${yellowColour} $money$ ${endColour}"
#         if [ "$money" -gt "$max_dinero_ganado" ]; then
#           max_dinero_ganado=$money
#          fi
          initial_bet=$backup_bet
          jugadas_malas="" 
        fi
    else
 #      echo -e "${yellowColour}[+]${endColour}${redColour} El número que ha salido es impar, ¡pierdes!${endColour}"
        initial_bet=$(($initial_bet*2))
        jugadas_malas+="$random_number "
 #      echo -e "${yellowColour}[+]${endColour}${yellowColour} Ahora mismo tiene${endColour}${yellowColour} $money$ ${endColour}"
      fi
    fi
  else
      # No hay plata
      echo -e "\n${redColour}[!] Te has quedado sin plata${endColour}\n"
      echo -e "${yellowColour}[+]${endColour}${grayColour} Han habido un tolal de${endColour}${yellowColour} $play_counter${endColour}${grayColour} jugadas${endColour}"
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Malas jugadas consecutivas:${endColour}\n"
      echo -e "${blueColour}$jugadas_malas${endColour}"
 #    echo -e "\n[+] El maximo dinero ganado fue:"
 #    echo -e "${greenColour}$max_dinero_ganado${endColour}"
      tput cnorm; exit 0
  fi
     let play_counter+=1
  done
  tput cnorm
 }

while getopts "m:t:h" arg; do
  case $arg in
    m) money=$OPTARG;;
    t) technique=$OPTARG;;
    h) helpPanel;;
  esac
done
 
if [ $money ] && [ $technique ]; then 
  if [ "$technique" == "martingala" ]; then
    martingala
  else
    echo -e "\n${redColour}[!]La técnica introducida no existe${endColour}"
    helpPanel
  fi
else
  helpPanel
fi