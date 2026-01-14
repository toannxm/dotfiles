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
    print "  import_db <database> <sql_file> [--create] [--drop] - Import SQL file to database"
    print "    --create: Create database if it doesn't exist"
    print "    --drop: Drop database if it exists before importing"
    print "    Example: import_db mydb ~/backups/mydb.sql --drop --create"
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

# Clone production schema to a test DB (schema only, no data)
export def clone_db_test [
    source_db: string = "applydb_prod"     # Source database (default: applydb_prod)
    target_db: string = "test_applydb_prod" # Target database (default: test_applydb_prod)
] {
    let user = ($env.MYSQL_USER? | default "root")
    let host = ($env.MYSQL_HOST? | default "127.0.0.1")
    let port = ($env.MYSQL_PORT? | default "3306")
    let password = ($env.MYSQL_PASSWORD? | default "root")
    let error_log = "/tmp/duplicate_mysql_error.log"
    
    print $"Dropping '($target_db)' and generating from '($source_db)' schema"
    
    # Drop target database if exists
    ^mysql $"-h($host)" $"-P($port)" $"-u($user)" $"-p($password)" --force -e $"DROP DATABASE IF EXISTS `($target_db)`;"
    
    # Create target database
    ^mysql $"-h($host)" $"-P($port)" $"-u($user)" $"-p($password)" -e $"CREATE DATABASE `($target_db)`;"
    
    # Dump schema only (no data) and import to target
    ^mysqldump --force --protocol=tcp --no-data $"--log-error=($error_log)" $"-h($host)" $"-P($port)" $"-u($user)" $"-p($password)" $source_db | ^mysql $"-h($host)" $"-P($port)" $"-u($user)" $"-p($password)" $target_db
    
    print $"Clone '($target_db)' successful"
    
    # Copy django_migrations table data
    ^mysql $"-h($host)" $"-P($port)" $"-u($user)" $"-p($password)" -e "SET GLOBAL FOREIGN_KEY_CHECKS=0;"
    ^mysql $"-h($host)" $"-P($port)" $"-u($user)" $"-p($password)" -e $"INSERT ($target_db).django_migrations SELECT * FROM ($source_db).django_migrations;"
    ^mysql $"-h($host)" $"-P($port)" $"-u($user)" $"-p($password)" -e "SET GLOBAL FOREIGN_KEY_CHECKS=1;"
}

# Export database to SQL file
export def export_db [
    database: string          # Database name to export
    output_file?: string      # Output file path (optional, defaults to <database>_<timestamp>.sql)
    --container: string       # Docker container name (default: paradox_mysql)
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
    
    # Determine container name
    let container_name = if ($container | is-empty) {
        if ("MYSQL_CONTAINER" in $env) { $env.MYSQL_CONTAINER } else { "paradox_mysql" }
    } else {
        $container
    }
    
    # Check if Docker container exists and is running
    let container_running = (docker ps --format "{{.Names}}" | lines | any {|c| $c == $container_name})
    
    if $container_running {
        print $"🐳 Using Docker container: ($container_name)"
        
        # Get MySQL credentials from environment or use defaults
        let mysql_user = if ("MYSQL_USER" in $env) { $env.MYSQL_USER } else { "root" }
        let mysql_password = if ("MYSQL_PASSWORD" in $env) { $env.MYSQL_PASSWORD } else { "" }
        
        # Export database via Docker exec
        print "⏳ Exporting data..."
        docker exec $container_name mysqldump -u $mysql_user $"-p($mysql_password)" $database | save -f $export_path
        
    } else {
        # Fallback to local MySQL client
        print "💻 Using local MySQL client"
        
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
    }
    
    # Show file size
    let file_size = (ls $export_path | get size | first)
    print $"✓ Database exported successfully!"
    print $"  Size: ($file_size)"
    print $"  Location: ($export_path)"
}

# Import SQL file to database
export def import_db [
    database: string          # Database name to import to
    sql_file: string          # SQL file path to import
    --create                  # Create database if it doesn't exist
    --drop                    # Drop database if it exists before importing
    --container: string       # Docker container name (default: paradox_mysql)
] {
    # Expand path to handle ~ and relative paths
    let import_path = ($sql_file | path expand)
    
    # Check if file exists
    if not ($import_path | path exists) {
        print $"❌ Error: SQL file not found: ($import_path)"
        return
    }
    
    print $"📥 Importing SQL file to database: ($database)"
    print $"📁 SQL file: ($import_path)"
    
    # Show file size
    let file_size = (ls $import_path | get size | first)
    print $"📊 File size: ($file_size)"
    
    # Determine container name
    let container_name = if ($container | is-empty) {
        if ("MYSQL_CONTAINER" in $env) { $env.MYSQL_CONTAINER } else { "paradox_mysql" }
    } else {
        $container
    }
    
    # Check if Docker container exists and is running
    let container_running = (docker ps --format "{{.Names}}" | lines | any {|c| $c == $container_name})
    
    if $container_running {
        print $"🐳 Using Docker container: ($container_name)"
        
        # Get MySQL credentials from environment or use defaults
        let mysql_user = if ("MYSQL_USER" in $env) { $env.MYSQL_USER } else { "root" }
        let mysql_password = if ("MYSQL_PASSWORD" in $env) { $env.MYSQL_PASSWORD } else { "" }
        
        # Drop database if --drop flag is set
        if $drop {
            print "🗑️  Dropping database if exists..."
            docker exec $container_name mysql -u $mysql_user $"-p($mysql_password)" -e $"DROP DATABASE IF EXISTS ($database);"
        }
        
        # Create database if --create flag is set
        if $create {
            print "✨ Creating database if it doesn't exist..."
            docker exec $container_name mysql -u $mysql_user $"-p($mysql_password)" -e $"CREATE DATABASE IF NOT EXISTS ($database);"
        }
        
        # Check if pv (pipe viewer) is available for progress bar
        let has_pv = (which pv | length) > 0
        
        if $has_pv {
            # Use pv for progress bar
            pv $import_path | docker exec -i $container_name mysql -u $mysql_user $"-p($mysql_password)" $database
        } else {
            # No progress bar, just import
            open $import_path | docker exec -i $container_name mysql -u $mysql_user $"-p($mysql_password)" $database
        }
        
        print "✓ Database imported successfully!"
    } else {
        # Fallback to local MySQL client
        print "💻 Using local MySQL client"
        
        # Check if MySQL credentials are available
        if ("MYSQL_USER" not-in $env or "MYSQL_PASSWORD" not-in $env or "MYSQL_HOST" not-in $env) {
            print "⚠️  Warning: MYSQL_USER, MYSQL_PASSWORD, or MYSQL_HOST not set in environment"
            print "Attempting to use default credentials..."
            
            # Drop database if --drop flag is set
            if $drop {
                print "🗑️  Dropping database if exists..."
                mysql -e $"DROP DATABASE IF EXISTS ($database);"
            }
            
            # Import without credentials (will use .my.cnf or prompt)
            if $create {
                mysql -e $"CREATE DATABASE IF NOT EXISTS ($database);"
            }
            open $import_path | mysql $database
        } else {
            # Create a temporary MySQL config file for secure password handling
            let mysql_config = "/tmp/.my.cnf.import.tmp"
            $"[client]\nuser=($env.MYSQL_USER)\npassword=($env.MYSQL_PASSWORD)\nhost=($env.MYSQL_HOST)\n" | save -f $mysql_config
            
            
            # Check if pv (pipe viewer) is available for progress bar
            let has_pv = (which pv | length) > 0
            
            if $has_pv {
                # Use pv for progress bar
                pv $import_path | mysql $"--defaults-extra-file=($mysql_config)" $database
            } else {
                # No progress bar, just import
                open $import_path | mysql $"--defaults-extra-file=($mysql_config)" $database
            }
            if $drop {
                print "🗑️  Dropping database if exists..."
                mysql $"--defaults-extra-file=($mysql_config)" -e $"DROP DATABASE IF EXISTS ($database);"
            }
            
            # Create database if --create flag is set
            if $create {
                print "✨ Creating database if it doesn't exist..."
                mysql $"--defaults-extra-file=($mysql_config)" -e $"CREATE DATABASE IF NOT EXISTS ($database);"
            }
            
            # Import SQL file
            print "⏳ Importing data..."
            open $import_path | mysql $"--defaults-extra-file=($mysql_config)" $database
            
            # Cleanup temp config
            rm $mysql_config
            
            print "✓ Database imported successfully!"
        }
    }
}
