# Dotfiles

> Terminal Kitty · **Fish** · Starship · zoxide · fzf · eza — tudo sob o tema **Ayu Dark** (azul como acento principal).

Suporte a **Fedora**, **Ubuntu** e **Arch** (instalador detecta a distro automaticamente).

![Terminal Setup](terminal.png)

---

## Stack

| Camada       | Ferramenta                          |
|--------------|-------------------------------------|
| Terminal     | [Kitty](https://sw.kovidgoyal.net/kitty/) 0.47+ |
| Shell        | [Fish](https://fishshell.com/) 3.7+ (autosuggestions + syntax highlight nativos) |
| Prompt       | [Starship](https://starship.rs/) com palette Ayu Dark |
| cd inteligente | [zoxide](https://github.com/ajeetdsouza/zoxide) |
| Fuzzy finder | [fzf](https://github.com/junegunn/fzf) com preview bat/eza |
| `ls`         | [eza](https://github.com/eza-community/eza) |
| `cat`        | [bat](https://github.com/sharkdp/bat) (tema Ayu) |
| info         | [fastfetch](https://github.com/fastfetch-cli/fastfetch) |
| Monitor      | [btop](https://github.com/aristocratos/btop) (tema Ayu Dark custom) |
| Fonte        | JetBrainsMono Nerd Font |

> Fish puro, sem plugin manager — autosuggestions, syntax-highlight, abbrs e key bindings já vêm prontos.

**Paleta Ayu Dark** — `#0A0E14` fundo · `#73D0FF` azul (primária) · `#FFD173` amarelo · `#FF6767` vermelho · `#AAD84C` verde · `#F29E74` laranja-magenta · `#686868` cinza.

---

## Instalação rápida

```bash
# instala tudo (pacotes + symlinks + chsh)
curl -fsSL https://raw.githubusercontent.com/gustavx404/.dotfiles/main/scripts/install.sh | bash
```

Ou, com o repositório já clonado:

```bash
./scripts/install.sh            # instalar
./scripts/install.sh status     # verificar configurações
./scripts/install.sh backup     # backup das configs existentes
./scripts/install.sh uninstall  # remover symlinks (não desinstala pacotes)
```

O instalador:

1. Detecta a distro e instala via `dnf` / `apt` / `pacman`:
   `fish zoxide fzf eza bat fastfetch fd git unzip curl btop` (pacote-a-pacote, pra não derrubar a transação quando um falta).
2. Instala **starship** via script oficial de `starship.rs` em `~/.local/bin` (não empacotado no dnf do Fedora 44).
3. Instala **JetBrainsMono Nerd Font** (download direto do GitHub).
4. Aplica todos os symlinks (`~/.gitconfig`, `~/.config/{kitty,fish,starship,fastfetch,btop}`) e força reaponto de symlinks antigos/stale (do tempo do zsh).
5. Roda `chsh -s /usr/bin/fish` para tornar o fish o shell padrão de login.

Verifique o status com `./scripts/install.sh status`.

### Shell de login

O instalador tenta tornar o **fish** seu shell de login trocando `/etc/passwd` via `chsh`. A troca **só vale a partir do próximo login** — sessões já abertas continuam com o shell anterior até serem reabertas (Kitty/Wayland/desktop session).

Se `chsh` falhar (PAM, escritura read-only, etc.), aplique manualmente:

```bash
chsh -s /usr/bin/fish          # via PAM (pede senha)
sudo usermod -s /usr/bin/fish $USER   # fallback direto em /etc/passwd
```

Após instalar, se `$SHELL` ainda mostrar `/bin/bash`:
- Provavelmente o **display manager** (`plasmalogin.service` no KDE Plasma 6 / Fedora 44+) iniciou antes do `chsh` e cached seu `SHELL` antigo.
- Solução: **reiniciar o computador** (ou, se quiser evitar reboot completo, rodar `sudo systemctl restart plasmalogin.service` — derruba a sessão gráfica e força novo login que vai respeitar `/etc/passwd`).
- Não há nada para o script corrigir — `/etc/passwd` já está correto (`getent passwd $USER | cut -d: -f7`).

---

## Estrutura

```
dotfiles/
├── .config/
│   ├── kitty/
│   │   ├── kitty.conf         # config principal (inclui o tema)
│   │   └── current-theme.conf # paleta Ayu Dark (somente cores)
│   ├── starship/
│   │   └── starship.toml       # prompt com palette ayu_dark
│   ├── fastfetch/
│   │   └── config.jsonc        # info do sistema (azul como keyColor)
│   ├── btop/
│   │   ├── btop.conf            # config de monitor (blue/azul)
│   │   └── themes/
│   │       └── ayu-dark.theme   # tema Ayu Dark custom
│   ├── fish/
│   │   ├── config.fish          # config principal (cores, history, key bindings)
│   │   ├── conf.d/              # auto-sourced pelo fish
│   │   │   ├── 00-fastfetch.fish # auto-run fastfetch no inicio
│   │   │   ├── env.fish          # PATH, EDITOR, BAT_THEME
│   │   │   ├── starship.fish     # init starship
│   │   │   ├── zoxide.fish       # init zoxide
│   │   │   ├── fzf.fish          # fzf + key bindings + cores Ayu
│   │   │   ├── abbrs.fish        # abreviações (.. .., ls, git, etc)
│   │   │   └── distro.fish       # aliases update/install/search por distro
│   │   ├── functions/           # comandos personalizados (autoload)
│   │   │   ├── zi.fish           # zoxide interativo com fzf
│   │   │   ├── mkcd.fish         # mkdir + cd
│   │   │   ├── killporta.fish    # mata processo numa porta
│   │   │   ├── extract.fish      # descompacta qualquer extensão
│   │   │   └── ports.fish        # lista portas em LISTEN
│   │   └── completions/         # (vazio — pronto pra customizações)
│   └── git/
│       └── .gitconfig          # git config com aliases
├── scripts/
│   └── install.sh              # instalador multi-distro
```

> Fish auto-sourceia `~/.config/fish/conf.d/*.fish` na inicialização — `env`, `starship`, `zoxide`, `fzf`, `abbrs` e `distro` ficam em arquivos separados.

---

## Kitty Terminal

Tema **Ayu Dark** carregado via `include current-theme.conf` (mantém cores separadas da config). Transparência 85% + blur 30.

### Atalhos de teclado (mão esquerda)

Todos usam `Alt` (mod1) para operar só com a mão esquerda.

| Atalho          | Ação                  |
|-----------------|-----------------------|
| `Ctrl+Shift+1…6`| Aba 1 a 6             |
| `Ctrl+Shift+W`  | Nova aba              |
| `Ctrl+Shift+Q`  | Fechar aba            |
| `Ctrl+Shift+A`  | Aba anterior          |
| `Ctrl+Shift+D`  | Próxima aba           |
| `Ctrl+Shift+S`  | Split horizontal      |
| `Ctrl+Shift+F`  | Limpar terminal       |

---

## Shell (Fish)

- **Prompt**: Starship (palette `ayu_dark` em `~/.config/starship/starship.toml`).
- **cd**: `zoxide` apelidado como `cd` (`z init --cmd cd`) + função `zi` interativo.
- **fzf**: cores Ayu em `FZF_DEFAULT_OPTS`, key-bindings do fzf carregados em `conf.d/fzf.fish`:
  - `Ctrl+T` → selecionar arquivo (preview bat)
  - `Alt+C` → selecionar diretório para cd (preview eza --tree)
  - `Ctrl+R` → history com preview
- **eza**: substitui `ls` com ícones e git status.
- **bat**: `cat` abreviado para `bat` com tema `ayu`.
- **btop**: substitui `top`/`htop` — tema Ayu Dark custom em `.config/btop/themes/ayu-dark.theme`.
- **Nativo do fish**: autosuggestions (cinza Ayu), syntax-highlight (comando válido/inválido colorido), abreviações (`abbr` que expandem ao apertar espaço).

### Abbreviations (`conf.d/abbrs.fish`, expandem ao apertar espaço)

| Abbr       | Comando                                |
|------------|----------------------------------------|
| `.. … ….`  | `cd` um/dois/três níveis               |
| `ls/ll/la` | listagem (eza com ícones)              |
| `update`   | atualiza pacotes (dnf/apt/pacman)     |
| `install`  | instala pacote                         |
| `g/gs/gl`  | atalhos git (`git s`, `git l`...)      |
| `cat`      | `bat --style=plain`                    |
| `top`      | `btop` (com tema Ayu)                  |
| `htop`     | `btop` (alias)                          |
| `reload`   | `exec fish` (reinicia o shell)         |
| `dk/dc`    | docker / docker compose                |

### Funções (em `~/.config/fish/functions/`)

| Função             | O que faz                                  |
|--------------------|--------------------------------------------|
| `zi`               | zoxide interativo (fzf + preview eza-tree) |
| `mkcd <dir>`       | cria e entra num diretório                 |
| `extract <arq>`    | descompacta (tar.gz, zip, 7z, rar, zst...) |
| `killporta <p>`    | mata processo ouvindo na porta `p`         |
| `ports`            | lista portas em LISTEN                     |

Diferentes aliases de `update/install/search` são escolhidos automaticamente conforme a distro (`/etc/os-release`).

---

## Git

Configuração com aliases úteis — editar `~/.config/git/.gitconfig`.

| Alias | Comando                       |
|-------|------------------------------|
| `git s`  | `status`                  |
| `git c`  | `commit`                  |
| `git p`  | `push`                    |
| `git l`  | `log --oneline --graph`   |
| `git a`  | `add`                     |
| `git d`  | `diff`                    |
| `git co` | `checkout`                |
| `git cb` | `checkout -b`             |
| `git br` | `branch`                  |
| `git last` | `log -1 HEAD`           |
| `git unstage` | `reset HEAD --`     |
| `git amend` | `commit --amend --no-edit` |

---

## Detalhes da máquina de referência

- **CPU**: AMD Ryzen 5 5600X (12) @ 4.65 GHz
- **GPU**: AMD Radeon RX 6600 XT
- **RAM**: 16 GB
- **Storage**: 1TB NVMe (btrfs)
- **WM**: KDE Plasma (Wayland)
- **Kernel**: Fedora 44

Visualize o sistema no terminal:

```bash
fastfetch
```
