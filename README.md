# Dotfiles

Personal Linux dotfiles for an Arch-based setup. This repo installs common packages, links XDG config files, and sets up a few daily-driver tools.

## What's Included

- `install.fish` - installer for packages, AUR packages, `keyd`, and config symlinks.
- `packages/pacman.txt` - official repository packages.
- `packages/aur.txt` - AUR packages installed with `yay`.
- `config/` - files linked into `~/.config` with GNU Stow.
- `config/mise/config.toml` - dev tools installed globally by mise, including `npm:portless`.
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
7. Install the mise tools from `config/mise/config.toml`.
8. Install the portless proxy as a system service.

After it finishes, restart your shell or run:

```sh
exec fish
```

## Portless

`portless` is installed globally by mise (`npm:portless` in `config/mise/config.toml`), not
from the AUR - the AUR package lags npm by several minor versions, and the proxy and the
`portless` a repo runs must speak the same route-file format.

`install.fish` registers the proxy as a systemd service, so one process owns port 443 for
`*.localhost` from boot. Without it, the proxy is started ad-hoc by whichever repo runs
`portless` first; when that repo's version differs, every other app 404s with
"No app registered".

After `mise upgrade`, restart the service so it picks up the new binary:

```sh
sudo systemctl restart portless
```

## Manual Notes

- This repo assumes an Arch-based system with `pacman` and `sudo`.
- `git`, `fish`, and `stow` are listed in `packages/pacman.txt`; install them manually first if this is a completely fresh system.
- Config linking uses `stow --dir=~/dotfiles/config --target=~/.config .`, so each directory inside `config/` becomes a matching directory under `~/.config`.
- Review `packages/` and `keyd/default.conf` before running the installer on a new machine.
