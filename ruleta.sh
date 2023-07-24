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
  backup_bet=$initial_bet
  play_counter=1
  jugadas_malas=""
  
  tput civis # Ocultar cursor
  while true; do
    money=$(($money-$initial_bet))
    random_number="$(($RANDOM % 37))"
    if [ ! "$money" -lt 0 ]; then
      if [ "$par_impar" == "par" ]; then
        #Todo esto es para cuando se apuesta a "par"
        if [ "$(($random_number % 2))" -eq 0 ]; then
          if [ "$random_number" -eq 0 ]; then
            initial_bet=$(($initial_bet*2))
            jugadas_malas+="$random_number "
          else
            reward=$(($initial_bet*2))
            money=$(($money+$reward))
            initial_bet=$backup_bet
            jugadas_malas="" 
          fi
        else
          initial_bet=$(($initial_bet*2))
          jugadas_malas+="$random_number "
        fi
      else
        #Todo esto es para cuando se apuesta a "impar"
        if [ "$(($random_number % 2))" -eq 1 ]; then
          reward=$(($initial_bet*2))
          money=$(($money+$reward))
          initial_bet=$backup_bet
          jugadas_malas=""
        else
          initial_bet=$(($initial_bet*2))
          jugadas_malas+="$random_number "
        fi
      fi
    else
      # No hay plata
      echo -e "\n${redColour}[!] Te has quedado sin plata${endColour}\n"
      echo -e "${yellowColour}[+]${endColour}${grayColour} Han habido un tolal de${endColour}${yellowColour} $(($play_counter-1))${endColour}${grayColour} jugadas${endColour}"
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Malas jugadas consecutivas:${endColour}\n"
      echo -e "${blueColour}[ $jugadas_malas]${endColour}"
      tput cnorm; exit 0
    fi
    let play_counter+=1
  done
  tput cnorm
}

function inverseLabrouchere(){
  echo -e "\n${yellowColour}[+]${endColur}${grayColour} Dinero actual:${endColour}${yellowColour} $money$ ${endColour}"
  echo -ne "${yellowColour}[+]${endColour} ${grayColour}¿A qué deseas apostar continuamente (par/impar)? -> ${endColour}" && read par_impar
  declare -a my_sequence=(1 2 3 4)
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Comemzamos con la secuencia ${endColour}${greenColour}[${my_sequence[@]}]${endColour}"

  bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
  jugadas_totales=0
  bet_to_renew=$(($money+50)) # Dinero el cual una vez alcanzado hará que renovemos nuestra secuencia [1 2 3 4]

  echo -e "${yellowColour}[+]${endColour}${grayColour} EL tope a renover la secuencia está establecido por encima de${endColour}${yellowColour} $bet_to_renew$ ${endColour}"

  tput civis
  while true; do
    let jugadas_totales+=1
    random_number=$(($RANDOM % 37))
    money=$(($money - $bet))
    if [ ! "$money" -lt 0 ]; then
      echo -e "${yellowColour}[+]${endColour}${grayColour} Invertimos ${yellowColour}$bet$ ${endColour}"
      echo -e "${yellowColour}[+]${endColour}${grayColour} Tenemos${endColour} ${yellowColour}$money$ ${endColour}"
      
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Ha salido el número${endColour}${blueColour} $random_number${endColour}"

      if [ "$par_impar" == "par" ]; then
        if [ "$(($random_number % 2))" -eq 0 ] && [ "$random_number" -ne 0 ] ; then
          echo -e "${yellowColour}[+]${endColour}${grayColour} El número es par, ¡ganas!${endColour}"
          reward=$(($bet*2))
          let money+=$reward
          echo -e "${yellowColour}[+]${endColour}${grayColour} Tiene ${endColour}${yellowColour}$money$ ${endColour}"
          
          if [ $money -gt $bet_to_renew ]; then
            echo -e "${yellowColour}[+]${endColour}${grayColour} Se ha superado el tope establecido de${endColour}${yellowColour} $bet_to_renew$ ${endColour}${grayColour} para renovar nuestra secuencia${endColour}"
            bet_to_renew=$(($bet_to_renew + 50))
            echo -e "${yellowColour}[+]${endColour}${grayColour} El tope se ha establecido en${endColour}${yellowColour} $bet_to_renew$ ${endColour}"
            my_sequence=(1 2 3 4)
            bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            echo -e "${yellowColour}[+]${endColour}${grayColour} La secuencia ha sido restablecida a:${endColour}${greenColour} [${my_sequence[@]}]${endColour}"
          else
            my_sequence+=($bet)
            my_sequence=(${my_sequence[@]})

            echo -e "${yellowColour}[+]${endColour}${grayColour} Nuestra nueva sequencia es: ${endColour}${greenColour}[${my_sequence[@]}]${endColour}"
            if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 0 ]; then
              bet=${my_sequence[0]}
            else
              echo -e "${redColour}[!] Hemos perdido la secuencia${endColour}"
              my_sequence=(1 2 3 4)
              echo -e "${yellowColour}[+]${endColour}${yellowColour} Restablecemos la secuencia a${endColour}${greenColour} [${my_sequence[@]}]${endColour}"
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
          fi
        elif [ "$((random_number % 2))" -eq 1 ] || [ $(($random_number)) -eq 0 ]; then
          if [ $((random_number % 2)) -eq 1 ]; then  
            echo -e "${redColour}[!] El número es impar, ¡pierdes!${endColour}"
          else
            echo -e "${redColour}[!] Ha salido el número 0, ¡pierdes!${endColour}"
          fi
          if [ $money -lt $(($bet_to_renew-100)) ]; then
            echo -e "${yellowColour}[+]${endColour}${grayColour} Hemos llegado a un mínimo crítico, se procede a reajustar el tope${endColour}"
            bet_to_renew=$(($bet_to_renew - 50))
            echo -e "${yellowColour}[+]${endColour}${grayColour} El tope ha sido renovado a:${endColour}${yellowColour} $bet_to_renew$ ${endColour}"

            unset my_sequence[0]
            unset my_sequence[-1] 2>/dev/null

            my_sequence=(${my_sequence[@]})

            echo -e "${yellowColour}[+]${endColour}${grayColour} Nuestra nueva sequencia es: ${endColour}${greenColour}[${my_sequence[@]}]${endColour}"
            if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 0 ]; then
              bet=${my_sequence[0]}
            else
              echo -e "${redColour}[!] Hemos perdido la secuencia${endColour}"
              my_sequence=(1 2 3 4)
              echo -e "${yellowColour}[+]${endColour}${yellowColour} Restablecemos la secuencia a${endColour}${greenColour} [${my_sequence[@]}]${endColour}"
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
          else
            unset my_sequence[0]
            unset my_sequence[-1] 2>/dev/null

            my_sequence=(${my_sequence[@]})

            echo -e "${yellowColour}[+]${endColour}${grayColour} La secuencia ha quedado de la siguiente manera:${endColour} ${greenColour}[${my_sequence[@]}]${endColour}"
            if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]; then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 1 ]; then
              bet=${my_sequence[0]}
            else
              echo -e "${redColour}[!] Hemos perdido la secuencia${endColour}"
              my_sequence=(1 2 3 4)
              echo -e "${yellowColour}[+]${endColour}${yellowColour} Restablecemos la secuencia a${endColour}${blueColour} [${my_sequence[@]}]${endColour}"
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            fi
          fi
        fi 
      fi
    else
      echo -e "\n${redColour}[!] Te has quedado sin plata${endColour}"
      echo -e "${yellowColour}[+]${endColour}${grayColour} Jugadas totales:${endColour}${yellowColour} $jugadas_totales${endColour}"
      tput cnorm; exit 1
    fi 
#   sleep 2
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
  elif [ "$technique" == "inverseLabrouchere" ]; then
    inverseLabrouchere
  else
    echo -e "\n${redColour}[!]La técnica introducida no existe${endColour}"
    helpPanel
  fi
else
  helpPanel
fi
