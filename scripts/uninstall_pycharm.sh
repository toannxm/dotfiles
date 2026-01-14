#!/usr/bin/env bash

# Script to completely remove PyCharm from macOS
# This removes the application, preferences, caches, and all related files

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}PyCharm Uninstaller for macOS${NC}"
echo "=================================="
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}Error: This script is designed for macOS only${NC}"
    exit 1
fi

# Function to remove file/directory if it exists
remove_if_exists() {
    local path="$1"
    if [ -e "$path" ]; then
        echo -e "${GREEN}Removing:${NC} $path"
        rm -rf "$path"
    else
        echo -e "${YELLOW}Not found:${NC} $path"
    fi
}

# Confirm before proceeding
echo -e "${YELLOW}This will completely remove PyCharm and all its data.${NC}"
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""
echo "Starting PyCharm removal..."
echo ""

# Kill any running PyCharm processes (including indexing)
echo "Stopping any running PyCharm processes..."
pkill -9 -f "PyCharm" 2>/dev/null && echo -e "${GREEN}Stopped PyCharm processes${NC}" || echo -e "${YELLOW}No running PyCharm processes found${NC}"
sleep 2

# Remove PyCharm applications (Professional, Community, and Educational editions)
# Check both system and user Applications folders
remove_if_exists "/Applications/PyCharm.app"
remove_if_exists "/Applications/PyCharm CE.app"
remove_if_exists "/Applications/PyCharm Edu.app"
remove_if_exists "$HOME/Applications/PyCharm.app"
remove_if_exists "$HOME/Applications/PyCharm CE.app"
remove_if_exists "$HOME/Applications/PyCharm Edu.app"

# Remove user preferences and settings
# Format: ~/Library/Application Support/JetBrains/PyCharm[Edition]YYYY.Y
echo ""
echo "Removing preferences and settings..."
remove_if_exists "$HOME/Library/Application Support/JetBrains/PyCharm"*
remove_if_exists "$HOME/Library/Preferences/com.jetbrains.pycharm"*
remove_if_exists "$HOME/Library/Preferences/PyCharm"*

# Remove caches
echo ""
echo "Removing caches (including index caches)..."
remove_if_exists "$HOME/Library/Caches/JetBrains/PyCharm"*
remove_if_exists "$HOME/Library/Caches/com.jetbrains.pycharm"*

# Remove index files specifically
echo ""
echo "Removing index files..."
remove_if_exists "$HOME/Library/Caches/JetBrains/PyCharm"*/caches
remove_if_exists "$HOME/Library/Caches/JetBrains/PyCharm"*/index

# Remove logs
echo ""
echo "Removing logs..."
remove_if_exists "$HOME/Library/Logs/JetBrains/PyCharm"*

# Remove saved application state
echo ""
echo "Removing saved application state..."
remove_if_exists "$HOME/Library/Saved Application State/com.jetbrains.pycharm"*

# Remove local data
echo ""
echo "Removing local data..."
remove_if_exists "$HOME/Library/Local/JetBrains/PyCharm"*

# Remove plugins (optional - only PyCharm-specific ones)
echo ""
echo "Checking for PyCharm-specific plugins..."
if [ -d "$HOME/Library/Application Support/JetBrains" ]; then
    # Check if there are any other JetBrains IDEs before removing shared plugins
    if [ -z "$(ls -A "$HOME/Library/Application Support/JetBrains" 2>/dev/null)" ]; then
        remove_if_exists "$HOME/Library/Application Support/JetBrains"
    else
        echo -e "${YELLOW}Note: Other JetBrains IDEs detected. Shared plugins not removed.${NC}"
    fi
fi

# Remove any PyCharm-related files in Application Scripts
echo ""
echo "Checking Application Scripts..."
remove_if_exists "$HOME/Library/Application Scripts/com.jetbrains.pycharm"*

# Remove any PyCharm-related containers
echo ""
echo "Checking Containers..."
remove_if_exists "$HOME/Library/Containers/com.jetbrains.pycharm"*

# Remove any PyCharm-related WebKit data
echo ""
echo "Checking WebKit data..."
remove_if_exists "$HOME/Library/WebKit/com.jetbrains.pycharm"*

# Remove system-wide files (requires sudo)
echo ""
echo -e "${YELLOW}Checking for system-wide files (may require sudo)...${NC}"
if [ -d "/Library/Application Support/JetBrains/PyCharm"* ] 2>/dev/null; then
    sudo rm -rf /Library/Application\ Support/JetBrains/PyCharm*
    echo -e "${GREEN}Removed system-wide PyCharm files${NC}"
fi

# Clean up empty JetBrains directories
echo ""
echo "Cleaning up empty directories..."
[ -d "$HOME/Library/Application Support/JetBrains" ] && rmdir "$HOME/Library/Application Support/JetBrains" 2>/dev/null && echo -e "${GREEN}Removed empty JetBrains directory${NC}" || true
[ -d "$HOME/Library/Caches/JetBrains" ] && rmdir "$HOME/Library/Caches/JetBrains" 2>/dev/null && echo -e "${GREEN}Removed empty JetBrains cache directory${NC}" || true
[ -d "$HOME/Library/Logs/JetBrains" ] && rmdir "$HOME/Library/Logs/JetBrains" 2>/dev/null && echo -e "${GREEN}Removed empty JetBrains logs directory${NC}" || true

echo ""
echo -e "${GREEN}PyCharm has been completely removed from your system.${NC}"
echo ""
echo "Note: If you have PyCharm installed via Homebrew or JetBrains Toolbox,"
echo "you may also want to run:"
echo "  brew uninstall pycharm"
echo "  brew uninstall pycharm-ce"
echo ""
