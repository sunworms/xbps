# void-pkgs — Custom Void Linux Repository

Binary XBPS packages for Void Linux, built and **updated automatically** via GitHub Actions.
No manual rebuilding needed — packages update themselves.

## Packages

| Package | Upstream | Update trigger | Arch |
|---|---|---|---|
| `helix-git` | [helix-editor/helix](https://github.com/helix-editor/helix) | Every new commit to `master` (checked hourly) | x86_64 |
| `helium-browser-bin` | [imputnet/helium-linux](https://github.com/imputnet/helium-linux) | Every new stable release (checked twice daily) | x86_64 |
| `font-aporetic` | [protesilaos/aporetic](https://github.com/protesilaos/aporetic) | Every new commit to `main` (checked daily) | noarch |

When a new version is detected, GitHub Actions automatically:
1. Updates the template (`version=`, `_commit=`, `checksum=`) and commits it back to this repo
2. Builds the `.xbps` package in a Void Linux container
3. Signs the repo index with the RSA key stored as a GitHub secret
4. Deploys everything to GitHub Pages

## Installation

**1. Add the repository:**
```sh
echo "repository=https://sunworms.github.io/xbps" \
  | sudo tee /etc/xbps.d/20-custom.conf
```

**2. Sync and import the signing key:**
```sh
sudo xbps-install -S
```
XBPS will ask to import the RSA key. Verify the fingerprint:
```
Signed by: Sunny <sunnybhowmick0310@gmail.com>
Fingerprint: 6d:d4:53:6c:e1:d8:1a:2c:06:6e:91:f1:98:d1:23:bc
```

**3. Install:**
```sh
sudo xbps-install helix-git
sudo xbps-install helium-browser-bin
sudo xbps-install font-aporetic
```

## One-time setup (for maintainers)

### 1. Generate the signing keypair

```sh
bash scripts/generate-repokey.sh
```

Add the three printed values as repository secrets (**Settings → Secrets → Actions**):

| Secret | Value |
|---|---|
| `REPOKEY_PRIVATE` | Base64-encoded private key |
| `REPOKEY_PUBLIC` | Plain-text public key |
| `REPOKEY_SIGNEDBY` | Display name, e.g. `Your Name <you@example.com>` |

### 2. Allow Actions to push commits

Go to **Settings → Actions → General → Workflow permissions** and enable
**"Read and write permissions"** so the bot can commit updated templates.

### 3. Enable GitHub Pages

**Settings → Pages → Source: GitHub Actions**

### 4. Update the placeholders

Edit `public/index.html` and this `README.md`:
- Replace `YOUR_GITHUB_USERNAME` / `YOUR_REPO_NAME`
- Fill in your fingerprint and signed-by string (printed by `generate-repokey.sh`)

That's it — push to `main` and the first build will run automatically.

## How auto-updates work

```
update-helix-git.yml      runs hourly
  └─ checks helix master HEAD via GitHub API
  └─ if new commit → updates template, commits, triggers build.yml

update-helium.yml         runs twice daily
  └─ checks helium-linux latest release via GitHub API
  └─ if new version → updates template, commits, triggers build.yml

update-font-aporetic.yml  runs daily
  └─ checks aporetic main HEAD via GitHub API
  └─ if new commit → updates template, commits, triggers build.yml

build.yml (reusable)
  └─ boots Void Linux container
  └─ clones void-packages + injects custom templates
  └─ ./xbps-src pkg <package>
  └─ xbps-rindex --sign
  └─ deploys to GitHub Pages
```

## Directory layout

```
.github/workflows/
  build.yml                 Reusable build + deploy workflow
  update-helix-git.yml      Hourly updater for helix-git
  update-helium.yml         Twice-daily updater for helium-browser-bin
  update-font-aporetic.yml  Daily updater for font-aporetic
pkgs/
  helix-git/template
  helium-browser-bin/template
  font-aporetic/template
scripts/
  generate-repokey.sh       One-time local key generation
  gen-pkglist.sh            Used by CI to generate packages.json for the site
public/
  index.html                GitHub Pages landing page
```
