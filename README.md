# Dotfiles

> Kitty terminal · **Fish** shell · Starship prompt · btop monitor · fastfetch sysinfo — all under the **Ayu Dark** theme (blue as the primary accent).

Supports **Fedora**, **Ubuntu**, and **Arch** (the installer auto-detects the distro).

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
| Font      | JetBrainsMono Nerd Font (icons in the prompt, abbrevs and fastfetch) |

> Nerd Font is required for the icons (git branch , dir , OS , languages — all rendered via Nerd Font glyphs). The installer takes care of installing JetBrainsMono Nerd Font.

> Lean stack: fish (with native autosuggestions, syntax highlighting, and abbreviations), starship (prompt), btop (monitor), and fastfetch (sysinfo). `ls`, `cat`, `cd`, etc. use GNU coreutils defaults — no wrappers.

**Ayu Dark palette** — `#0A0E14` background · `#73D0FF` blue (primary) · `#FFD173` yellow · `#FF6767` red · `#AAD84C` green · `#F29E74` orange-magenta · `#686868` gray.

---

## Quick install

```bash
# installs everything (packages + symlinks + chsh)
curl -fsSL https://raw.githubusercontent.com/gustavx404/.dotfiles/main/scripts/install.sh | bash
```

Or, with the repo already cloned:

```bash
./scripts/install.sh            # install
./scripts/install.sh status     # check configuration status
./scripts/install.sh backup     # back up existing configs
./scripts/install.sh uninstall  # remove symlinks (does NOT uninstall packages)
```

The installer:

1. Detects the distro and installs via `dnf` / `apt` / `pacman`:
   `fish git unzip curl btop fastfetch` (one package at a time, so a missing package doesn't abort the whole transaction).
2. Installs **starship** via the official `starship.rs` script into `~/.local/bin` (not packaged in Fedora 44's dnf).
3. Installs **JetBrainsMono Nerd Font** (downloaded directly from GitHub).
4. Applies all symlinks (`~/.gitconfig`, `~/.config/{kitty,fish,starship,fastfetch,btop}`) and forcibly re-points stale symlinks from the old zsh setup.
5. Runs `chsh -s /usr/bin/fish` to make fish the default login shell.

Check status with `./scripts/install.sh status`.

### Login shell

The installer tries to make **fish** your login shell by updating `/etc/passwd` via `chsh`. The change only takes effect at the **next login** — already-running sessions keep their previous shell until reopened (Kitty/Wayland/desktop session).

If `chsh` fails (PAM, read-only filesystem, etc.), apply manually:

```bash
chsh -s /usr/bin/fish          # via PAM (asks for password)
sudo usermod -s /usr/bin/fish $USER   # direct fallback in /etc/passwd
```

If `$SHELL` still shows `/bin/bash` after installing:
- The **display manager** (`plasmalogin.service` on KDE Plasma 6 / Fedora 44+) likely started before `chsh` and cached your old `$SHELL`.
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
│   │   │   ├── 00-fastfetch.fish # auto-run fastfetch on startup
│   │   │   ├── env.fish          # PATH, EDITOR, PAGER
│   │   │   ├── starship.fish     # init starship
│   │   │   ├── abbrs.fish        # abbreviations (.. .., ls, git, etc)
│   │   │   └── distro.fish       # update/install/search aliases per distro
│   │   ├── functions/           # custom commands (autoload)
│   │   │   ├── mkcd.fish         # mkdir + cd
│   │   │   ├── killport.fish     # kill process on a port
│   │   │   ├── extract.fish      # unpack any extension
│   │   │   └── ports.fish        # list ports in LISTEN
│   │   └── completions/         # (empty — ready for customizations)
│   └── git/
│       └── .gitconfig          # git config with aliases
├── scripts/
│   └── install.sh              # multi-distro installer
```

> Fish auto-sources `~/.config/fish/conf.d/*.fish` at startup — `env`, `starship`, `abbrs`, and `distro` live in separate files.

---

## Kitty terminal

**Ayu Dark** theme loaded via `include current-theme.conf` (keeps colors separate from the config). 85% transparency + 30 blur.

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
| `update`   | update packages (dnf/apt/pacman)        |
| `install`  | install a package                      |
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

The `update`/`install`/`search` abbreviations are picked automatically based on the distro (`/etc/os-release`).

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
- **Kernel**: Fedora 44

Show system info in the terminal:

```bash
fastfetch
```
