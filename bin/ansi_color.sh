# Reset
Escape=$(echo -e '\033')

Color_Off="${Escape}[0m"       # Text Reset

# Regular Colors
Black="${Escape}[0;30m"        # Black
Red="${Escape}[0;31m"          # Red
Green="${Escape}[0;32m"        # Green
Yellow="${Escape}[0;33m"       # Yellow
Blue="${Escape}[0;34m"         # Blue
Purple="${Escape}[0;35m"       # Purple
Cyan="${Escape}[0;36m"         # Cyan
White="${Escape}[0;37m"        # White

# Bold
BBlack="${Escape}[1;30m"       # Black
BRed="${Escape}[1;31m"         # Red
BGreen="${Escape}[1;32m"       # Green
BYellow="${Escape}[1;33m"      # Yellow
BBlue="${Escape}[1;34m"        # Blue
BPurple="${Escape}[1;35m"      # Purple
BCyan="${Escape}[1;36m"        # Cyan
BWhite="${Escape}[1;37m"       # White

# Underline
UBlack="${Escape}[4;30m"       # Black
URed="${Escape}[4;31m"         # Red
UGreen="${Escape}[4;32m"       # Green
UYellow="${Escape}[4;33m"      # Yellow
UBlue="${Escape}[4;34m"        # Blue
UPurple="${Escape}[4;35m"      # Purple
UCyan="${Escape}[4;36m"        # Cyan
UWhite="${Escape}[4;37m"       # White

# Background
On_Black="${Escape}[40m"       # Black
On_Red="${Escape}[41m"         # Red
On_Green="${Escape}[42m"       # Green
On_Yellow="${Escape}[43m"      # Yellow
On_Blue="${Escape}[44m"        # Blue
On_Purple="${Escape}[45m"      # Purple
On_Cyan="${Escape}[46m"        # Cyan
On_White="${Escape}[47m"       # White

# High Intensity
IBlack="${Escape}[0;90m"       # Black
IRed="${Escape}[0;91m"         # Red
IGreen="${Escape}[0;92m"       # Green
IYellow="${Escape}[0;93m"      # Yellow
IBlue="${Escape}[0;94m"        # Blue
IPurple="${Escape}[0;95m"      # Purple
ICyan="${Escape}[0;96m"        # Cyan
IWhite="${Escape}[0;97m"       # White

# Bold High Intensity
BIBlack="${Escape}[1;90m"      # Black
BIRed="${Escape}[1;91m"        # Red
BIGreen="${Escape}[1;92m"      # Green
BIYellow="${Escape}[1;93m"     # Yellow
BIBlue="${Escape}[1;94m"       # Blue
BIPurple="${Escape}[1;95m"     # Purple
BICyan="${Escape}[1;96m"       # Cyan
BIWhite="${Escape}[1;97m"      # White

# High Intensity backgrounds
On_IBlack="${Escape}[0;100m"   # Black
On_IRed="${Escape}[0;101m"     # Red
On_IGreen="${Escape}[0;102m"   # Green
On_IYellow="${Escape}[0;103m"  # Yellow
On_IBlue="${Escape}[0;104m"    # Blue
On_IPurple="${Escape}[0;105m"  # Purple
On_ICyan="${Escape}[0;106m"    # Cyan
On_IWhite="${Escape}[0;107m"   # White

Italic="${Escape}[3m"
Underline="${Escape}[4m"
Reverse="${Escape}[7m"
Strike="${Escape}[9m"

function rgb()
{
  echo -n -e "\033[38;2;$1;$2;$3m"
}

function bg_rgb()
{
  echo -n -e "\033[48;2;$1;$2;$3m"
}

function rgb6b()
{
  local code=$(($1*36 + $2*6 + $3 + 16))
  echo -n -e "\033[38;5;${code}m"
}

function bg_rgb6b()
{
  local code=$(($1*36 + $2*6 + $3 + 16))
  echo -n -e "\033[48;5;${code}m"
}

function gray()
{
  local code=$(($1 + 232))
  echo -n -e "\033[38;5;${code}m"
}

function bg_gray()
{
  local code=$(($1 + 232))
  echo -n -e "\033[48;5;${code}m"
}

function e.red()
{
  echo "${Red}$*${Color_Off}"
}

function e.green()
{
  echo "${Green}$*${Color_Off}"
}

function e.blue()
{
  echo "${Blue}$*${Color_Off}"
}

function e.yellow()
{
  echo "${Yellow}$*${Color_Off}"
}

function e.purple()
{
  echo "${Purple}$*${Color_Off}"
}

function h1()
{
  echo "${BWhite}${On_Blue} $1 ${Color_Off}"
}

function h2()
{
  echo "${ICyan}** $1 **${Color_Off}"
}

function h3()
{
  echo "${Purple}-> $1 ${Color_Off}"
}

function rgb_cube()
{
  local r g b x
  for r in {0..5}; do
    for g in {0..5}; do
      for b in {0..5}; do
        echo -n "$(bg_rgb6b $r $g $b)   ";
      done;
      echo -n "$Color_Off   ";
    done;
    echo ''
  done

  echo ''
  for x in {0..23}; do
    echo -n "$(bg_gray $x)     "
  done
  echo ''
}
