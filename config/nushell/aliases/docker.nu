# Docker aliases and utilities
# Common Docker CLI shortcuts

# -------------------------------------------------------------------
# Help function
# -------------------------------------------------------------------
export def "help docker" [filter?: string] {
    let help_text = "📚 Docker Aliases & Utilities

BASIC DOCKER
    d                 alias     docker (base command)
    dps               alias     docker ps (running containers)
    dpsa              alias     docker ps -a (all containers)
    di                alias     docker images
    drmi              alias     docker rmi (remove image)
    drm               alias     docker rm (remove container)
    
CONTAINER MANAGEMENT
    dstart            alias     docker start
    dstop             alias     docker stop
    drestart          alias     docker restart
    dkill             alias     docker kill
    dlogs             alias     docker logs
    dlogsf            alias     docker logs -f (follow)
    dexec             alias     docker exec -it
    dinspect          alias     docker inspect
    
    dsh <container>   func      exec bash shell in container
    dsha <container>  func      exec sh shell in container (alpine)
    dstopall          func      stop all running containers
    drmall            func      remove all stopped containers
    dtool             func      exec into container or list containers
    
DOCKER COMPOSE
    dc                alias     docker-compose
    dcup              alias     docker-compose up
    dcupd             alias     docker-compose up -d (detached)
    dcdown            alias     docker-compose down
    dcrestart         alias     docker-compose restart
    dclogs            alias     docker-compose logs
    dclogsf           alias     docker-compose logs -f
    dcps              alias     docker-compose ps
    dcbuild           alias     docker-compose build
    dcpull            alias     docker-compose pull
    
    dupdate <svc>     func      pull and restart a compose service
    dlogs-tail        func      tail logs with custom line count
    
SYSTEM & CLEANUP
    dprune            alias     docker system prune
    dprunea           alias     docker system prune -a
    ddf               alias     docker system df (disk usage)
    
    remove_image      func      remove image by name/ID (with confirmation)
    drmdangling       func      remove dangling images
    dstats            func      show container resource usage
    dcleanall         func      complete Docker cleanup
    
VOLUMES
    dvls              alias     docker volume ls
    dvinspect         alias     docker volume inspect
    dvcreate          alias     docker volume create
    dvrm              alias     docker volume rm
    
    dvlist            func      list volumes with details
    dvprune           func      remove unused volumes (with confirmation)
    dvremove <vol>    func      remove volume by name (with confirmation)
    dvinfo <vol>      func      inspect volume details
    dvcreate-new      func      create new volume with options
    dvstats           func      show volume usage statistics

Usage: help docker [filter]
  filter - Optional: filter results by keyword
Example: help docker compose
"
    
    if ($filter | is-empty) {
        print $help_text
    } else {
        print ($help_text | lines | where { |line| $line =~ $filter } | str join "\n")
    }
}

# Basic Docker commands
export alias d = docker
export alias dps = docker ps
export alias dpsa = docker ps -a
export alias di = docker images
export alias drmi = docker rmi
export alias drm = docker rm

# Docker container management
export alias dstart = docker start
export alias dstop = docker stop
export alias drestart = docker restart
export alias dkill = docker kill
export alias dlogs = docker logs
export alias dlogsf = docker logs -f
export alias dexec = docker exec -it
export alias dinspect = docker inspect

# Docker system commands
export alias dprune = docker system prune
export alias dprunea = docker system prune -a
export alias ddf = docker system df

# Docker volume management
export alias dvls = docker volume ls
export alias dvinspect = docker volume inspect
export alias dvcreate = docker volume create
export alias dvrm = docker volume rm

# Docker Compose aliases
export alias dc = docker-compose
export alias dcup = docker-compose up
export alias dcupd = docker-compose up -d
export alias dcdown = docker-compose down
export alias dcrestart = docker-compose restart
export alias dclogs = docker-compose logs
export alias dclogsf = docker-compose logs -f
export alias dcps = docker-compose ps
export alias dcbuild = docker-compose build
export alias dcpull = docker-compose pull

# Get into a running container with bash
export def dsh [container: string] {
    docker exec -it $container /bin/bash
}

# Get into a running container with sh (for alpine images)
export def dsha [container: string] {
    docker exec -it $container /bin/sh
}

# Stop all running containers
export def dstopall [] {
    let running = (docker ps -q | lines | where $it != "")
    if ($running | is-empty) {
        print "ℹ️  No running containers"
    } else {
        print $"⚠️  Stopping ($running | length) container(s)..."
        docker stop ...$running
        print "✓ All containers stopped"
    }
}

# Remove all stopped containers
export def drmall [] {
    let stopped = (docker ps -aq | lines | where $it != "")
    if ($stopped | is-empty) {
        print "ℹ️  No stopped containers to remove"
    } else {
        print $"⚠️  About to remove ($stopped | length) container(s)"
        let confirm = (input "Type 'yes' to confirm: ")
        if $confirm == "yes" {
            docker rm ...$stopped
            print "✓ All stopped containers removed"
        } else {
            print "❌ Operation cancelled"
        }
    }
}

# Remove dangling images
export def drmdangling [] {
    let dangling = (docker images -f "dangling=true" -q | lines | where $it != "")
    if ($dangling | is-empty) {
        print "ℹ️  No dangling images found"
    } else {
        print $"⚠️  About to remove ($dangling | length) dangling image(s)"
        docker rmi ...$dangling
        print "✓ Dangling images removed"
    }
}

# Show container resource usage
export def dstats [] {
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}

# Pull and restart a service (useful for updates)
export def dupdate [service: string] {
    print $"📥 Pulling latest image for ($service)..."
    docker-compose pull $service
    print $"🔄 Restarting ($service)..."
    docker-compose up -d $service
    print $"✓ ($service) updated and restarted"
}

# View logs for a specific service with tail
export def dlogs-tail [
    container: string
    --lines(-n): int = 100  # Number of lines to show
] {
    docker logs --tail $lines -f $container
}

# Clean up everything (containers, images, volumes, networks)
export def dcleanall [] {
    print "⚠️  This will remove:"
    print "  - All stopped containers"
    print "  - All networks not used by containers"
    print "  - All dangling images"
    print "  - All dangling build cache"
    print ""
    let confirm = (input "Type 'yes' to confirm: ")
    if $confirm == "yes" {
        docker system prune -a --volumes
        print "✓ Docker cleanup complete"
    } else {
        print "❌ Cleanup cancelled"
    }
}

# Docker toolbox - exec into container or list containers
export def dtool [
    container?: string     # Container name or ID (partial match supported)
    --list (-l)            # List all running containers
    filter?: string        # Optional filter for container names
    ...args                # Command to run (default: /bin/bash)
] {
    # Handle --help
    if ($container == "--help" or $container == "-h" or $container == "help") {
        print "Usage: dtool [container] [--list [filter]] [command]"
        print ""
        print "Examples:"
        print "  dtool web                     # exec into container matching 'web'"
        print "  dtool web /bin/sh             # exec with custom shell"
        print "  dtool --list                  # list all running containers"
        print "  dtool --list api              # list containers matching 'api'"
        print "  dtool                         # interactive: select from running containers"
        return
    }
    
    # Handle --list mode
    if $list {
        let containers = (docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | lines)
        
        if ($filter | is-empty) {
            print ($containers | str join "\n")
        } else {
            print ($containers | where { |line| $line =~ $filter } | str join "\n")
        }
        return
    }
    
    # Get running containers
    let running = (docker ps --format "{{.Names}}" | lines | where $it != "")
    
    if ($running | is-empty) {
        print "❌ No running containers found"
        return
    }
    
    # If no container specified, show interactive list
    if ($container | is-empty) {
        print "Running containers:"
        $running | enumerate | each { |item| print $"  [($item.index)] ($item.item)" }
        print ""
        let choice = (input "Select container number (or 'q' to quit): ")
        
        if $choice == "q" {
            return
        }
        
        let selected_idx = ($choice | into int)
        let selected = ($running | get $selected_idx)
        
        let cmd = (if ($args | is-empty) { ["/bin/bash"] } else { $args })
        print $"🐳 Executing into ($selected)..."
        docker exec -it $selected ...$cmd
        return
    }
    
    # Find matching container
    let matches = ($running | where { |name| $name =~ $container })
    
    if ($matches | is-empty) {
        print $"❌ No running container found matching: ($container)"
        print "\nRunning containers:"
        $running | each { |name| print $"  - ($name)" }
        return
    }
    
    if ($matches | length) > 1 {
        print $"⚠️  Multiple containers match '($container)':"
        $matches | each { |name| print $"  - ($name)" }
        print "\nPlease be more specific."
        return
    }
    
    let target = ($matches | first)
    let cmd = (if ($args | is-empty) { ["/bin/bash"] } else { $args })
    
    print $"🐳 Executing into ($target)..."
    docker exec -it $target ...$cmd
}

# List Docker volumes with details
export def dvlist [] {
    docker volume ls --format "table {{.Name}}\t{{.Driver}}\t{{.Mountpoint}}"
}

# Remove unused volumes
export def dvprune [] {
    let unused = (docker volume ls -qf dangling=true | lines | where $it != "")
    
    if ($unused | is-empty) {
        print "ℹ️  No unused volumes found"
    } else {
        print $"⚠️  About to remove ($unused | length) unused volume(s):"
        $unused | each { |v| print $"  - ($v)" }
        print ""
        let confirm = (input "Type 'yes' to confirm: ")
        if $confirm == "yes" {
            docker volume prune -f
            print "✓ Unused volumes removed"
        } else {
            print "❌ Volume pruning cancelled"
        }
    }
}

# Remove specific volume by name
export def dvremove [
    volume: string     # Volume name (partial match supported)
    --force(-f)        # Force removal without confirmation
] {
    # Find matching volumes
    let all_volumes = (docker volume ls --format "{{.Name}}" | lines | where $it != "")
    let matches = ($all_volumes | where { |v| $v =~ $volume })
    
    if ($matches | is-empty) {
        print $"❌ No volumes found matching: ($volume)"
        print "\nAvailable volumes:"
        $all_volumes | each { |v| print $"  - ($v)" }
        return
    }
    
    print "Found matching volumes:"
    $matches | each { |v| print $"  📦 ($v)" }
    print ""
    
    if not $force {
        let confirm = (input $"⚠️  Remove ($matches | length) volume(s)? Type 'yes' to confirm: ")
        if $confirm != "yes" {
            print "❌ Volume removal cancelled"
            return
        }
    }
    
    for vol in $matches {
        docker volume rm $vol
        print $"✓ Removed volume: ($vol)"
    }
    print $"\n✓ Removed ($matches | length) volume(s)"
}

# Inspect volume details
export def dvinfo [volume: string] {
    let all_volumes = (docker volume ls --format "{{.Name}}" | lines | where $it != "")
    let matches = ($all_volumes | where { |v| $v =~ $volume })
    
    if ($matches | is-empty) {
        print $"❌ No volumes found matching: ($volume)"
        return
    }
    
    if ($matches | length) > 1 {
        print $"⚠️  Multiple volumes match '($volume)':"
        $matches | each { |v| print $"  - ($v)" }
        print "\nPlease be more specific or use full volume name."
        return
    }
    
    let vol = ($matches | first)
    print $"📦 Volume information for: ($vol)"
    print ""
    docker volume inspect $vol | from json | table -e
}

# Create a new volume
export def dvcreate-new [
    name: string              # Volume name
    --driver(-d): string      # Volume driver (default: local)
    --label(-l): list<string> # Labels in key=value format
] {
    mut cmd = ["docker", "volume", "create"]
    
    if ($driver | is-not-empty) {
        $cmd = ($cmd | append ["--driver", $driver])
    }
    
    if ($label | is-not-empty) {
        for lbl in $label {
            $cmd = ($cmd | append ["--label", $lbl])
        }
    }
    
    $cmd = ($cmd | append $name)
    
    print $"Creating volume: ($name)"
    run-external "docker" "volume" "create" ...(if ($driver | is-not-empty) {["--driver", $driver]} else {[]}) ...(if ($label | is-not-empty) {$label | each {|l| ["--label", $l]} | flatten} else {[]}) $name
    print $"✓ Volume created: ($name)"
}

# Show volume usage statistics
export def dvstats [] {
    print "📊 Docker Volume Statistics"
    print ""
    
    let volumes = (docker volume ls -q | lines | where $it != "")
    let total_count = ($volumes | length)
    
    let unused = (docker volume ls -qf dangling=true | lines | where $it != "")
    let unused_count = ($unused | length)
    
    let in_use_count = ($total_count - $unused_count)
    
    print $"Total volumes:   ($total_count)"
    print $"In use:          ($in_use_count)"
    print $"Unused:          ($unused_count)"
    print ""
    
    if $unused_count > 0 {
        print "💡 Run 'dvprune' to remove unused volumes"
    }
}
