# Dotfiles

> Kitty · **Fish** · Starship · btop · fastfetch — one **Ayu Dark** theme, blue as the accent.

Personal terminal setup for **CachyOS** (works on any Arch-based distro — Manjaro, Garuda, EndeavourOS, Artix, …). Single distro, single package manager: **pacman**. Every tool comes from the official repos — no `curl | sh`, no `cargo install`, no language runtimes.

![Terminal setup](terminal.png?v=2)

## Contents

- [Stack](#stack)
- [Install](#install) — [requirements](#requirements) · [one-liner](#one-liner) · [from a clone](#from-a-clone) · [just one config](#just-one-or-two-configs) · [what it does](#what-the-installer-does) · [after installing](#after-installing) · [login shell](#login-shell) · [updating](#updating) · [backups--uninstall](#backups--uninstall)
- [Structure](#structure) — [the `latest` tag](#the-latest-tag)
- [Kitty](#kitty-terminal) — [keyboard shortcuts (left-hand only)](#keyboard-shortcuts--left-hand-only)
- [Fish](#shell-fish) — [abbreviations](#abbreviations) · [functions](#functions) · [package aliases](#package-aliases)
- [Git](#git)
- [Reference machine](#reference-machine)

---

## Stack

| Component | Tool | Package |
|-----------|------|---------|
| Terminal  | [Kitty](https://sw.kovidgoyal.net/kitty/) 0.36+ | `kitty` |
| Shell     | [Fish](https://fishshell.com/) 3.7+ | `fish` |
| Prompt    | [Starship](https://starship.rs/) | `starship` |
| Sysinfo   | [fastfetch](https://github.com/fastfetch-cli/fastfetch) | `fastfetch` |
| Monitor   | [btop](https://github.com/aristocratos/btop) | `btop` |
| Editor    | [Neovim](https://neovim.io/) (`$EDITOR`, `git core.editor`) | `neovim` |
| GitHub    | [`gh`](https://cli.github.com/) CLI | `github-cli` |
| Font      | JetBrainsMono Nerd Font | `ttf-jetbrains-mono-nerd` |

**Ayu Dark palette** — `#0A0E14` bg · `#73D0FF` blue (primary) · `#FFD173` yellow · `#FF6767` red · `#AAD84C` green · `#F29E74` orange-magenta · `#686868` gray.

Deliberately lean: `ls`, `cat`, `cd`, `grep` stay as plain GNU coreutils — no `eza`/`bat`/`zoxide` wrappers. Fish's own autosuggestions, syntax highlighting and abbreviations cover the ergonomics. A **Nerd Font is required** for the prompt glyphs (git branch, dir, OS, language icons); `kitty` also renders it.

---

## Install

### Requirements

- CachyOS or an Arch-based distro (`pacman` on `PATH`)
- `sudo` rights and an internet connection

`git` and `curl` are installed by the installer if missing.

### One-liner

Fetches and runs the latest installer — packages, symlinks and `chsh` in one go:

```bash
curl -fsSL https://raw.githubusercontent.com/gustavx404/.dotfiles/refs/tags/latest/scripts/bootstrap.sh | bash
```

### From a clone

```bash
git clone https://github.com/gustavx404/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

./scripts/install.sh            # install
./scripts/install.sh status     # show what's linked / installed
./scripts/install.sh backup     # copy current configs to ~/.config/backup/<timestamp>/
./scripts/install.sh uninstall  # remove the symlinks (packages stay)
```

The clone location is irrelevant — `install.sh` links straight out of wherever the repo sits (`~/.dotfiles`, `~/Projetos/.dotfiles`, …).

### Just one or two configs

The configs are independent. To adopt only some, back up what's there and symlink by hand:

```bash
D=~/Projetos/.dotfiles                       # wherever you cloned it
mkdir -p ~/.config/backup
mv ~/.config/kitty ~/.config/backup/ 2>/dev/null

ln -s "$D/.config/kitty" ~/.config/kitty
ln -s "$D/.config/fish"  ~/.config/fish
ln -s "$D/.config/starship" ~/.config/starship
ln -s "$D/.config/git/.gitconfig" ~/.gitconfig
```

Open a **new** terminal window afterwards (running shells/kitty don't reload configs live).

### What the installer does

1. **Packages** — one pacman transaction: `sudo pacman -Syu --needed --noconfirm <list>` syncs the system and installs at once (no partial upgrades). List:
   `fish kitty neovim git unzip curl github-cli btop fastfetch starship ttf-jetbrains-mono-nerd`.
   `--needed` makes re-runs a no-op; one `-Syy` retry covers a stale mirror. Then `fc-cache -f`.
2. **Symlinks** — `~/.gitconfig` and `~/.config/{kitty,fish,starship,fastfetch,btop,environment.d}`, re-pointing any stale links from a previous setup.
3. **Login shell** — `chsh -s /usr/bin/fish` (falls back to `sudo usermod -s` if PAM blocks `chsh`).

No `pacman`? Step 1 is skipped, the symlinks are still applied.

### After installing

- Open a **new kitty window** (or `exec fish`) to pick up the shell + terminal config.
- **Reboot** — or `sudo systemctl restart plasmalogin.service` — so the graphical session picks up fish as `$SHELL` (see below).
- `./scripts/install.sh status` should show every entry linked.

### Login shell

`chsh` updates `/etc/passwd`, but it only takes effect at the **next login** — running sessions keep their old shell.

If both `chsh` and `usermod` fail, do it by hand:

```bash
chsh -s /usr/bin/fish                  # via PAM (asks for your password)
sudo usermod -s /usr/bin/fish "$USER"  # or edit /etc/passwd directly
```

If `$SHELL` still shows the old shell after that:

- On **KDE Plasma 6**, `plasmalogin.service` started before `chsh` and cached the old `$SHELL`.
- Fix: **reboot**, or `sudo systemctl restart plasmalogin.service` (drops the graphical session, forces a fresh login).
- `/etc/passwd` is already correct — check with `getent passwd "$USER" | cut -d: -f7`.

### Updating

Configs are symlinks, so a pull is enough:

```bash
cd ~/.dotfiles && git pull
```

New files under `conf.d/` / `functions/` are picked up on the next new shell. `kitty.conf` changes need a new kitty window (or `Ctrl+Shift+Q` then `R` to reload). Re-run `./scripts/install.sh` only when the package list or the set of linked configs changed.

### Backups & uninstall

- `install.sh` copies anything it's about to replace into `~/.config/backup/<timestamp>/` before linking.
- `./scripts/install.sh uninstall` removes the symlinks only — installed packages are left in place. Restore a config by moving its backup folder back.

---

## Structure

```
dotfiles/
├── .config/
│   ├── kitty/
│   │   ├── kitty.conf          # main config (left-hand keymap, QoL, includes the theme)
│   │   └── current-theme.conf  # Ayu Dark palette (colors only)
│   ├── starship/
│   │   └── starship.toml       # prompt, ayu_dark palette
│   ├── fastfetch/
│   │   └── config.jsonc        # sysinfo (blue keyColor)
│   ├── btop/
│   │   ├── btop.conf           # monitor (blue accent)
│   │   └── themes/ayu-dark.theme
│   ├── environment.d/
│   │   └── dotfiles.conf       # Wayland session PATH (~/.local/bin, ~/.cargo/bin, ~/.opencode/bin)
│   ├── fish/
│   │   ├── config.fish         # history, emacs key bindings, Ayu Dark fish_color_*
│   │   ├── conf.d/             # auto-sourced, alphabetical
│   │   │   ├── 05-fastfetch.fish  # run fastfetch on each interactive start
│   │   │   ├── abbrs.fish         # abbreviations (expand on space)
│   │   │   ├── distro.fish        # pacman aliases: update/install/search/remove/orphans/pacclean
│   │   │   ├── env.fish           # PATH, EDITOR=nvim, PAGER=less
│   │   │   └── starship.fish      # starship init
│   │   └── functions/          # autoloaded, one command per file
│   │       ├── extract.fish       # unpack any archive
│   │       ├── killport.fish      # kill whatever listens on a port
│   │       ├── mkcd.fish          # mkdir -p + cd
│   │       ├── ports.fish         # list LISTEN sockets
│   │       ├── ssh.fish           # kitten ssh inside kitty (ships terminfo)
│   │       └── ssh-terminfo.fish  # push xterm-kitty terminfo to a host
│   └── git/
│       └── .gitconfig          # aliases (git s / c / p / l / …)
└── scripts/
    ├── bootstrap.sh            # one-liner entry point (downloads install.sh)
    ├── install.sh              # pacman installer (install / status / backup / uninstall)
    └── hooks/
        └── pre-push           # moves the `latest` tag to each pushed main commit
```

### The `latest` tag

The one-liner installs from `refs/tags/latest`, so that tag must track `main`. The `pre-push` hook keeps it there — enable it once per clone:

```bash
git config core.hooksPath scripts/hooks
```

Every `git push` of `main` then re-points `latest` to the same commit and force-pushes the tag. Bypass for a single push with `SKIP_LATEST_SYNC=1 git push`.

---

## Kitty terminal

**Ayu Dark** via `include current-theme.conf` (colors kept separate from behaviour). 85% opacity + 30 blur, beam cursor (no blink), bell silent with a visual + tab marker, desktop notification when a background command finishes.

Kitty speaks the kitty keyboard protocol, so `Shift+Enter` arrives as a distinct key with no config (Alacritty needs a manual `\r` binding).

### Keyboard shortcuts — left-hand only

All of kitty's defaults are wiped (`clear_all_shortcuts yes`) and rebuilt so **nothing needs the right hand**. Prefix `Ctrl+Shift` (left-pinky claw); every action key is on the left half — `Q W E R T · A S D F G · Z X C V B`. No number row past `4`, no arrows, no `PageUp`/`Home`/`End`, no `[` `]`.

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+T` | New tab (inherits current dir) |
| `Ctrl+Shift+W` | Close tab |
| `Ctrl+Shift+A` / `D` | Previous / next tab |
| `Ctrl+Shift+1`–`4` | Jump to tab 1–4 |
| `Ctrl+Shift+S` | Split the window (larger axis) |
| `Ctrl+Shift+E` | Close pane |
| `Ctrl+Shift+R` | Cycle panes |
| `Ctrl+Shift+F` | Clear screen (`Ctrl+L`) |
| `Ctrl+Shift+B` | Scrollback in the pager (`/` to search) |
| `Ctrl+Shift+Z` / `X` | Jump to previous / next prompt |
| `Ctrl+Shift+G` | Show last command's output |
| `Ctrl+Shift+C` / `V` | Copy / paste |

**Leader** — `Ctrl+Shift+Q`, release, then one key (tap-tap, no chord held):

| Then | Action | Then | Action |
|------|--------|------|--------|
| `W` / `S` / `D` | Font bigger / smaller / reset | `Z` | Zoom the current pane |
| `C` | Previous pane | `A` / `F` | Move tab left / right |
| `T` | Toggle fullscreen | `B` | New OS window |
| `G` | Pick & open a URL on screen | `R` | Reload `kitty.conf` |
| `E` | Edit `kitty.conf` in an overlay | | |

`Ctrl+Shift+Z` / `G` rely on shell integration (automatic with fish). Splits use `enabled_layouts splits,stack` (already set). Selecting text with the mouse copies it (`copy_on_select`); middle-click pastes.

---

## Shell (Fish)

- **Prompt** — Starship, `ayu_dark` palette (`~/.config/starship/starship.toml`): OS icon, git branch + dirty/staged state, language versions (Python, Node, Rust, Go, PHP, Java), command duration, arrow.
- **No greeting** — the fish welcome banner is silenced; each interactive shell runs `fastfetch` instead (skipped if its config isn't linked).
- **Native fish** — autosuggestions (Ayu gray), syntax highlighting, abbreviations. Emacs key bindings (`Ctrl+A`/`E`/`K`/…).
- **`EDITOR`** is `nvim` when present, else `vi`; `PAGER` is `less -R`.

### Abbreviations

`conf.d/abbrs.fish` — expand when you press space, so the real command lands in history:

| Abbr | Expands to |
|------|-----------|
| `..` / `...` / `....` | `cd` up 1 / 2 / 3 levels |
| `ls` / `ll` / `la` / `l` | GNU `ls` variants, colored |
| `g` / `gs` / `ga` / `gc` / `gp` / `gl` / `gd` | `git` / `git s` / `a` / `c` / `p` / `l` / `d` |
| `top` / `htop` | `btop` |
| `df` / `du` / `free` | `-h` variants |
| `dk` / `dc` | `docker` / `docker compose` |
| `fishrc` | `$EDITOR ~/.config/fish/config.fish` |
| `reload` | `exec fish` |
| `weather` | `curl -s wttr.in \| head -20` |

### Functions

`~/.config/fish/functions/` — one autoloaded command per file:

| Function | What it does |
|----------|--------------|
| `mkcd <dir>` | `mkdir -p` then `cd` into it |
| `extract <file>` | unpack `.tar.*`, `.zip`, `.7z`, `.rar`, `.zst`, … |
| `killport <port>` | kill whatever is listening on `<port>` |
| `ports` | list sockets in `LISTEN` |
| `ssh` | inside kitty → `kitten ssh` (copies the `xterm-kitty` terminfo to the host); plain `ssh` otherwise |
| `ssh-terminfo <host>` | one-shot: install the `xterm-kitty` terminfo on a host you can't reach with `kitten ssh` (jump host, from inside tmux, Ansible) |

> **Why `ssh` is wrapped** — kitty sets `TERM=xterm-kitty`. A host without that terminfo entry breaks ncurses apps (`nano`, `htop`, …) with `cannot initialize terminal type ($TERM="xterm-kitty")`. `kitten ssh` ships the entry on connect. The wrapper steps aside inside tmux/screen and when kitty isn't the terminal; `git` / `rsync` / `scp` invoke the `ssh` binary directly and are never affected.

### Package aliases

`conf.d/distro.fish` (pacman-only):

| Alias | Command |
|-------|---------|
| `update` | `sudo pacman -Syu` |
| `install` | `sudo pacman -S` |
| `search` | `pacman -Ss` |
| `remove` | `sudo pacman -Rns` |
| `orphans` | `pacman -Qtdq` |
| `pacclean` | `sudo pacman -Sc` |

---

## Git

Aliases in `~/.config/git/.gitconfig`:

| Alias | Command | | Alias | Command |
|-------|---------|-|-------|---------|
| `git s` | `status` | | `git co` | `checkout` |
| `git c` | `commit` | | `git cb` | `checkout -b` |
| `git a` | `add` | | `git br` | `branch` |
| `git p` | `push` | | `git last` | `log -1 HEAD` |
| `git l` | `log --oneline --graph` | | `git unstage` | `reset HEAD --` |
| `git d` | `diff` | | `git amend` | `commit --amend --no-edit` |

---

## Reference machine

| | |
|-|-|
| CPU | AMD Ryzen 5 5600X (12) @ 4.65 GHz |
| GPU | AMD Radeon RX 6600 XT |
| RAM | 16 GB |
| Storage | 1 TB NVMe (btrfs) |
| Desktop | KDE Plasma (Wayland) |
| OS | CachyOS (Arch-based) |

```bash
fastfetch   # show it in the terminal
```
