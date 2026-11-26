local time='[%D{%f/%m/%y} %D{%L:%M:%S}]'
local user='%n'
local host='$m'

print_line() {
  dash='\e[38;5;241m-'
  for i in {1..$((COLUMNS))}
  do
    echo -ne $dash
  done
}

PROMPT=$'$(print_line)
\U1F427 %n@%m ${time}
\U2BA1 '