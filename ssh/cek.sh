#!/bin/bash
MYIP=$(wget -qO- ipinfo.io/ip);
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White
UWhite='\033[4;37m'       # White
On_IPurple='\033[0;105m'  #
On_IRed='\033[0;101m'
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }

# // Exporting Language to UTF-8
export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'

# // Export Color & Information
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export LIGHT='\033[0;37m'
export NC='\033[0m'

clear
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e " ${BICyan}│${NC}                   ${BIWhite}${UWhite}SSH ACTIVE USERS${NC}                  ${BICyan}│${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"

if [ -e "/var/log/auth.log" ]; then
    LOG="/var/log/auth.log";
fi
if [ -e "/var/log/secure" ]; then
    LOG="/var/log/secure";
fi

# Declare associative array
declare -A ssh_users
declare -A ssh_first_connect
declare -A ssh_last_connect

# Function to calculate time difference
time_diff() {
    local start_time=$1
    local end_time=$(date +"%s")
    local diff=$(( end_time - start_time ))
    local hours=$(( diff / 3600 ))
    local minutes=$(( (diff % 3600) / 60 ))
    local seconds=$(( diff % 60 ))
    printf "%02d:%02d:%02d" $hours $minutes $seconds
}

# Process dropbear
data=( $(ps aux | grep -i dropbear | awk '{print $2}') )
cat $LOG | grep -i dropbear | grep -i "Password auth succeeded" > /tmp/login-db.txt
for PID in "${data[@]}"; do
    grep "dropbear\[$PID\]" /tmp/login-db.txt > /tmp/login-db-pid.txt
    NUM=$(wc -l < /tmp/login-db-pid.txt)
    USER=$(awk '{print $10}' /tmp/login-db-pid.txt)
    TIME=$(grep "dropbear\[$PID\]" /tmp/login-db.txt | awk '{print $1" "$2" "$3}')
    
    # Convert TIME to epoch seconds
    TIME=$(date -d "$TIME" +"%s" 2>/dev/null)
    if [ $? -ne 0 ]; then
        continue
    fi

    if [ $NUM -eq 1 ]; then
        ssh_users["$USER"]=$((ssh_users["$USER"]+1))
        if [ -z "${ssh_first_connect[$USER]}" ]; then
            ssh_first_connect["$USER"]=$TIME
        fi
    fi
done

# Process sshd
cat $LOG | grep -i sshd | grep -i "Accepted password for" > /tmp/login-db.txt
data=( $(ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}') )
for PID in "${data[@]}"; do
    grep "sshd\[$PID\]" /tmp/login-db.txt > /tmp/login-db-pid.txt
    NUM=$(wc -l < /tmp/login-db-pid.txt)
    USER=$(awk '{print $9}' /tmp/login-db-pid.txt)
    TIME=$(grep "sshd\[$PID\]" /tmp/login-db.txt | awk '{print $1" "$2" "$3}')
    
    # Convert TIME to epoch seconds
    TIME=$(date -d "$TIME" +"%s" 2>/dev/null)
    if [ $? -ne 0 ]; then
        continue
    fi

    if [ $NUM -eq 1 ]; then
        ssh_users["$USER"]=$((ssh_users["$USER"]+1))
        if [ -z "${ssh_first_connect[$USER]}" ]; then
            ssh_first_connect["$USER"]=$TIME
        fi
    fi
done

# Display SSH users
LINE_NUMBER=1
for USER in "${!ssh_users[@]}"; do
    COUNT=${ssh_users[$USER]}
    FIRST_CONNECT=${ssh_first_connect[$USER]}
    DURATION=$(time_diff $FIRST_CONNECT)
    printf " ${BICyan}│${NC}  ${BIBlue}${LINE_NUMBER}\\ ${NC}${BIWhite}%-18s${NC}     ${BIYellow}[${NC}${BIGreen}%02d${NC}${BIYellow}]${NC}      ${BIPurple}%s       ${BICyan}│${NC}\n" "$USER" "$COUNT" "$DURATION"
    LINE_NUMBER=$((LINE_NUMBER + 1))
done

echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
calculate_total() {
    TOTAL=0
    for count in "${!ssh_users[@]}"; do
        TOTAL=$((TOTAL + ${ssh_users[$count]}))
    done
    TOTAL=$(printf "%02d" $TOTAL)
}

calculate_total
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e " ${BICyan}│${NC} ${BIWhite} Total User Online: ${BIRed}$TOTAL${NC}                              ${BICyan}│${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
echo -e " ${BICyan}│${NC}                   ${BIWhite}${UWhite}OVPN ACTIVE USERS${NC}                 ${BICyan}│${NC}"
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"
echo -e "${BICyan} ┌─────────────────────────────────────────────────────┐${NC}"
# Process OpenVPN
cat /etc/openvpn/server/openvpn-tcp.log | grep -w "^CLIENT_LIST" | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g' > /tmp/vpn-login-tcp.txt
cat /tmp/vpn-login-tcp.txt
cat /etc/openvpn/server/openvpn-udp.log | grep -w "^CLIENT_LIST" | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g' > /tmp/vpn-login-udp.txt
cat /tmp/vpn-login-udp.txt
echo -e " ${BICyan}└─────────────────────────────────────────────────────┘${NC}"

rm -f /tmp/login-db-pid.txt
rm -f /tmp/login-db.txt
rm -f /tmp/vpn-login-tcp.txt
rm -f /tmp/vpn-login-udp.txt

echo ""
read -n 1 -s -r -p "   Press any key to back on menu"
menu-ssh
#    printf " ${BIBlue}│${NC}      ${BIWhite}%-18s${NC}     ${BIYellow}%-5d${NC}     ${BIPurple}%s      ${BIBlue}│${NC}\n" "$USER" "$COUNT" "$DURATION"
