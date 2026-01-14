# Common color and fzf theme constants for Nushell

export const COLORS = {
    green: "\u{1b}[38;2;166;227;161m",      # #a6e3a1 - Running/Active/Healthy
    yellow: "\u{1b}[38;2;249;226;175m",     # #f9e2af - Pending/Warning
    red: "\u{1b}[38;2;243;139;168m",        # #f38ba8 - Failed/Error
    blue: "\u{1b}[38;2;137;180;250m",       # #89b4fa - Info/Current
    gray: "\u{1b}[38;2;88;91;112m",         # #585b70 - Unknown/Terminating
    reset: "\u{1b}[0m"
}

# fzf theme constants
export const FZF_COLORS = "fg:#cdd6f4,bg:#1e1e2e,hl:#a6e3a1,fg+:#cdd6f4,bg+:#45475a,hl+:#a6e3a1,info:#94e2d5,prompt:#89b4fa,pointer:#89b4fa,marker:#f9e2af,spinner:#f5c2e7,header:#89b4fa"
export const FZF_POINTER = "👉🏼"
export const FZF_MARKER = "✓"