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

1. Syncs the system first (`sudo pacman -Syu`, no partial upgrades), then installs — one package at a time so a missing one doesn't abort the whole transaction:
   `fish kitty git unzip curl github-cli btop fastfetch starship ttf-jetbrains-mono-nerd`
   (`--needed`, so re-running it is a no-op). Refreshes the font cache with `fc-cache -f`.
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
│   │   │   └── ports.fish        # list ports in LISTEN
│   │   └── completions/         # (empty — ready for customizations)
│   └── git/
│       └── .gitconfig          # git config with aliases
├── scripts/
│   ├── bootstrap.sh           # one-liner entry point (fetches install.sh)
│   └── install.sh              # pacman installer (CachyOS / Arch)
```

> Fish auto-sources `~/.config/fish/conf.d/*.fish` at startup — `env`, `starship`, `abbrs`, and `distro` live in separate files.

---

## Kitty terminal

**Ayu Dark** theme loaded via `include current-theme.conf` (keeps colors separate from the config). 85% transparency + 30 blur.

Kitty implements the kitty keyboard protocol, so `Shift+Enter` reaches apps as a distinct key with no extra config (unlike Alacritty, which needs a manual `\r` binding).

### Keyboard shortcuts (left-hand friendly, `Ctrl+Shift` prefix)

| Shortcut        | Action                |
|-----------------|-----------------------|
| `Ctrl+Shift+1…6`| Tab 1 to 6            |
| `Ctrl+Shift+W`  | New tab               |
| `Ctrl+Shift+Q`  | Close tab             |
| `Ctrl+Shift+A`  | Previous tab          |
| `Ctrl+Shift+D`  | Next tab              |
| `Ctrl+Shift+S`  | Horizontal split      |
| `Ctrl+Shift+F`  | Clear terminal        |

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
