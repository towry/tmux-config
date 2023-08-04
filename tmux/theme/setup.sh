function setup_tmux_theme() {
  local light_theme="$HOME/.tmux/theme/kanagawa_light.conf"
  local dark_theme="$HOME/.tmux/theme/kanagawa_dark.conf"

  cat ~/.config/nvim/lua/settings_env.lua 2>/dev/null | grep -q 'light'
  if [[ $? -eq 0 ]]; then
    tmux display-message "Load light"
    tmux source-file $light_theme
  else
    tmux display-message "Load dark"
    tmux source-file $dark_theme
  fi
}

setup_tmux_theme
