# Nushell Environment Configuration
# This file is loaded first during Nushell startup
# Migrated from Zsh configuration

# -------------------------------------------------------------------
# Editor configuration
# -------------------------------------------------------------------
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

# -------------------------------------------------------------------
# Starship prompt configuration
# -------------------------------------------------------------------
$env.STARSHIP_CONFIG = ($"($env.HOME)/Workday/MacSetup/dotfiles/config/starship.toml")

# -------------------------------------------------------------------
# Locale configuration
# -------------------------------------------------------------------
$env.LANG = "en_US.UTF-8"
$env.LC_ALL = "en_US.UTF-8"

# -------------------------------------------------------------------
# Project roots (migrated from Zsh)
# -------------------------------------------------------------------
$env.OLIVIA_ROOT = $"($env.HOME)/Workday/Olivia/SourceCode"
$env.OLIVIA_CORE = $"($env.OLIVIA_ROOT)/olivia-core"
$env.OLIVIA_UI = $"($env.OLIVIA_ROOT)/olivia"
$env.OLIVIA_DOCKER = $"($env.OLIVIA_ROOT)/paradox-docker"
$env.OLIVIA_FF = $"($env.OLIVIA_ROOT)/paradox-feature-flag"

# -------------------------------------------------------------------
# SSH Key Switcher
# -------------------------------------------------------------------
export def ssh_toannguyen_prd [] {
    ^mkdir -p ~/.ssh  # Create the .ssh directory if it doesn't exist
    ^chmod 700 ~/.ssh # Set the proper permissions

    let ssh_config = (
        "Host github.com\n"
        + "  HostName github.com\n"
        + "  User git\n"
        + "  IdentityFile ~/.ssh/id_rsa\n"
    )
    echo $ssh_config > ~/.ssh/config
    ^chmod 600 ~/.ssh/config
    ^ssh-add -D
    ^ssh-add ~/.ssh/id_rsa

    # Update git config for work
    ^git config --global user.name "prd-toannguyen"
    ^git config --global user.email "toan.nguyen@paradox.ai"

    print "Switched to PRD SSH key and updated Git config"
}

export def ssh_toannxm [] {
    ^mkdir -p ~/.ssh  # Create the .ssh directory if it doesn't exist
    ^chmod 700 ~/.ssh # Set the proper permissions

    let ssh_config = (
        "Host github.com\n"
        + "  HostName github.com\n"
        + "  User git\n"
        + "  IdentityFile ~/.ssh/id_rsa_toannxm\n"
    )
    echo $ssh_config > ~/.ssh/config
    ^chmod 600 ~/.ssh/config
    ^ssh-add -D
    ^ssh-add ~/.ssh/id_rsa_toannxm

    # Update git config for personal
    ^git config --global user.name "toannxm"
    ^git config --global user.email "toannxm.itedu@gmail.com"

    print "Switched to Personal SSH key and updated Git config"
}

# -------------------------------------------------------------------
# MySQL configuration (migrated from Zsh)
# Load from .env file if available, otherwise use defaults
# -------------------------------------------------------------------
$env.MYSQL_USER = ($env.MYSQL_USER? | default "root")
$env.MYSQL_HOST = ($env.MYSQL_HOST? | default "127.0.0.1")
$env.MYSQL_PORT = ($env.MYSQL_PORT? | default "3306")
$env.MYSQL_PASSWORD = ($env.MYSQL_PASSWORD? | default "root")

# -------------------------------------------------------------------
# Build flags for macOS packages (migrated from Zsh)
# -------------------------------------------------------------------
let homebrew_prefix = (if (sys host | get name) == "Darwin" { "/opt/homebrew" } else { "/usr/local" })
let libxmlsec_version = "1.2.37"

$env.XMLSEC_CFLAGS = $"-I($homebrew_prefix)/Cellar/libxmlsec1/($libxmlsec_version)/include/xmlsec1"
$env.XMLSEC_LIBS = $"-L($homebrew_prefix)/Cellar/libxmlsec1/($libxmlsec_version)/lib"
$env.PKG_CONFIG_PATH = $"($homebrew_prefix)/Cellar/libxmlsec1/($libxmlsec_version)/lib/pkgconfig:($homebrew_prefix)/opt/mysql-client/lib/pkgconfig"
$env.LDFLAGS = $"-L($homebrew_prefix)/opt/openssl@3/lib"
$env.CPPFLAGS = $"-I($homebrew_prefix)/opt/openssl@3/include"

# -------------------------------------------------------------------
# PATH Configuration
# -------------------------------------------------------------------
# PNPM Home (define before using in PATH)
$env.PNPM_HOME = $"($env.HOME)/Library/pnpm"

# Additional tool directories
let carapace_bin = $"($env.HOME)/Library/Application Support/carapace/bin"
let jetbrains_scripts = $"($env.HOME)/Library/Application Support/JetBrains/Toolbox/scripts"
let pyenv_bin = $"($env.HOME)/.pyenv/bin"
let pmk_bin = "/opt/pmk/env/global/bin"
let local_bin = $"($env.HOME)/.local/bin"

# Build PATH in order of priority (highest first)
# Start with default system paths and add our custom paths
let default_paths = [
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
]

$env.PATH = (
    [
        $env.PNPM_HOME                            # pnpm
        $"($homebrew_prefix)/bin"                 # Homebrew
        $"($homebrew_prefix)/sbin"                # Homebrew sbin
        $"($homebrew_prefix)/opt/mysql@8.4/bin"  # MySQL 8.4
    ]
    | append (if ($local_bin | path exists) { [$local_bin] } else { [] })  # Local bin (if exists)
    | append (if ($pyenv_bin | path exists) { [$pyenv_bin] } else { [] })  # pyenv bin (if exists)
    | append (if ($carapace_bin | path exists) { [$carapace_bin] } else { [] })  # Carapace (if exists)
    | append (if ($jetbrains_scripts | path exists) { [$jetbrains_scripts] } else { [] })  # JetBrains Toolbox (if exists)
    | append (if ($pmk_bin | path exists) { [$pmk_bin] } else { [] })  # PMK (if exists)
    | append $default_paths
    | append ($env.PATH | split row (char esep))
    | uniq
)

# -------------------------------------------------------------------
# Bun JavaScript runtime - if installed
# -------------------------------------------------------------------
let bun_install = $"($env.HOME)/.bun"
if ($bun_install | path exists) {
    $env.BUN_INSTALL = $bun_install
    $env.PATH = ($env.PATH | split row (char esep) | prepend $"($bun_install)/bin")
}

# -------------------------------------------------------------------
# fnm (Fast Node Manager) - if installed
# -------------------------------------------------------------------
if (which fnm | is-not-empty) {
    ^fnm env --json | from json | load-env
    $env.PATH = ($env.PATH | split row (char esep) | prepend $"($env.FNM_MULTISHELL_PATH)/bin")
}

# -------------------------------------------------------------------
# Node.js CA Certificates
# -------------------------------------------------------------------
$env.NODE_EXTRA_CA_CERTS = $"($env.HOME)/zscaler-root-ca.crt"

# -------------------------------------------------------------------
# AWS Configuration
# -------------------------------------------------------------------
$env.AWS_PROFILE = ($env.AWS_PROFILE? | default "default")

# -------------------------------------------------------------------
# pyenv - managed in env.d/pyenv.nu (loaded at end of file)
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Environment variable conversions
# -------------------------------------------------------------------
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) }
        to_string: { |v| $v | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) }
        to_string: { |v| $v | str join (char esep) }
    }
}

# -------------------------------------------------------------------
# Load style modules
# -------------------------------------------------------------------
const DOTFILES_STYLE = ("~/Workday/MacSetup/dotfiles/config/nushell/style" | path expand)
use ($DOTFILES_STYLE | path join "carapace.nu") *
use ($DOTFILES_STYLE | path join "ls_colors.nu") *

# -------------------------------------------------------------------
# LS_COLORS Configuration
# -------------------------------------------------------------------
$env.LS_COLORS = (get_ls_colors)

# -------------------------------------------------------------------
# Carapace Configuration (Environment Variables)
# -------------------------------------------------------------------
# -------------------------------------------------------------------
# Set carapace environment variables for enhanced completions
# These must be in env.nu to persist across the session
$env.CARAPACE_MATCH = "1"              # Enable fuzzy matching
$env.CARAPACE_LENIENT = "1"            # Be lenient with parsing
# $env.CARAPACE_HIDDEN = "1"           # Uncomment to show hidden flags

# Carapace styling - customize completion colors (loaded from style/carapace.nu)
$env.CARAPACE_STYLE = (get_carapace_style)

# -------------------------------------------------------------------
# Load .env file for sensitive configuration
# -------------------------------------------------------------------
const NUSHELL_DIR = ("~/Workday/MacSetup/dotfiles/config/nushell" | path expand)
const ENV_FILE = ($NUSHELL_DIR | path join ".env")

if ($ENV_FILE | path exists) {
    # Load .env file and export variables
    let env_vars = (
        open $ENV_FILE
        | lines
        | where {|line|
            let trimmed = ($line | str trim)
            (not ($trimmed | str starts-with "#")) and (not ($trimmed | is-empty))
        }
        | each {|line|
            # Parse "export VAR=value" or "VAR=value"
            let cleaned = ($line | str replace -r '^export\s+' '')
            let parts = ($cleaned | split row '=')
            if ($parts | length) >= 2 {
                let var_name = ($parts | first | str trim)
                let var_value = ($parts | skip 1 | str join '=' | str trim -c '"' | str trim -c "'")
                {key: $var_name, value: $var_value}
            }
        }
        | compact
        | reduce -f {} {|it, acc| $acc | insert $it.key $it.value }
    )
    load-env $env_vars
}

# -------------------------------------------------------------------
# Load environment modules
# -------------------------------------------------------------------
const DOTFILES_ENV = ("~/Workday/MacSetup/dotfiles/config/nushell/env.d" | path expand)

# Starship prompt
source ($DOTFILES_ENV | path join "starship.nu")

# pyenv initialization
source ($DOTFILES_ENV | path join "pyenv.nu")

