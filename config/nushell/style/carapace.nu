# -------------------------------------------------------------------
# Carapace Styling Configuration
# -------------------------------------------------------------------
# Customize completion colors and styles
# Available styles: https://github.com/rsteube/carapace/wiki/Style
# Format: "element=style" where style can be: bold, dim, italic, underline, color names

export def get_carapace_style [] {
    [
        "carapace.Highlight=bold,magenta"      # Highlighted completions
        "carapace.Value=cyan"                   # Completion values
        "carapace.Description=dim"              # Completion descriptions
        "carapace.Error=red"                    # Error messages
        "carapace.Usage=yellow"                 # Usage hints
        "carapace.Flag=blue"                    # Flags (--flag)
        "carapace.FlagArg=green"                # Flag arguments
        "carapace.FlagOptArg=light_green"       # Optional flag arguments
        "carapace.FlagNoArg=light_blue"         # Flags without arguments
        "carapace.Positional=cyan"              # Positional arguments
        "carapace.PositionalOptArg=light_cyan"  # Optional positional arguments
    ] | str join ","
}
