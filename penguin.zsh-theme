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


function precmd() {
  dash='\e[38;5;241m-'
  for i in {1..$((COLUMNS))}
  do
    echo -ne $dash
  done

  echo '' # new line

  # Get APM info.
  if [[ -x "$(whence -p ibam)" ]]; then
      PR_APM_RESULT=$(ibam --percentbattery)
  elif [[ -x "$(whence -p apm)" ]]; then
      PR_APM_RESULT=$(apm)
  fi

  ### https://aperiodic.net/pip/prompt/prompt.txt
  # Show virtual environment

  PR_VENV=""
  if [[ -n "$POETRY_ACTIVE" ]]; then
      # I'm not sure how to tell _which_ Poetry venv is running, so that
      # information gets left out.  Sigh.
      PR_VENV="${PR_VENV}${PR_BLUE}[${PR_GREEN}poetry${PR_BLUE}]${PR_SHIFT_IN}${PR_HBAR}${PR_SHIFT_OUT}"
  fi
  if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
      PR_VENV="${PR_VENV}${PR_BLUE}[${PR_GREEN}conda${PR_BLUE}:${PR_GREEN}${CONDA_DEFAULT_ENV}${PR_BLUE}]${PR_SHIFT_IN}${PR_HBAR}${PR_SHIFT_OUT}"
  fi
  if [[ -n "$VIRTUAL_ENV" ]]; then
      PR_VENV="${PR_VENV}${PR_BLUE}[${PR_GREEN}venv${PR_BLUE}:${PR_GREEN}${VIRTUAL_ENV/#${HOME}/~}${PR_BLUE}]${PR_SHIFT_IN}${PR_HBAR}${PR_SHIFT_OUT}"
  fi
}


PROMPT=$'\U1F427 ' # penguin
PROMPT+=$'\e[38;5;241m[%D{%L:%M:%S}] ' # time
PROMPT+=$'%{$(hash_color "$USER")%}%n%{$reset_color%}' # user
PROMPT+=$'@%{$(hash_color "$HOST")%}%m%{$reset_color%} ' # @host
PROMPT+=$'\e[38;5;241~%~ ' # pwd
PROMPT+=$'\n\U2BA1%{$reset_color%}' # new line

if [[ -n "$PR_VENV" ]]; then
  PROMPT+=$'($PR_VENV) '
else
  PROMPT+=' '
fi



# keep time fresh
TMOUT=1

TRAPALRM() {
    zle reset-prompt
}