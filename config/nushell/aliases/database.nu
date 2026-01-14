# MySQL aliases and utilities
# MySQL 8.4 from Homebrew

# -------------------------------------------------------------------
# Help function
# -------------------------------------------------------------------
export def "help database" [] {
    print "📚 Database (MySQL) Aliases & Utilities\n"
    print "MySQL Commands:"
    print "  mysql          - MySQL client (v8.4)"
    print "  mysqldump      - MySQL dump utility\n"
    print "Cache:"
    print "  del_cache      - Flush memcached (localhost:11211)\n"
    print "Functions:"
    print "  clone_db_test <source> <target> - Clone database for testing"
    print "    Example: clone_db_test prod_db test_db"
    print "  export_db <database> [output_file] - Export database to SQL file"
    print "    Example: export_db mydb ~/backups/mydb.sql"
}

# MySQL explicit paths (from Homebrew 8.4)
export alias mysql = /opt/homebrew/opt/mysql@8.4/bin/mysql
export alias mysqldump = /opt/homebrew/opt/mysql@8.4/bin/mysqldump

# Cache management (memcached)
export alias del_cache = echo 'flush_all' | nc localhost 11211

# Clone database for testing (MySQL schema duplication)
export def clone_db_test [source_db: string, target_db: string] {
    print $"Cloning database: ($source_db) → ($target_db)"
    
    let temp_file = "/tmp/db_clone.sql"
    
    # Create a temporary MySQL config file for secure password handling
    let mysql_config = "/tmp/.my.cnf.tmp"
    $"[client]\nuser=($env.MYSQL_USER)\npassword=($env.MYSQL_PASSWORD)\nhost=($env.MYSQL_HOST)\n" | save -f $mysql_config
    
    # Dump source database
    print "📦 Dumping source database..."
    mysqldump $"--defaults-extra-file=($mysql_config)" $source_db | save -f $temp_file
    
    # Drop target if exists
    print "🗑️  Dropping target database if exists..."
    mysql $"--defaults-extra-file=($mysql_config)" -e $"DROP DATABASE IF EXISTS ($target_db);"
    
    # Create target database
    print "✨ Creating target database..."
    mysql $"--defaults-extra-file=($mysql_config)" -e $"CREATE DATABASE ($target_db);"
    
    # Import dump
    print "📥 Importing data..."
    open $temp_file | mysql $"--defaults-extra-file=($mysql_config)" $target_db
    
    # Cleanup temp files
    rm $temp_file
    rm $mysql_config
    print $"✓ Database cloned successfully: ($target_db)"
}

# Export database to SQL file
export def export_db [
    database: string          # Database name to export
    output_file?: string      # Output file path (optional, defaults to <database>_<timestamp>.sql)
] {
    # Generate default filename with timestamp if not provided
    let filename = if ($output_file | is-empty) {
        let timestamp = (date now | format date "%Y%m%d_%H%M%S")
        $"($database)_($timestamp).sql"
    } else {
        $output_file
    }
    
    # Expand path to handle ~ and relative paths
    let export_path = ($filename | path expand)
    
    print $"📦 Exporting database: ($database)"
    print $"📁 Output file: ($export_path)"
    
    # Check if MySQL credentials are available
    if ("MYSQL_USER" not-in $env or "MYSQL_PASSWORD" not-in $env or "MYSQL_HOST" not-in $env) {
        print "⚠️  Warning: MYSQL_USER, MYSQL_PASSWORD, or MYSQL_HOST not set in environment"
        print "Attempting to use default credentials..."
        
        # Export without credentials (will use .my.cnf or prompt)
        mysqldump $database | save -f $export_path
    } else {
        # Create a temporary MySQL config file for secure password handling
        let mysql_config = "/tmp/.my.cnf.export.tmp"
        $"[client]\nuser=($env.MYSQL_USER)\npassword=($env.MYSQL_PASSWORD)\nhost=($env.MYSQL_HOST)\n" | save -f $mysql_config
        
        # Export database
        mysqldump $"--defaults-extra-file=($mysql_config)" $database | save -f $export_path
        
        # Cleanup temp config
        rm $mysql_config
    }
    
    # Show file size
    let file_size = (ls $export_path | get size | first)
    print $"✓ Database exported successfully!"
    print $"  Size: ($file_size)"
    print $"  Location: ($export_path)"
}
