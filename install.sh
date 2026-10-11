#!/usr/bin/env bash

# Bootstrap this dotfiles repository on a new machine.
# Usage: ./install.sh [--git-name NAME] [--git-email EMAIL] [--dry-run]
#        [--skip-packages] [--skip-vim] [--skip-tmux]

set -euo pipefail

REPO_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
DRY_RUN=0
SKIP_PACKAGES=0
SKIP_VIM=0
SKIP_TMUX=0
GIT_NAME=""
GIT_EMAIL=""

usage() {
  sed -n '3,4p' "$0"
}

log() {
  printf '[dev-env] %s\n' "$*"
}

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '+ %s\n' "$*"
  else
    "$@"
  fi
}

has_command() {
  command -v "$1" >/dev/null 2>&1
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --skip-packages) SKIP_PACKAGES=1; shift ;;
    --skip-vim) SKIP_VIM=1; shift ;;
    --skip-tmux) SKIP_TMUX=1; shift ;;
    --git-name)
      [ "$#" -ge 2 ] || { printf '%s requires a value\n' "$1" >&2; exit 2; }
      GIT_NAME="$2"; shift 2 ;;
    --git-email)
      [ "$#" -ge 2 ] || { printf '%s requires a value\n' "$1" >&2; exit 2; }
      GIT_EMAIL="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done

install_homebrew() {
  if has_command brew; then
    return
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    log "Homebrew is missing; would install it from brew.sh"
    return
  fi

  if [ "$(uname -s)" != "Darwin" ]; then
    log "Homebrew is not installed. Install your Linux package dependencies manually."
    return
  fi

  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_packages() {
  [ "$SKIP_PACKAGES" -eq 1 ] && return

  install_homebrew
  if has_command brew; then
    local formula
    local formulas=(git git-lfs tmux vim fzf eza pyenv node yarn)
    [ "$(uname -s)" = "Darwin" ] && formulas+=(openjdk@21)
    for formula in "${formulas[@]}"; do
      if brew list --formula "$formula" >/dev/null 2>&1; then
        log "Already installed: $formula"
      else
        run brew install "$formula"
      fi
    done
  elif [ "$(uname -s)" = "Linux" ] && has_command apt-get; then
    run sudo apt-get update
    run sudo apt-get install -y git git-lfs tmux vim fzf nodejs npm
  else
    log "No supported package manager found; skipping system packages"
  fi
}

backup_path() {
  local target="$1"
  local backup_dir="$HOME/.config-backups/dev_env/$(date +%Y%m%d-%H%M%S)"
  run mkdir -p "$backup_dir"
  run mv "$target" "$backup_dir/"
  log "Backed up $target to $backup_dir/"
}

link_dotfile() {
  local name="$1"
  local source="$REPO_DIR/$name"
  local target="$HOME/$name"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    log "Already linked: $target"
    return
  fi
  if [ -e "$target" ] || [ -L "$target" ]; then
    backup_path "$target"
  fi
  run ln -s "$source" "$target"
  log "Linked $target -> $source"
}

configure_git_identity() {
  local current_name current_email answer
  current_name="$(git config --file "$REPO_DIR/.gitconfig" --get user.name 2>/dev/null || true)"
  current_email="$(git config --file "$REPO_DIR/.gitconfig" --get user.email 2>/dev/null || true)"

  if [ "$DRY_RUN" -eq 0 ] && [ -t 0 ] && [ -t 1 ]; then
    if [ -z "$GIT_NAME" ]; then
      read -r -p "Git user.name [${current_name}]: " answer
      GIT_NAME="${answer:-$current_name}"
    fi
    if [ -z "$GIT_EMAIL" ]; then
      read -r -p "Git user.email [${current_email}]: " answer
      GIT_EMAIL="${answer:-$current_email}"
    fi
  else
    GIT_NAME="${GIT_NAME:-$current_name}"
    GIT_EMAIL="${GIT_EMAIL:-$current_email}"
  fi

  if [ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ]; then
    printf 'Git identity is required. Use --git-name and --git-email.\n' >&2
    exit 2
  fi

  run git config --file "$REPO_DIR/.gitconfig" user.name "$GIT_NAME"
  run git config --file "$REPO_DIR/.gitconfig" user.email "$GIT_EMAIL"
  log "Configured Git identity: $GIT_NAME <$GIT_EMAIL>"
}

install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    log "Already installed: Oh My Zsh"
  else
    log "Installing Oh My Zsh"
    if [ "$DRY_RUN" -eq 1 ]; then
      log "Would download and run the Oh My Zsh installer"
    else
      env RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
        "\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
  fi

  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  if [ -d "$custom/themes/powerlevel10k" ]; then
    log "Already installed: Powerlevel10k"
  else
    run git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
      "$custom/themes/powerlevel10k"
  fi
}

install_tmux_plugins() {
  [ "$SKIP_TMUX" -eq 1 ] && return
  local tpm="$HOME/.tmux/plugins/tpm"
  if [ -d "$tpm" ]; then
    log "Already installed: tmux plugin manager"
  else
    run git clone https://github.com/tmux-plugins/tpm "$tpm"
  fi
  if [ "$DRY_RUN" -eq 0 ] && [ -x "$tpm/bin/install_plugins" ]; then
    run "$tpm/bin/install_plugins"
  fi
}

install_vim_plugins() {
  [ "$SKIP_VIM" -eq 1 ] && return
  local vim_dir="$HOME/.vim"
  run mkdir -p "$vim_dir/autoload" "$vim_dir/bundle"

  if [ ! -f "$vim_dir/autoload/pathogen.vim" ]; then
    run curl -fsSL https://tpo.pe/pathogen.vim -o "$vim_dir/autoload/pathogen.vim"
  fi
  if [ ! -f "$vim_dir/autoload/plug.vim" ]; then
    run curl -fLo "$vim_dir/autoload/plug.vim" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
  if [ ! -d "$vim_dir/bundle/nerdtree" ]; then
    run git clone --depth=1 https://github.com/preservim/nerdtree.git \
      "$vim_dir/bundle/nerdtree"
  fi
  if [ ! -d "$vim_dir/bundle/nerdcommenter" ]; then
    run git clone --depth=1 https://github.com/preservim/nerdcommenter.git \
      "$vim_dir/bundle/nerdcommenter"
  fi
  if [ ! -f "$vim_dir/colors/kolor.vim" ]; then
    run mkdir -p "$vim_dir/colors"
    run curl -fsSL https://raw.githubusercontent.com/tyrannicaltoucan/vim-quantum/master/colors/kolor.vim \
      -o "$vim_dir/colors/kolor.vim"
  fi

  if has_command vim && [ "$DRY_RUN" -eq 0 ]; then
    vim -Nu "$HOME/.vimrc" -n -es "+PlugInstall --sync" +qa
  fi
}

main() {
  cd "$REPO_DIR"
  install_packages
  install_oh_my_zsh
  configure_git_identity
  link_dotfile .zshrc
  link_dotfile .p10k.zsh
  link_dotfile .tmux.conf
  link_dotfile .vimrc
  link_dotfile .gitconfig
  install_tmux_plugins
  install_vim_plugins
  if has_command git-lfs && [ "$DRY_RUN" -eq 0 ]; then
    git lfs install
  fi
  log "Done. Start a new shell, then run: tmux and vim"
}

main
