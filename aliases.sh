# Docker aliases - installed by docker-aliases/install.sh

# dls lives in ~/.local/bin; make sure it is on PATH.
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

alias dc='docker compose'
alias dup='docker compose up -d'
