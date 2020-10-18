#!/bin/bash
#
# System Monitor using shell command
# AUTHOR: Bharath Kumar

#######################################
# Prints colored text in the terminal.
# Globals:
#   COLOR
# Arguments:
#   COLOR       .eg: green, red
#######################################
function print_color() {
    case $1 in
    "green")
        COLOR="\033[0;32m"
        ;;
    "red")
        COLOR="\033[0;31m"
        ;;
    "*")
        COLOR="\033[0m"
        break
        ;;
    esac
    NC="\033[0m"
    echo -e "${COLOR} $2 ${NC}"
}

## CPU Uptime
UPTIME=$(uptime -p | awk '{for (i=2; i<NF; i++) printf $i " "; if(NF >=1) print $NF; }')

## RAM Usage
RAM=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')

## CPU Temperature
TEMPERATURE=$(sensors | awk '/^Core*/ {print $1$2, $3}')

## Most memory intensive process
MEM_INTENSIVE=$(ps axch -o cmd:15,%mem --sort=-%mem | head)

## Most cpu intensive process
CPU_INTENSIVE=$(ps axch -o cmd:15,%cpu --sort=-%cpu | head)


printf "$(print_color 'green' 'CPU uptime: ') $UPTIME\n\n"
printf "$(print_color 'green' 'RAM: ') $RAM\n\n"
printf "$(print_color 'green' 'CPU Temperature: ')\n" 
printf "$TEMPERATURE\n\n"
printf "$(print_color 'green' 'Most Memory Intensive process: ')\n"
printf "$MEM_INTENSIVE\n\n"
printf "$(print_color 'green' 'Most CPU Intensive process: ')\n"
printf "$CPU_INTENSIVE\n\n"
