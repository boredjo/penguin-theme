local gray_color=241

hash_color() {
    [[ -z "$1" ]] && return 1

    local hash hue saturation=65 lightness=70
    local c x m r g b

    hash=$(printf '%s' "$1" | sha256sum)
    hash=${hash:0:8}

    # Map hash to hue (0–359)
    hue=$(( 16#$hash % 360 ))

    # HSL -> RGB
    c=$(( (100 - (2 * lightness - 100)) * saturation ))
    x=$(( c * (60 - (hue % 120)) / 60 ))
    m=$(( lightness * 2 - c / 2 ))

    case $(( hue / 60 )) in
        0) r=$c; g=$x; b=0 ;;
        1) r=$x; g=$c; b=0 ;;
        2) r=0; g=$c; b=$x ;;
        3) r=0; g=$x; b=$c ;;
        4) r=$x; g=0; b=$c ;;
        5) r=$c; g=0; b=$x ;;
    esac

    # Convert to 8-bit RGB
    r=$(( (r + m) * 255 / 200 ))
    g=$(( (g + m) * 255 / 200 ))
    b=$(( (b + m) * 255 / 200 ))

    printf '\e[38;2;%d;%d;%dm' "$r" "$g" "$b"
}


print_line() {
  dash='\e[38;5;${gray_color}m-'
  for i in {1..$((COLUMNS))}
  do
    echo -ne $dash
  done
}


PROMPT='$(print_line)\n' # dashed Line
PROMPT+=$'\U1F427 ' # penguin
PROMPT+=$'%{$(hash_color "$USER")%}%n%{$reset_color%}' # user
PROMPT+=$'@%{$(hash_color "$HOST")%}%m%{$reset_color%} ' # @host
RPROMPT+=$'\e[38;5;${gray_color}m[%D{%f/%m/%y} %D{%L:%M:%S}]' # time
PROMPT+=$'\n\U2BA1%{$reset_color%} ' # new line