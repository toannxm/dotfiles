# Nushell Configuration File
# Migrated from Zsh modular configuration
# version = "0.98.0"

# For more information on defining custom themes, see
# https://www.nushell.sh/book/coloring_and_theming.html
# And here is the theme collection
# https://github.com/nushell/nu_scripts/tree/main/themes

# -------------------------------------------------------------------
# Color themes
# -------------------------------------------------------------------
let dark_theme = {
    # color for nushell primitives
    separator: white
    leading_trailing_space_bg: { attr: n } # no fg, no bg, attr none effectively turns this off
    header: green_bold
    empty: blue
    # Closures can be used to choose colors for specific values.
    # The value (in this case, a bool) is piped into the closure.
    # eg) {|| if $in { 'light_cyan' } else { 'light_gray' } }
    bool: light_cyan
    int: white
    filesize: cyan
    duration: white
    date: purple
    range: white
    float: white
    string: white
    nothing: white
    binary: white
    cell-path: white
    row_index: green_bold
    record: white
    list: white
    block: white
    hints: dark_gray
    search_result: { bg: red fg: white }

    # Syntax highlighting (for command line input)
    shape_garbage: { fg: white bg: red attr: b }
    shape_binary: purple_bold
    shape_bool: light_cyan
    shape_int: purple_bold
    shape_float: purple_bold
    shape_range: yellow_bold
    shape_internalcall: cyan_bold
    shape_external: cyan
    shape_externalarg: green
    shape_literal: blue
    shape_operator: yellow
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: cyan_bold
    shape_list: cyan_bold
    shape_table: blue_bold
    shape_record: cyan_bold
    shape_block: blue_bold
    shape_filepath: cyan
    shape_directory: cyan
    shape_globpattern: cyan_bold
    shape_variable: purple
    shape_flag: blue_bold
    shape_custom: green
    shape_nothing: light_cyan
    shape_matching_brackets: { attr: u }
}

let light_theme = {
    # color for nushell primitives
    separator: dark_gray
    leading_trailing_space_bg: { attr: n } # no fg, no bg, attr none effectively turns this off
    header: green_bold
    empty: blue
    # Closures can be used to choose colors for specific values.
    # The value (in this case, a bool) is piped into the closure.
    # eg) {|| if $in { 'dark_cyan' } else { 'dark_gray' } }
    bool: dark_cyan
    int: dark_gray
    filesize: cyan_bold
    duration: dark_gray
    date: purple
    range: dark_gray
    float: dark_gray
    string: dark_gray
    nothing: dark_gray
    binary: dark_gray
    cell-path: dark_gray
    row_index: green_bold
    record: dark_gray
    list: dark_gray
    block: dark_gray
    hints: dark_gray
    search_result: { fg: white bg: red }

    # Syntax highlighting (for command line input)
    shape_garbage: { fg: white bg: red attr: b }
    shape_binary: purple_bold
    shape_bool: light_cyan
    shape_int: purple_bold
    shape_float: purple_bold
    shape_range: yellow_bold
    shape_internalcall: cyan_bold
    shape_external: cyan
    shape_externalarg: green
    shape_literal: blue
    shape_operator: yellow
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: cyan_bold
    shape_list: cyan_bold
    shape_table: blue_bold
    shape_record: cyan_bold
    shape_block: blue_bold
    shape_filepath: cyan
    shape_directory: cyan
    shape_globpattern: cyan_bold
    shape_variable: purple
    shape_flag: blue_bold
    shape_custom: green
    shape_nothing: light_cyan
    shape_matching_brackets: { attr: u }
}

# -------------------------------------------------------------------
# Main Nushell configuration
# -------------------------------------------------------------------
$env.config = {
    show_banner: false  # Hide welcome banner

    # Table configuration
    table: {
        mode: rounded  # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
        index_mode: auto  # always, never, auto
        show_empty: true
        padding: { left: 1, right: 1 }
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
            truncating_suffix: "..."
        }
    }

    # History configuration
    history: {
        max_size: 100_000
        sync_on_enter: true
        file_format: "sqlite"  # "sqlite" or "plaintext"
        isolation: false
    }

    # Completion configuration
    # Note: Carapace completer is configured in env.nu
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "prefix"  # prefix, fuzzy
        external: {
            enable: true
            max_results: 100
            completer: null  # Will be set by carapace init in env.nu
        }
    }

    # Cursor shape configuration
    cursor_shape: {
        emacs: line      # block, underscore, line, blink_block, blink_underscore, blink_line
        vi_insert: block
        vi_normal: underscore
    }

    # Color configuration
    color_config: $dark_theme  # or $light_theme

    # Float precision
    float_precision: 2

    # Buffer editor (for editing commands with Ctrl+O)
    buffer_editor: "code"

    # Shell integration
    shell_integration: {
        osc2: true
        osc7: true
        osc8: true
        osc9_9: false
        osc133: true
        osc633: true
        reset_application_mode: true
    }

    # Render right prompt on the last line
    render_right_prompt_on_last_line: false

    # Use ANSI coloring
    use_ansi_coloring: true

    # Bracketed paste
    bracketed_paste: true

    # Edit mode (emacs or vi)
    edit_mode: emacs
}

# -------------------------------------------------------------------
# Load modular aliases
# -------------------------------------------------------------------
# Load from dotfiles directory
const DOTFILES_ALIASES = ("~/Workday/MacSetup/dotfiles/config/nushell/aliases" | path expand)

# Load all alias files from dotfiles
use ($DOTFILES_ALIASES | path join "core.nu") *
use ($DOTFILES_ALIASES | path join "git.nu") *
use ($DOTFILES_ALIASES | path join "database.nu") *
use ($DOTFILES_ALIASES | path join "docker.nu") *
use ($DOTFILES_ALIASES | path join "sdm.nu") *
use ($DOTFILES_ALIASES | path join "olivia.nu") *
use ($DOTFILES_ALIASES | path join "k8s.nu") *
use ($DOTFILES_ALIASES | path join "pyenv_wrapper.nu") *
use ($DOTFILES_ALIASES | path join "jetbrains.nu") *

# -------------------------------------------------------------------
# Theme switching functions
# -------------------------------------------------------------------
export def --env "theme dark" [] {
    $env.config.color_config = $dark_theme
    print "🌙 Switched to dark theme"
}

export def --env "theme light" [] {
    $env.config.color_config = $light_theme
    print "☀️  Switched to light theme"
}

export def "theme current" [] {
    if ($env.config.color_config == $dark_theme) {
        print "Current theme: 🌙 dark"
    } else {
        print "Current theme: ☀️  light"
    }
}

# -------------------------------------------------------------------
# Hooks - Auto-activate virtual environment
# -------------------------------------------------------------------
# NOTE: This must be set AFTER loading modules so functions are available
$env.config.hooks = {
    env_change: {
        PWD: [
            {|before, after|
                if ($after | str contains 'olivia-core') {
                    activate-core
                } else if ($after | str contains 'olivia') {
                    activate-ui
                }
            }
        ]
    }
}

# -------------------------------------------------------------------
# Load configuration modules
# -------------------------------------------------------------------
const DOTFILES_ENV = ("~/Workday/MacSetup/dotfiles/config/nushell/env.d" | path expand)

# Carapace completion (must be after $env.config is set)
source ($DOTFILES_ENV | path join "carapace.nu")

# -------------------------------------------------------------------
# Welcome message
# -------------------------------------------------------------------
# print ""
# print "🚀 Nushell environment loaded!"
# print ""
