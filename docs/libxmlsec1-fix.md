# libxmlsec1 Fix Documentation

## Problem

The default Homebrew formula for `libxmlsec1` (version 1.3.9+) causes installation failures with the error:

```
Error: Homebrew requires casks to be in a tap, rejecting:
  /opt/homebrew/opt/libxmlsec1/.brew/libxmlsec1.rb
```

Additionally, the newer versions depend on `openssl@1.1` which has been deprecated and removed from Homebrew in favor of `openssl@3`.

## Solution

We maintain a custom formula for `libxmlsec1` version **1.2.37** with the following modifications:

1. **Version**: Uses the stable 1.2.37 release instead of 1.3.9+
2. **OpenSSL**: Updated to depend on `openssl@3` instead of `openssl@1.1`
3. **URL**: Points to the older release archive

## Why Version 1.2.37?

- Compatible with `openssl@3` (with our patch)
- Stable and tested with Python SAML libraries (`python3-saml`, `xmlsec`)
- Avoids the tap rejection error present in newer versions
- Required for SSO/SAML functionality in the Olivia project

## Files Involved

```
dotfiles/
├── homebrew/
│   └── Formula/
│       └── libxmlsec1.rb         # Custom formula (1.2.37 + openssl@3)
├── scripts/
│   └── setup-libxmlsec1.sh       # Installation script
└── Brewfile                       # Standard libxmlsec1 commented out
```

## Installation

The custom version is automatically installed when you run:

```bash
./install.sh --brew
# or
./scripts/brew.sh
```

## Manual Installation

If you need to install manually:

```bash
cd ~/dotfiles  # or wherever your dotfiles are
./scripts/setup-libxmlsec1.sh
```

## Verification

Check the installed version:

```bash
brew info libxmlsec1
# Should show: Installed /opt/homebrew/Cellar/libxmlsec1/1.2.37
```

Verify dependencies:

```bash
brew deps libxmlsec1
# Should include: openssl@3 (not openssl@1.1)
```

## Troubleshooting

### Error: "Homebrew requires formulae to be in a tap"

This means you're trying to install from a file outside a tap. The setup script handles this by:
1. Creating a local tap at `$(brew --repository)/Library/Taps/local/homebrew-tap`
2. Copying the formula there
3. Installing via `brew install local/tap/libxmlsec1`

### Error: "A full installation of Xcode.app is required"

If building from source, you may need full Xcode. The setup script uses pre-built bottles when available to avoid this.

### Wrong Version Installed

Uninstall and reinstall:

```bash
brew uninstall libxmlsec1 --force
./scripts/setup-libxmlsec1.sh
```

## Python Package Integration

After installing libxmlsec1, you may need to reinstall Python packages that depend on it:

```bash
# For poetry projects
poetry install

# For pip
pip install python3-saml --force-reinstall

# Verify
python -c "import xmlsec; print(xmlsec.__version__)"
```

## Formula Details

The custom formula is based on Homebrew core commit `7f35e6ede954326a10949891af2dba47bbe1fc17` with modifications:

- **Original URL**: `https://www.aleksey.com/xmlsec/download/xmlsec1-1.3.x.tar.gz`
- **Modified URL**: `https://www.aleksey.com/xmlsec/download/older-releases/xmlsec1-1.2.37.tar.gz`
- **Original Dependency**: `depends_on "openssl@1.1"`
- **Modified Dependency**: `depends_on "openssl@3"`

## References

- Original Homebrew formula: https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/lib/libxmlsec1.rb
- XMLSec project: https://www.aleksey.com/xmlsec/
- OpenSSL 3 migration: https://github.com/Homebrew/homebrew-core/pull/93741

## Maintenance

If this fix becomes obsolete (e.g., Homebrew updates the formula to support openssl@3), you can:

1. Remove the custom formula: `rm homebrew/Formula/libxmlsec1.rb`
2. Uncomment in Brewfile: Change `# brew "libxmlsec1"` to `brew "libxmlsec1"`
3. Remove setup script: `rm scripts/setup-libxmlsec1.sh`
4. Update brew.sh: Remove the `setup_libxmlsec1` call
5. Reinstall: `brew uninstall libxmlsec1 --force && brew install libxmlsec1`

---

Last updated: January 13, 2026
