# dotfiles-personal

Personal machine profile for the dotfiles framework. Contains personal
packages, config overrides, and identity settings.

See [dotfiles-common](../dotfiles-common/README.md) for the full framework
reference — architecture, app definition format, PM authoring, etc.

---

## Quick start

```bash
git clone <this-repo-url> ~/.dotfiles/profile
~/.dotfiles/profile/install.sh
```

The common framework repo is cloned automatically on first run. By default it
is placed at `~/.dotfiles/common`; override with `DOTFILES_COMMON_DIR` and
`DOTFILES_COMMON_REPO` env vars if needed.

### Flags

```
./install.sh              # packages + link + macOS defaults
./install.sh --packages   # install packages only
./install.sh --link       # stow configs and regenerate .gitconfig only
./install.sh --defaults   # apply macOS defaults only
```

---

## What's in this repo

### Git identity

`stow/git/.gitconfig.d/30-personal.gitconfig` — fill in your name and email:

```ini
[user]
    name  = Your Name
    email = you@example.com
```

### Shell config

`stow/shell/.zsh/rc.d/30-personal.zsh` — personal aliases, functions, and
environment variables. Sourced after the common config (`10-env.zsh`).

### macOS defaults

`stow/macos/.macos/defaults.d/30-personal.sh` — personal `defaults write`
overrides. Runs after the common defaults scripts.

---

## Extending this profile

**Add a package** — create `apps/<canonical-name>` with PM mappings:

```
# apps/my-tool — installed everywhere with the same name
*=my-tool

# apps/iterm2 — macOS-only, no wildcard so apt/other PMs skip it
brew-casks=iterm2

# apps/bat — different name on apt
*=bat
apt=batcat
```

**Add shell config** — add a numbered file to `stow/shell/.zsh/rc.d/`:

```
30-personal.zsh      # already exists — add to it
35-extra.zsh         # or add a new fragment
```

**Add a macOS default** — add a script to `stow/macos/.macos/defaults.d/`:

```bash
# 30-personal.sh (already exists)
defaults write com.apple.screensaver askForPassword -int 1
```

**Add a hook** — create `hooks/pre-install.sh` or `hooks/post-install.sh`.
Hooks run before / after the main install phases.
