# dev_env

Personal macOS/Linux shell and editor configuration for zsh, tmux, Vim and Git.

## Install on a new machine

Clone this repository, then run:

```sh
./install.sh
```

The installer asks for `user.name` and `user.email` interactively, then stores
them in this repository's `.gitconfig`. For automation, pass them as arguments:

```sh
./install.sh --git-name "Your Name" --git-email "you@example.com"
```

The installer is safe to run repeatedly. Existing dotfiles are moved to
`~/.config-backups/dev_env/<timestamp>/` before the repository files are linked
into `$HOME`. It installs the command-line dependencies and bootstraps:

- Homebrew packages: Git, Git LFS, tmux, Vim, fzf, eza, pyenv, Node.js and
  OpenJDK 21 on macOS
- Oh My Zsh and Powerlevel10k
- The tracked `.p10k.zsh` Powerlevel10k prompt configuration
- tmux Plugin Manager and the plugins declared in `.tmux.conf`
- Vim Pathogen, vim-plug, NERDTree, NERDCommenter, kolor and all Vim plugins
  declared in `.vimrc`

Useful options:

```sh
./install.sh --dry-run
./install.sh --skip-packages
./install.sh --skip-vim
./install.sh --skip-tmux
./install.sh --git-name "Your Name" --git-email "you@example.com"
```

The installer does not manage SSH keys, tokens or other machine-specific
secrets. The tracked Git config uses `~/.gitignore_global` instead of a
machine-specific absolute path.

After installation, open a new shell and run `p10k configure` if the prompt
needs customization.
