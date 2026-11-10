# My-DMS-dotfiles

My niri + DankMaterialShell (DMS) desktop, backed up as installable dotfiles.

Everything colour-related is generated from the current wallpaper by DMS/matugen:
niri, DankMaterialShell, Starship, kitty, Ghostty, Neovim, Zed, GTK 3/4, Qt,
and Zen Browser.

## Install

```bash
git clone https://github.com/praveenshabnam010-ctrl/My-DMS-dotfiles.git ~/My-DMS-dotfiles
~/My-DMS-dotfiles/install.sh
```

Or run the installer directly:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/praveenshabnam010-ctrl/My-DMS-dotfiles/main/install.sh)"
```

Install the package set first (EndeavourOS/Arch, uses `yay`/`paru`/`pacman`):

```bash
~/My-DMS-dotfiles/install.sh --packages
```

Useful options:

```bash
./install.sh --no-wallpapers   # skip the 43 MB wallpaper collection
./install.sh --dry-run         # show what would be copied
```

The installer copies files into `$HOME`, backs up every replaced file to
`~/.local/state/dotfiles-backup/<timestamp>`, rewrites hard-coded home paths,
links `~/.config/gtk-4.0` to the Wallbash GTK theme, and enables userChrome for
existing Zen Browser profiles.

### Install time

Measured on this machine:

- Clone from GitHub: ~20-25 seconds
- Config install, no wallpapers: ~20 seconds
- Config install, with wallpapers: ~20-25 seconds
- Full one-liner: ~45 seconds
- `--packages`: ~5-15 minutes depending on network speed, mirror sync, and AUR
  builds

After installing, allow one logout/login and one Zen restart.

## What is included

- niri config and DMS-generated `dms/*.kdl` includes
- DankMaterialShell settings, custom Tokyo Night theme, plugin lockfile
- matugen user templates for Starship, Neovim (`firewatch`), Ghostty, Zen
- kitty, Ghostty, Neovim, Zed, GTK 3, Qt5ct/Qt6ct, fish, Bash
- Wallbash GTK, adw-gtk3 and WhiteSur-dark icon themes
- Wallpapers in `~/Pictures/Wallpapers`

## After installing

1. Log out and back in so niri and DMS reload.
2. Open the wallpaper picker with `Mod+Y` and pick a wallpaper.
3. Restart Zen Browser once so `userChrome.css` is loaded.
4. Reinstall DMS plugins from the Plugins page if needed.

Generated files (`dank-*.conf`, `dank-colors.css`, `niri/dms/*.kdl`,
`dms.lua`, `firewatch.lua`, `dank-userChrome.css`, `dank-zed-theme.json`) are
refreshed by DMS whenever the wallpaper changes. They are copies, not links, so
re-run `install.sh` after editing this repo.

## Requirements

- EndeavourOS/Arch with niri, quickshell, dms-shell, matugen
- kitty, ghostty, fish, starship, qt5ct, qt6ct
- Zen Browser via Flatpak (optional, for the Zen theme)
