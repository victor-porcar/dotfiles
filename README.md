# dotfiles

Personal development environment for Java on Linux (tested on Ubuntu 24.04).

## Installing on a new machine

```bash
sudo apt-get install -y git
git clone https://github.com/victor-porcar/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Then open a new terminal (or run `source ~/.bashrc`).

The repo is cloned over HTTPS because a fresh machine has no SSH key yet. To be able
to push later, switch the remote:
`git remote set-url origin git@github.com:victor-porcar/dotfiles.git`

You can run a single step: `./install.sh packages | git | link | java`.
The script is **idempotent**: running it several times breaks nothing.

## What each step does

| Step       | What it does                                                        |
|------------|---------------------------------------------------------------------|
| `packages` | Installs with `apt` everything listed in `packages/apt.txt`         |
| `git`      | Asks for name and email and stores them in `~/.gitconfig.local`     |
| `link`     | Creates symlinks from `$HOME` to the files in this repo             |
| `java`     | Installs SDKMAN and the candidates in `java/sdkman-candidates.txt`  |

If a file already exists when linking, it is moved to `~/.dotfiles-backup/<date>/`.

## Layout

```
install.sh                 entry point
scripts/                   install logic (one file per step + lib.sh)
bash/bashrc                -> ~/.bashrc  (loads the modules in bash/)
bash/*.sh                  options, exports, history, aliases, functions, prompt, java
bash/inputrc               -> ~/.inputrc (completion and history search)
git/gitconfig              -> ~/.gitconfig
git/ignore                 -> ~/.config/git/ignore (global gitignore)
vim/vimrc                  -> ~/.vimrc
editorconfig/editorconfig  -> ~/.editorconfig
java/maven/settings.xml    copied (not linked) to ~/.m2/settings.xml if missing
java/sdkman-candidates.txt JDK, Maven, Gradle to install
packages/apt.txt           system packages
```

## Local customization (not versioned)

- `~/.bashrc.local`: aliases, variables or secrets specific to that machine.
- `~/.gitconfig.local`: git identity (and anything you want to override).

Note: since `~/.gitconfig` is a symlink into the repo, `git config --global ...` edits
the repo file. For local changes use `git config --file ~/.gitconfig.local ...`.

## Testing from scratch

On a freshly installed Ubuntu VM: clone and run `./install.sh`.
