# Dotfiles

Configurações pessoais do terminal e ferramentas. Compatível com Fedora, Ubuntu e Arch.

![Terminal Setup](terminal.png)

## Stack

- **Terminal**: Kitty 0.47.1 (tema Ayu Dark)
- **Shell**: Bash 5.3.9 / ZSH
- **Fonte**: JetBrainsMono Nerd Font
- **WM**: KDE Plasma (Wayland)
- **SO**: Fedora Linux 44

## Instalação Rápida

```bash
git clone https://github.com/SEU_USER/dotfiles.git ~/Projects/dotfiles
cd ~/Projects/dotfiles
./scripts/install.sh
```

## Comandos

| Comando | Descrição |
|---------|-----------|
| `./scripts/install.sh` | Instalar todos os dotfiles |
| `./scripts/install.sh status` | Verificar status das configs |
| `./scripts/install.sh backup` | Backup das configs existentes |

## Estrutura

```
dotfiles/
├── .config/
│   ├── kitty/          # Terminal Kitty (tema Ayu Dark)
│   ├── fastfetch/      # Sistema de informações
│   ├── shell/          # ZSH/Bash configs e aliases
│   └── git/            # Git config com aliases
├── scripts/
│   └── install.sh      # Instalador multi-distro
├── .opencode/
│   └── skills/         # Skills para opencode
│       ├── dotfile-manager/
│       └── cross-platform/
└── opencode.json
```

## Kitty Terminal

Tema: **Ayu Dark** com transparência e abas powerline.

### Atalhos de Teclado (mão esquerda)

| Atalho | Ação |
|--------|------|
| `Alt+A` | Tab 1 |
| `Alt+S` | Tab 2 |
| `Alt+D` | Tab 3 |
| `Alt+F` | Tab 4 |
| `Alt+W` | Nova aba |
| `Alt+Z` | Fechar aba |
| `Alt+Q/E` | Mover aba |

## Shell

Aliases e configs para ZSH e Bash. Editar `~/.config/shell/aliases.zsh` ou `~/.config/shell/aliases.bash`.

### Aliases Shell

| Alias | Comando |
|-------|---------|
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `ll` | `ls -la` |
| `la` | `ls -A` |
| `update` | `sudo dnf update` |
| `install` | `sudo dnf install` |
| `reload` | `source ~/.config/shell/.zshrc` |

## Git

Configuração com aliases úteis. Editar `~/.config/git/.gitconfig`.

### Aliases Git

| Alias | Comando |
|-------|---------|
| `git s` | `git status` |
| `git c` | `git commit` |
| `git p` | `git push` |
| `git l` | `git log --oneline --graph` |
| `git a` | `git add` |
| `git d` | `git diff` |
| `git co` | `git checkout` |
| `git cb` | `git checkout -b` |
| `git br` | `git branch` |
| `git last` | `git log -1 HEAD` |
| `git unstage` | `git reset HEAD --` |
| `git amend` | `git commit --amend --no-edit` |

## Compatibilidade

| Distribuição | Gerenciador |
|--------------|-------------|
| Fedora | `dnf` |
| Ubuntu | `apt` |
| Arch | `pacman` |

O instalador detecta automaticamente a distribuição e usa o gerenciador de pacotes correto.

## Hardware

- **CPU**: AMD Ryzen 5 5600X (12) @ 4.65 GHz
- **GPU**: AMD Radeon RX 6600 XT
- **RAM**: 16 GB
- **Storage**: 1TB NVMe (btrfs)
