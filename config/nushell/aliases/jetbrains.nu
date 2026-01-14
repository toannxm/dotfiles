# JetBrains product utilities
# Reset trial periods and manage JetBrains IDEs

# -------------------------------------------------------------------
# Help function
# -------------------------------------------------------------------
export def "help jetbrains" [] {
    print "📚 JetBrains Utilities\n"
    print "Trial Management:"
    print "  reset-jetbrains-trial --name <product>  - Reset trial for JetBrains product"
    print "                                            (e.g., DataGrip, IntelliJ, PyCharm, etc.)"
}

# -------------------------------------------------------------------
# Reset JetBrains trial period
# -------------------------------------------------------------------
# Reset trial period for a JetBrains product
# Usage: reset-jetbrains-trial --name DataGrip
export def reset-jetbrains-trial [
    --name (-n): string  # Product name (e.g., DataGrip, IntelliJ, PyCharm)
] {
    if ($name | is-empty) {
        error make { msg: "Product name is required. Use --name <product>" }
    }
    
    let product = $name
    
    print $"🔄 Resetting trial for ($product)..."
    
    # Force close if running
    print $"  Killing ($product) process..."
    try {
        pkill -f $product
    } catch {
        print $"  No running ($product) process found"
    }
    
    # Remove eval folders from Preferences
    print "  Removing eval data from Preferences..."
    let prefs_eval = $"($env.HOME)/Library/Preferences/($product)*/eval"
    try {
        rm -rf $prefs_eval
    } catch {
        # Silently continue if path doesn't exist
    }
    
    # Remove eval folders from Application Support
    print "  Removing eval data from Application Support..."
    let app_support_eval = $"($env.HOME)/Library/Application Support/JetBrains/($product)*/eval"
    try {
        rm -rf $app_support_eval
    } catch {
        # Silently continue if path doesn't exist
    }
    
    # Remove evlsprt from Preferences other.xml
    print "  Cleaning Preferences other.xml..."
    let prefs_other = $"($env.HOME)/Library/Preferences/($product)*/options/other.xml"
    try {
        ls $prefs_other | each { |file|
            sed -i '' '/evlsprt/d' $file.name
        }
    } catch {
        # Silently continue if files don't exist
    }
    
    # Remove evlsprt from Application Support other.xml
    print "  Cleaning Application Support other.xml..."
    let app_support_other = $"($env.HOME)/Library/Application Support/JetBrains/($product)*/options/other.xml"
    try {
        ls $app_support_other | each { |file|
            sed -i '' '/evlsprt/d' $file.name
        }
    } catch {
        # Silently continue if files don't exist
    }
    
    # Remove preference plists
    print "  Removing preference plists..."
    try {
        rm -f $"($env.HOME)/Library/Preferences/com.apple.java.util.prefs.plist"
    }
    try {
        rm -f $"($env.HOME)/Library/Preferences/com.jetbrains.*.plist"
    }
    try {
        rm -f $"($env.HOME)/Library/Preferences/jetbrains.*.*.plist"
    }
    
    # Kill cfprefsd to refresh preferences
    print "  Refreshing preferences daemon..."
    try {
        killall cfprefsd
    } catch {
        print "  Warning: Could not refresh cfprefsd"
    }
    
    print $"✅ Done! Trial reset for ($product) complete."
    print $"   You can now launch ($product) to start a new trial period."
}
