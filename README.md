# Dotfiles

> Kitty terminal · **Fish** shell · Starship prompt · btop monitor · fastfetch sysinfo — all under the **Ayu Dark** theme (blue as the primary accent).

Built for **CachyOS** (and Arch / Arch-based derivatives — Manjaro, Garuda, EndeavourOS, Artix, ...). Single distro, single package manager: **pacman**. Every package comes from the official CachyOS/Arch repos — no `curl | sh` fallbacks.

![Terminal Setup](terminal.png?v=2)

---

## Stack

| Component | Tool                                          |
|-----------|-----------------------------------------------|
| Terminal  | [Kitty](https://sw.kovidgoyal.net/kitty/) 0.47+ |
| Shell     | [Fish](https://fishshell.com/) 3.7+ (native autosuggestions + syntax highlighting) |
| Prompt    | [Starship](https://starship.rs/) with Ayu Dark palette |
| Sysinfo   | [fastfetch](https://github.com/fastfetch-cli/fastfetch) |
| Monitor   | [btop](https://github.com/aristocratos/btop) (custom Ayu Dark theme) |
| GitHub    | [`gh`](https://cli.github.com/) CLI |
| Font      | JetBrainsMono Nerd Font (icons in the prompt, abbrevs and fastfetch) |

> Nerd Font is required for the icons (git branch , dir , OS , languages — all rendered via Nerd Font glyphs). The installer pulls it from the repos with `sudo pacman -S ttf-jetbrains-mono-nerd`; run that command yourself if you only want the font.

> Lean stack: fish (with native autosuggestions, syntax highlighting, and abbreviations), starship (prompt), btop (monitor), and fastfetch (sysinfo). `ls`, `cat`, `cd`, etc. use GNU coreutils defaults — no wrappers.

**Ayu Dark palette** — `#0A0E14` background · `#73D0FF` blue (primary) · `#FFD173` yellow · `#FF6767` red · `#AAD84C` green · `#F29E74` orange-magenta · `#686868` gray.

---

## Install

**Requirements:** CachyOS or an Arch-based distro (pacman), `sudo`, and an internet connection. `git` and `curl` are pulled in by the installer if missing.

### One-liner

```bash
# Installs everything (packages + symlinks + chsh).
# Always fetches the newest version via the 'latest' tag:
curl -fsSL https://raw.githubusercontent.com/gustavx404/.dotfiles/refs/tags/latest/scripts/bootstrap.sh | bash
```

### From a clone

```bash
git clone https://github.com/gustavx404/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

./scripts/install.sh            # install
./scripts/install.sh status     # check configuration status
./scripts/install.sh backup     # back up existing configs
./scripts/install.sh uninstall  # remove symlinks (does NOT uninstall packages)
```

The clone location doesn't matter — `install.sh` symlinks straight out of wherever the repo lives, so keep it in `~/.dotfiles`, `~/Projetos/.dotfiles`, or anywhere else.

The installer:

1. Installs everything in **one pacman transaction** — `sudo pacman -Syu --needed --noconfirm <packages>` syncs the system and pulls the packages at once (no partial upgrades):
   `fish kitty git unzip curl github-cli btop fastfetch starship ttf-jetbrains-mono-nerd`
   `--needed` makes re-runs a no-op; a single retry with `-Syy` covers a stale mirror. Then refreshes the font cache with `fc-cache -f`.
2. Applies all symlinks (`~/.gitconfig`, `~/.config/{kitty,fish,starship,fastfetch,btop,environment.d}`) and forcibly re-points stale symlinks from the old zsh setup.
3. Runs `chsh -s /usr/bin/fish` to make fish the default login shell (falls back to `sudo usermod -s` if PAM blocks `chsh`).

If `pacman` isn't found the installer skips step 1 and still applies the symlinks. Check status with `./scripts/install.sh status`.

### Login shell

The installer tries to make **fish** your login shell by updating `/etc/passwd` via `chsh`. The change only takes effect at the **next login** — already-running sessions keep their previous shell until reopened (Kitty/Wayland/desktop session).

If `chsh` fails (PAM restrictions), the installer automatically falls back to `sudo usermod -s`. Only if both fail, apply manually:

```bash
chsh -s /usr/bin/fish          # via PAM (asks for password)
sudo usermod -s /usr/bin/fish $USER   # direct fallback in /etc/passwd
```

If `$SHELL` still shows the old shell after installing:
- The **display manager** (`plasmalogin.service` on KDE Plasma 6) likely started before `chsh` and cached your old `$SHELL`.
- Fix: **reboot** (or, to avoid a full reboot, run `sudo systemctl restart plasmalogin.service` — this drops the graphical session and forces a fresh login that respects `/etc/passwd`).
- Nothing for the script to fix — `/etc/passwd` is already correct (`getent passwd $USER | cut -d: -f7`).

---

## Structure

```
dotfiles/
├── .config/
│   ├── kitty/
│   │   ├── kitty.conf         # main config (includes the theme)
│   │   └── current-theme.conf # Ayu Dark palette (colors only)
│   ├── starship/
│   │   └── starship.toml       # prompt with ayu_dark palette
│   ├── fastfetch/
│   │   └── config.jsonc        # system info (blue keyColor)
│   ├── btop/
│   │   ├── btop.conf            # monitor config (blue accent)
│   │   └── themes/
│   │       └── ayu-dark.theme   # custom Ayu Dark theme
│   ├── environment.d/
│   │   └── dotfiles.conf          # Wayland PATH (~/.local/bin, ~/.cargo/bin, ~/.opencode/bin)
│   ├── fish/
│   │   ├── config.fish          # main config (colors, history, key bindings)
│   │   ├── conf.d/              # auto-sourced by fish
│   │   │   ├── 05-fastfetch.fish # auto-run fastfetch on startup
│   │   │   ├── env.fish          # PATH, EDITOR, PAGER
│   │   │   ├── starship.fish     # init starship
│   │   │   ├── abbrs.fish        # abbreviations (.. .., ls, git, etc)
│   │   │   └── distro.fish       # pacman aliases (update/install/search/remove)
│   │   ├── functions/           # custom commands (autoload)
│   │   │   ├── mkcd.fish         # mkdir + cd
│   │   │   ├── killport.fish     # kill process on a port
│   │   │   ├── extract.fish      # unpack any extension
│   │   │   ├── ports.fish        # list ports in LISTEN
│   │   │   ├── ssh.fish          # kitten ssh inside kitty (ships terminfo)
│   │   │   └── ssh-terminfo.fish # push xterm-kitty terminfo to a host
│   │   └── completions/         # (empty — ready for customizations)
│   └── git/
│       └── .gitconfig          # git config with aliases
├── scripts/
│   ├── bootstrap.sh           # one-liner entry point (fetches install.sh)
│   ├── install.sh              # pacman installer (CachyOS / Arch)
│   └── hooks/
│       └── pre-push           # keeps the `latest` tag on top of main
```

> Fish auto-sources `~/.config/fish/conf.d/*.fish` at startup — `env`, `starship`, `abbrs`, and `distro` live in separate files.

### The `latest` tag

The one-liner installs from `refs/tags/latest`, so that tag has to follow `main`. A `pre-push` hook does it automatically — enable it once per clone:

```bash
git config core.hooksPath scripts/hooks
```

From then on every `git push` of `main` re-points `latest` to the same commit and force-pushes the tag. Skip it for a one-off push with `SKIP_LATEST_SYNC=1 git push`.

---

## Kitty terminal

**Ayu Dark** theme loaded via `include current-theme.conf` (keeps colors separate from the config). 85% transparency + 30 blur.

Kitty implements the kitty keyboard protocol, so `Shift+Enter` reaches apps as a distinct key with no extra config (unlike Alacritty, which needs a manual `\r` binding).

### Keyboard shortcuts — left-hand only

Every default kitty shortcut is wiped (`clear_all_shortcuts yes`) and rebuilt so **nothing needs the right hand**: prefix is `Ctrl+Shift` (left-pinky claw) and every action key sits on the left half — `Q W E R T · A S D F G · Z X C V B`. No number row past `4`, no arrows, no `PageUp`/`Home`/`End`, no `[` `]`.

| Shortcut         | Action                                    |
|------------------|-------------------------------------------|
| `Ctrl+Shift+T`   | New tab (inherits current dir)            |
| `Ctrl+Shift+W`   | Close tab                                  |
| `Ctrl+Shift+A` / `D` | Previous / next tab                    |
| `Ctrl+Shift+1`–`4` | Jump to tab 1–4                          |
| `Ctrl+Shift+S`   | Split (along the larger axis)              |
| `Ctrl+Shift+E`   | Close pane                                 |
| `Ctrl+Shift+R`   | Cycle panes                                |
| `Ctrl+Shift+F`   | Clear screen (`Ctrl+L`)                    |
| `Ctrl+Shift+B`   | Scrollback in the pager (search with `/`)  |
| `Ctrl+Shift+Z` / `X` | Jump to previous / next prompt         |
| `Ctrl+Shift+G`   | Show last command output                   |
| `Ctrl+Shift+C` / `V` | Copy / paste                           |

**Leader** — `Ctrl+Shift+Q`, release, then a key (tap-tap, no chord held):

| Then… | Action                          | Then… | Action                  |
|-------|---------------------------------|-------|-------------------------|
| `W` / `S` / `D` | Font bigger / smaller / reset | `Z` | Zoom the current pane |
| `C`   | Previous pane                   | `A` / `F` | Move tab left / right |
| `T`   | Toggle fullscreen               | `B`   | New OS window            |
| `G`   | Pick / open a URL on screen     | `R`   | Reload `kitty.conf`     |
| `E`   | Edit `kitty.conf` in an overlay |       |                         |

`Ctrl+Shift+Z` / `G` need shell integration (automatic with fish); splits need `enabled_layouts splits,stack` (already set).

---

## Shell (Fish)

- **Prompt**: Starship (`ayu_dark` palette in `~/.config/starship/starship.toml`). Uses Nerd Font icons throughout: OS indicator, git branch, modified/deleted/staged status, languages (Python, Node, Rust, Go, PHP, Java), command duration, prompt arrow.
- **Greeting disabled** — no welcome banner at all (just the prompt and fastfetch startup).
- **Native to fish**: autosuggestions (Ayu gray), syntax highlighting (valid/invalid command coloring), abbreviations (`abbr` that expand when you press space).

### Abbreviations (`conf.d/abbrs.fish`, expand on space)

| Abbr       | Command                                |
|------------|----------------------------------------|
| `.. … ….`  | `cd` up one/two/three levels           |
| `ls/ll/la` | listing (GNU ls with colors)           |
| `update`   | `sudo pacman -Syu`                     |
| `install`  | `sudo pacman -S <pkg>`                 |
| `g/gs/gl`  | git shortcuts (`git s`, `git l`...)    |
| `top`      | `btop` (with Ayu theme)                |
| `htop`     | `btop` (alias)                         |
| `reload`   | `exec fish` (restart the shell)        |
| `dk/dc`    | docker / docker compose                |

### Functions (`~/.config/fish/functions/`)

| Function         | What it does                                |
|------------------|---------------------------------------------|
| `mkcd <dir>`     | create a directory and cd into it            |
| `extract <file>` | unpack (tar.gz, zip, 7z, rar, zst...)        |
| `killport <p>`   | kill the process listening on port `p`       |
| `ports`          | list ports in LISTEN                         |
| `ssh`            | inside kitty, runs `kitten ssh` (ships the `xterm-kitty` terminfo to the host); plain `ssh` otherwise |
| `ssh-terminfo <host>` | one-shot: install the `xterm-kitty` terminfo on a host you can't reach with `kitten ssh` |

> **Why `ssh` is wrapped:** kitty sets `TERM=xterm-kitty`; hosts without that terminfo entry break ncurses apps with `cannot initialize terminal type ($TERM="xterm-kitty")`. `kitten ssh` copies the entry on connect. The wrapper skips itself inside tmux/screen and when kitty isn't the terminal; `git`/`rsync`/`scp` call the `ssh` binary directly and are unaffected.

`conf.d/distro.fish` also defines `search` (`pacman -Ss`), `remove` (`sudo pacman -Rns`), `orphans` (`pacman -Qtdq`) and `pacclean` (`sudo pacman -Sc`).

---

## Git

Config with useful aliases — edit `~/.config/git/.gitconfig`.

| Alias        | Command                       |
|--------------|-------------------------------|
| `git s`      | `status`                      |
| `git c`      | `commit`                      |
| `git p`      | `push`                        |
| `git l`      | `log --oneline --graph`       |
| `git a`      | `add`                         |
| `git d`      | `diff`                        |
| `git co`     | `checkout`                    |
| `git cb`     | `checkout -b`                 |
| `git br`     | `branch`                      |
| `git last`   | `log -1 HEAD`                 |
| `git unstage`| `reset HEAD --`               |
| `git amend`  | `commit --amend --no-edit`     |

---

## Reference machine

- **CPU**: AMD Ryzen 5 5600X (12) @ 4.65 GHz
- **GPU**: AMD Radeon RX 6600 XT
- **RAM**: 16 GB
- **Storage**: 1 TB NVMe (btrfs)
- **WM**: KDE Plasma (Wayland)
- **OS**: CachyOS (Arch-based)

Show system info in the terminal:

```bash
fastfetch
```
