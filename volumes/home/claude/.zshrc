# mise (version manager) activation
eval "$(mise activate zsh)"

# history
HISTSIZE=10000
SAVEHIST=10000
setopt share_history
setopt hist_ignore_dups
setopt nobeep

# completion
autoload -Uz compinit
compinit

# fzf key bindings + completion
# fzf --zsh requires fzf >= 0.48; fall back to legacy key-bindings files for older versions
if fzf --zsh &>/dev/null; then
  source <(fzf --zsh)
else
  [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
  [[ -f /usr/share/doc/fzf/examples/completion.zsh ]]   && source /usr/share/doc/fzf/examples/completion.zsh
fi
