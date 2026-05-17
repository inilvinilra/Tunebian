# Tunebian default shell profile.
export LS_OPTIONS='--color=auto'
eval "$(dircolors -b 2>/dev/null || true)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -alF'

