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

## What's included

### Bash

**General aliases** (`bash/aliases.sh`)

| Alias      | Does                                         |
|------------|----------------------------------------------|
| `ll` / `la`| `ls -lh` / `ls -lhA` (includes hidden files) |
| `..` / `...` | go up 1 / 2 directories                    |
| `cp`, `mv` | ask before overwriting                       |
| `df`, `du` | human-readable sizes                         |
| `g`        | `git`                                        |
| `gs`       | `git status -sb` (compact status)            |
| `gl`       | `git lg` (graph log)                         |
| `reload`   | reload `~/.bashrc`                           |
| `dotfiles` | `cd` into this repo                          |

**Java aliases** (`bash/java.sh`), plus SDKMAN loaded (`sdk` to switch JDKs)

| Alias     | Does                                              |
|-----------|---------------------------------------------------|
| `mci`     | `mvn clean install`                               |
| `mcis`    | `mvn clean install -DskipTests`                   |
| `mdt`     | `mvn dependency:tree`                             |
| `mdu`     | dependencies with newer versions available        |
| `mw` / `gw` | `./mvnw` / `./gradlew` (project wrappers)       |

**Functions** (`bash/functions.sh`)

- `mkcd dir`: create a directory and `cd` into it.
- `port 8080`: show which process is using a port.
- `extract file`: unpack `.tar.gz`, `.tar.xz`, `.zip`, `.jar`, `.gz`...
- `path_prepend dir` / `path_append dir`: add to `PATH` only if the dir exists and is not
  already there (handy in `~/.bashrc.local`).

**History** (`bash/history.sh`): 50,000 entries with timestamps, no duplicates,
commands starting with a space are not saved, shared across open terminals.

**Shell options** (`bash/options.sh`): `autocd` (type a directory name to enter it),
`cdspell` (fixes small typos in `cd`), `globstar` (`**/*.java` is recursive),
bash-completion enabled.

**Prompt** (`bash/prompt.sh`): `user@host:~/project (main *)$`, showing the git branch,
`*` for uncommitted changes and whether you are ahead/behind the remote.

**Readline** (`bash/inputrc`): case-insensitive completion; up/down arrows search
history for what you've already typed (type `mvn` + ↑).

### Git (`git/gitconfig`)

- **Aliases**: `st`, `sw` (switch), `br`, `ci`, `amend` (add to last commit, keep
  message), `unstage`, `last` (last commit with files), `lg` (colored graph log).
- `pull` merges (default behavior, set explicitly to avoid git's warning); `push` creates the remote branch automatically;
  `fetch` prunes deleted remote branches; `rebase` auto-stashes local changes.
- Better diffs and conflicts (`histogram`, `zdiff3`); `rerere` remembers conflict
  resolutions.
- Default branch `main`, LF line endings.
- **Global gitignore** (`git/ignore`): IntelliJ, VS Code, Eclipse and OS files.

### Editors

- **vim**: line numbers, smart search, 4-space indentation, mouse support.
- **editorconfig**: UTF-8, LF, 4 spaces (2 for YAML/JSON/XML), trims trailing
  whitespace. Used by IntelliJ and VS Code in projects without their own.

### Tools installed

- **apt**: git, curl, wget, zip/unzip, build-essential, vim, tree, `jq`, `htop`,
  `ripgrep` (`rg`), `fd-find` (`fdfind`), bash-completion.
- **SDKMAN**: JDK 21 (Temurin), Maven, Gradle.

### Templates

- `~/.m2/settings.xml`: skeleton for corporate Nexus/Artifactory servers and mirrors.

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
bash/bashrc.local.example  copied (not linked) to ~/.bashrc.local if missing
java/maven/settings.xml    copied (not linked) to ~/.m2/settings.xml if missing
java/sdkman-candidates.txt JDK, Maven, Gradle to install
packages/apt.txt           system packages
```

## Local customization (not versioned)

- `~/.bashrc.local`: aliases, variables or secrets specific to that machine.
  Created by `./install.sh link` from `bash/bashrc.local.example` (with commented
  examples) if it does not exist yet.
- `~/.gitconfig.local`: git identity (and anything you want to override).

Note: since `~/.gitconfig` is a symlink into the repo, `git config --global ...` edits
the repo file. For local changes use `git config --file ~/.gitconfig.local ...`.

### Work vs personal git identity (`includeIf`)

On a work machine, git can pick the identity based on where the repo lives.
Everything cloned under `~/work/` commits with the work email; anything else uses
the personal one:

```ini
# ~/.gitconfig.local
[user]
    name = Your Name
    email = personal@example.com
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig.work
```

```ini
# ~/.gitconfig.work
[user]
    email = you@company.com
```

The trailing `/` in `gitdir:~/work/` matters: it matches every repo below that folder.
Check which identity applies inside a repo with `git config user.email`.

## Testing from scratch

On a freshly installed Ubuntu VM: clone and run `./install.sh`.
