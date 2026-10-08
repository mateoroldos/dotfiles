# Dotfiles

Personal dotfiles for an Arch desktop and a Debian 13 devbox. `mise bootstrap` installs system packages, links configs into `~/.config`, and installs dev tools.

Configured tools include Fish, Neovim/LazyVim, tmux, mise, sesh, tuicr, herdr, yazi, and Jujutsu.

## Layout

```text
mise.toml          every machine: pacman/apt packages, login shell, docker, portless, config/ → ~/.config
mise.desktop.toml  desktop apps, fonts, keyd, desktop/config/ → ~/.config
config/            linked into ~/.config on every machine
desktop/           desktop-only configs and keyd/default.conf
```

Dev tools live in `config/mise/config.toml`, mise's global config. Add one with `mise use -g <tool>`.

## Usage

The repo must live at `~/dotfiles`; `mise.toml` sets it as `dotfiles.root`.

Install mise and the AUR helper first: on Arch, `pacman -S mise yay`. On Debian, `curl https://mise.run | sh`; this also needs `sudo` and `curl`.

```sh
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
mise trust

mise bootstrap              # devbox
mise -E desktop bootstrap   # desktop
```

Add `--dry-run` to preview.

Log in again afterwards so fish becomes the login shell.

## Portless

`portless` is installed globally by mise (`npm:portless` in `config/mise/config.toml`), not
from the AUR - the AUR package lags npm by several minor versions, and the proxy and the
`portless` a repo runs must speak the same route-file format.

The `bootstrap` task in `mise.toml` registers the proxy as a systemd service, so one process owns port 443 for
`*.localhost` from boot. Without it, the proxy is started ad-hoc by whichever repo runs
`portless` first; when that repo's version differs, every other app 404s with
"No app registered".

After `mise upgrade`, restart the service so it picks up the new binary:

```sh
sudo systemctl restart portless
```
