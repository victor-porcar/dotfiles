# dotfiles

Configuración personal de entorno de desarrollo Java sobre Linux (probado en Ubuntu 24.04).

## Instalación en una máquina nueva

```bash
sudo apt-get install -y git
git clone https://github.com/victor-porcar/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Después abre una terminal nueva (o `source ~/.bashrc`).

Se clona por HTTPS porque en una máquina nueva aún no hay clave SSH. Para poder
hacer push después, cambia el remoto:
`git remote set-url origin git@github.com:victor-porcar/dotfiles.git`

Se puede ejecutar un solo paso: `./install.sh packages | git | link | java`.
El script es **idempotente**: lanzarlo varias veces no rompe nada.

## Qué hace cada paso

| Paso       | Qué hace                                                                 |
|------------|--------------------------------------------------------------------------|
| `packages` | Instala con `apt` lo listado en `packages/apt.txt`                       |
| `git`      | Pide nombre y email y los guarda en `~/.gitconfig.local`                 |
| `link`     | Crea enlaces simbólicos desde `$HOME` a los ficheros del repo            |
| `java`     | Instala SDKMAN y los candidatos de `java/sdkman-candidates.txt`          |

Si al enlazar ya existe un fichero, se mueve a `~/.dotfiles-backup/<fecha>/`.

## Estructura

```
install.sh                 punto de entrada
scripts/                   lógica de instalación (un fichero por paso + lib.sh)
bash/bashrc                -> ~/.bashrc  (carga los módulos de bash/)
bash/*.sh                  opciones, exports, historial, alias, funciones, prompt, java
bash/inputrc               -> ~/.inputrc (autocompletado y búsqueda en historial)
git/gitconfig              -> ~/.gitconfig
git/ignore                 -> ~/.config/git/ignore (gitignore global)
vim/vimrc                  -> ~/.vimrc
editorconfig/editorconfig  -> ~/.editorconfig
java/maven/settings.xml    copiado (no enlazado) a ~/.m2/settings.xml si no existe
java/sdkman-candidates.txt JDK, Maven, Gradle a instalar
packages/apt.txt           paquetes del sistema
```

## Personalización local (no versionada)

- `~/.bashrc.local`: alias, variables o secretos propios de esa máquina.
- `~/.gitconfig.local`: identidad de git (y lo que quieras sobreescribir).

Ojo: como `~/.gitconfig` es un enlace al repo, `git config --global ...` modifica
el fichero del repo. Para cambios locales usa `git config --file ~/.gitconfig.local ...`.

## Probar en limpio

En una VM recién instalada de Ubuntu: clonar y ejecutar `./install.sh`.
