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

The repo is cloned over HTTPS because a fresh machine has no SSH key yet. The `github`
step sets up SSH access and then switches the remote to SSH, so you can push.

You can run a single step: `./install.sh packages | git | github | link | java | home`.
The script is **idempotent**: running it several times breaks nothing.

## Moving to a new machine (a "copy" of the current one)

Think of a machine as two kinds of things:

1. **The recipe**: how everything must be set up (programs, shortcuts, the green terminal,
   the local-env launchers...). That is this repo, applied by `install.sh`.
2. **Your stuff**: your code, documents, keys, VPN, kubeconfigs... It is private, so it can't
   go to GitHub. That's what `backup-private` and `recover-private` are for.

Recipe + stuff = your machine exactly as it is now.

### On the current machine: make the copy

Plug in a USB disk (or pick any folder) and run:

```bash
backup-private /media/$USER/MyDisk
```

It lists what it will save, warns that it is not encrypted and asks `Proceed? [y/N]`.
Answer `y` and wait a few minutes. The result is **a single file** on the disk, such as
`private-backup-mymachine-20261008-1200.tar.gz`: the "suitcase" with all your stuff.

### On the new machine: make it the same

**Step 1, the recipe** (installs and configures everything):

```bash
sudo apt-get install -y git && git clone https://github.com/victor-porcar/dotfiles.git ~/dotfiles && cd ~/dotfiles && ./install.sh && ./install.sh desktop
```

Log out and back in.

**Step 2, your stuff** (plug in the disk with the copy):

```bash
recover-private /media/$USER/MyDisk/private-backup-mymachine-20261008-1200.tar.gz
```

It shows what it will put where, asks `Proceed? [y/N]`; answer `y` and open a new terminal.
Your `work`, `personal` and `docs` folders, SSH keys, VPN, kubenv, launchers... all in place.

### What does NOT travel in the copy

| What | How it comes back |
|---|---|
| Programs (IntelliJ, Chrome, Java...) | Installed by the recipe |
| `target/`, `node_modules/` folders | Regenerated when you build |
| IntelliJ settings | IntelliJ Settings Sync (your JetBrains account) |
| Chrome bookmarks | Your Google account |
| Docker data (Redis, Solr, **Oracle**) | Redis and Solr can be regenerated; **export Oracle separately** if its data matters |

### Important

The copy is **not encrypted** and holds **your SSH keys, VPN password and cloud/cluster
credentials**. Whoever has the file can get into all of that:

- Keep it on **a disk only you use**.
- **Don't upload it to the cloud** unencrypted.
- **Delete it** once the new machine is restored, if you no longer need it.

## What each step does

| Step       | What it does                                                        |
|------------|---------------------------------------------------------------------|
| `packages` | Installs with `apt` everything listed in `packages/apt.txt`         |
| `git`      | Asks for name and email and stores them in `~/.gitconfig.local`     |
| `github`   | Passwordless SSH access to GitHub: verifies github.com's fingerprint, creates an SSH key if missing, **pauses** while you add it on github.com (opens the page for you), checks the login and switches this repo's remote to SSH |
| `link`     | Creates symlinks from `$HOME` to the files in this repo             |
| `java`     | Installs SDKMAN and the candidates in `java/sdkman-candidates.txt`  |
| `home`     | Removes `~/Music`, `~/Videos`, `~/Templates` and `~/Public` (or their Spanish names) if empty and stops the desktop from recreating them; points the Documents folder to `~/docs`; creates `~/personal` and the `~/work` structure |

If a file already exists when linking, it is moved to `~/.dotfiles-backup/<date>/`.

### Home layout

The `home` step creates this structure (only the folders that don't exist yet):

```
~/docs/               personal documents (the desktop's Documents folder)
~/personal/           personal code (github-sync clones my repos into github-<user>/)
~/work/
├── access/           how I get in: VPN, certificates...
├── archive/          old stuff kept just in case
├── bin/              work scripts and tools (in PATH)
├── docs/             reference docs: PDFs, diagrams, specs
├── environments/     remote environments: kubeconfigs, clusters
├── local-env/        what runs on my machine: docker compose files
├── notes/            my own notes
└── workspaces/       source code
```

### Optional: desktop (`./install.sh desktop`)

Not part of `all`, so servers and headless VMs stay clean. Requires a GNOME session.

- Installs the apt packages in `desktop/apt.txt`: extension dependencies, GNOME Terminal and
  GNOME Boxes (virtual machines with KVM, handy to test these dotfiles from scratch).
- Installs the desktop apps listed in `desktop/snaps.txt` (IntelliJ IDEA Community, Postman,
  Freelens) in their latest stable version; if already installed, updates them right away.
- Installs Google Chrome from Google's official `.deb` (which also adds Google's apt
  repository, so it's updated with the system), or upgrades it if already installed.
- Installs the GNOME extensions listed in `desktop/gnome-extensions.txt` (UUIDs from
  extensions.gnome.org). GNOME downloads the version matching itself and asks for
  confirmation. Currently: [Vitals](https://github.com/corecoding/Vitals).
- Creates the GNOME Terminal profiles in `desktop/terminal-profiles/*.dconf` (updated in
  place if a profile with the same name exists; your default profile is kept).
  Currently: **Retro**, green on black like an 80s terminal (`gnome-terminal --profile=Retro`).
- Puts the launchers in `desktop/launchers/` on the desktop: **Start / Stop / Reset local-env**.
  They open as tabs of a single Retro "Consoles" window (see `console-tab`).
- Sets the first image in `desktop/wallpapers/` as background (if any).
- Loads GNOME settings from `desktop/dconf/*.conf`. The file name is the dconf path with
  dots. To save an extension's settings:
  `dconf dump /org/gnome/shell/extensions/vitals/ > desktop/dconf/org.gnome.shell.extensions.vitals.conf`

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
| `startAllLocalEnv` / `stopAllLocalEnv` | start / stop every service in `local-env/` |
| `resetAllLocalEnv` | stop every service in `local-env/` and delete its data (asks first) |

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
- `update`: update everything at once: apt packages (incl. Chrome), snaps and SDKMAN.
  Tells you if a reboot is needed. Java stays on the pinned version.
- `path_prepend dir` / `path_append dir`: add to `PATH` only if the dir exists and is not
  already there (handy in `~/.bashrc.local`).

**History** (`bash/history.sh`): 50,000 entries with timestamps, no duplicates,
commands starting with a space are not saved, shared across open terminals.

**Shell options** (`bash/options.sh`): `autocd` (type a directory name to enter it),
`cdspell` (fixes small typos in `cd`), `globstar` (`**/*.java` is recursive),
bash-completion enabled.

**Prompt** (`bash/prompt.sh`): `user@host:~/project (main *)$`, showing the git branch,
`*` for uncommitted changes and whether you are ahead/behind the remote. In Mercurial
repos it shows `(hg:branch|bookmark)`, read straight from `.hg/` to keep the prompt fast
(so no dirty-state marker).

**Readline** (`bash/inputrc`): case-insensitive completion; up/down arrows search
history for what you've already typed (type `mvn` + ↑).

### Scripts (`bin/`, in PATH)

**`kubenv.sh`**: Kubernetes port-forwards for an environment in one command.

```bash
kubenv.sh [-n|--namespace <ns>] <kubeconfig|alias> target:localPort[:remotePort[:kubeconfig|alias]] ...
kubenv.sh -n my-namespace my-env search:8080 svc/solr:8984:8983:my-infra
```

- `target` is a deployment/statefulset/daemonset name, matched exactly against the pod
  name structure (`publisher` never picks `publisher-s3-...`). If nothing matches exactly
  it falls back to a pod name prefix, warning when several pods match. A resource like
  `svc/solr` or `deploy/api` is passed to kubectl as is.
- Without `--namespace`, the namespace of the kubeconfig context is used.
- The remote port is taken from the pod if omitted.
- Port-forwards reconnect automatically when the pod restarts; Ctrl-C stops them all.
- If the local port is taken by a previous port-forward it is replaced; anything else
  using it is left alone and that forward is skipped.
- Aliases live outside the repo, in `~/work/environments/kubenv.properties`
  (override with `KUBENV_CONFIG`), with paths relative to that file:
  `my-env=kubeconfigs/my-env.yaml`
- Needs `kubectl` (not installed by `install.sh`).
- Tip: keep one small wrapper per environment next to its kubeconfigs (outside this
  repo), e.g. `exec kubenv.sh -n my-ns <kubeconfig> svc-a:10400:8080 svc-b:10401:8080`.

**`github-sync`**: clones all your GitHub repos (public and private) into
`~/personal/github-<your-user>` (or the folder you pass) and pulls the ones you already have. Repos with uncommitted
changes or a diverged branch are only fetched, never touched. The dotfiles repo is updated
in `~/dotfiles`. Needs the GitHub CLI (`gh`, installed by `packages`) logged in once:
`gh auth login`.

**`console-tab <tab name> <command...>`**: runs a command as a tab of one shared terminal
window (a tmux session shown in a Retro GNOME Terminal). The first call opens the window,
the next ones add tabs to it. Closing the window stops every tab's command (VPN,
port-forwards...). Used by the desktop launchers; works in your own launchers too:
`Exec=bash -ic "console-tab 'My tab' my-command"`.

**`backup-private <folder>`** / **`recover-private <archive>`**: back up and restore the
private data that is not in this repo, so that a new machine with `install.sh` +
`recover-private` ends up like the old one. Includes `~/work`, `~/personal`, `~/docs`,
`~/Desktop`, `~/Pictures`, `~/.ssh`, `~/.gnupg`, `~/.kube`, `~/.aws`, `~/.config/gh`,
`~/.bashrc.local`, `~/.gitconfig.local` and `~/.m2/settings.xml`, skipping build output
(`target/`, `node_modules/`, `build/`, `.gradle/`). Both list what they will do and ask
before proceeding. Restoring overwrites existing files. **The archive is not encrypted**:
it holds SSH keys and credentials. Not included: Docker volumes (e.g. local-env data).

### tmux (`tmux/tmux.conf`)

Linked to `~/.config/tmux/tmux.conf`. Mouse on (click a tab to switch), tabs numbered from
1, tabs with new output highlighted, green-on-black status bar matching the Retro profile.
Shortcuts start with `Ctrl+b`: `n` / `p` next / previous tab, `&` close tab.

### Git (`git/gitconfig`)

- **Aliases**: `st`, `sw` (switch), `br`, `ci`, `amend` (add to last commit, keep
  message), `unstage`, `last` (last commit with files), `lg` (colored graph log).
- `pull` merges (default behavior, set explicitly to avoid git's warning); `push` creates the remote branch automatically;
  `fetch` prunes deleted remote branches; `rebase` auto-stashes local changes.
- Better diffs and conflicts (`histogram`, `zdiff3`); `rerere` remembers conflict
  resolutions.
- Default branch `main`, LF line endings.
- **Global gitignore** (`git/ignore`): IntelliJ, VS Code, Eclipse and OS files.

### Editor

- **vim**: line numbers, smart search, 4-space indentation, mouse support.

### Tools installed

- **apt**: git, curl, wget, zip/unzip, build-essential, vim, tree, `jq`, `htop`,
  `ripgrep` (`rg`), `fd-find` (`fdfind`), `lsof`, `gh` (GitHub CLI), `tmux`, bash-completion, Docker (`docker.io` +
  the `docker compose` plugin; your user is added to the `docker` group).
- **SDKMAN**: JDK 21 (Temurin), Maven, Gradle.

### Templates

- `~/.m2/settings.xml`: skeleton for corporate Nexus/Artifactory servers and mirrors.

### Local services (`local-env/`)

Generic services for local development with Docker Compose (Docker itself is installed
by the `packages` step). Not started by `install.sh`: start them when needed.

| Service         | What                                   | Ports                         |
|-----------------|----------------------------------------|-------------------------------|
| `redis-cluster` | Redis Cluster, 3 masters + 3 replicas (Bitnami) | `6379` (node 0 only)  |
| `solr`          | SolrCloud, 3 nodes + ZooKeeper         | `8983`, `7574`, `7575`, `2181` |

```bash
cd ~/dotfiles/local-env/solr
docker compose up -d       # start
docker compose down        # stop, keep data
docker compose down -v     # stop and delete data
```

All at once: `startAllLocalEnv` and `stopAllLocalEnv` aliases (scripts in `local-env/`; data is kept).
`resetAllLocalEnv` also deletes the data volumes, to start from scratch (asks for confirmation).
To add a service, create its folder with a `compose.yaml` and add one line to each script.

**Changing versions**: edit the `.env` file next to each `compose.yaml`, or override
it for a single run: `SOLR_VERSION=9.9.0 docker compose up -d`.

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
tmux/tmux.conf             -> ~/.config/tmux/tmux.conf
bash/bashrc.local.example  copied (not linked) to ~/.bashrc.local if missing
java/maven/settings.xml    copied (not linked) to ~/.m2/settings.xml if missing
java/sdkman-candidates.txt JDK, Maven, Gradle to install
bin/                       personal scripts, added to PATH (kubenv.sh, github-sync, backup...)
packages/apt.txt           system packages
desktop/                   optional GNOME setup: extensions, terminal profiles, wallpapers, dconf
local-env/                 Docker Compose files for local services (versions in .env)
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
