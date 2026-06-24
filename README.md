# Dotfiles

Personal Linux dotfiles for an Arch-based setup. This repo installs common packages, links XDG config files, and sets up a few daily-driver tools.

## What's Included

- `install.fish` - installer for packages, AUR packages, `keyd`, and config symlinks.
- `packages/pacman.txt` - official repository packages.
- `packages/aur.txt` - AUR packages installed with `yay`.
- `config/` - files linked into `~/.config` with GNU Stow.
- `keyd/default.conf` - keyboard remaps for Caps Lock, Alt, and Meta.

Configured tools include Fish, Neovim/LazyVim, tmux, mise, sesh, tuicr, herdr, yazi-related CLI tooling, and Jujutsu.

## Usage

Clone the repo into `~/dotfiles`:

```sh
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
```

Run the installer with Fish:

```sh
fish install.fish
```

The installer will:

1. Install `yay` if it is missing.
2. Install packages from `packages/pacman.txt`.
3. Install AUR packages from `packages/aur.txt`.
4. Link `keyd/default.conf` into `/etc/keyd/default.conf`.
5. Enable and reload `keyd`.
6. Link everything under `config/` into `~/.config` with Stow.

After it finishes, restart your shell or run:

```sh
exec fish
```

## Manual Notes

- This repo assumes an Arch-based system with `pacman` and `sudo`.
- `git`, `fish`, and `stow` are listed in `packages/pacman.txt`; install them manually first if this is a completely fresh system.
- Config linking uses `stow --dir=~/dotfiles/config --target=~/.config .`, so each directory inside `config/` becomes a matching directory under `~/.config`.
- Review `packages/` and `keyd/default.conf` before running the installer on a new machine.
