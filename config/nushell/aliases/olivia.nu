# Project-specific aliases (Olivia)
# Django management commands, virtualenv activation, and project navigation

# -------------------------------------------------------------------
# Help function
# -------------------------------------------------------------------
export def "help olivia" [] {
    print "📚 Olivia Project Aliases & Utilities\n"
    print "Navigation:"
    print "  olivia-core    - cd to olivia-core"
    print "  olivia-ui      - cd to olivia UI\n"
    print "Setup & Run:"
    print "  olivia-app-nuxt3         - Install dependencies and setup Nuxt3 environment"
    print "  olivia-app-nuxt3 --clean - Clean, install, and setup Nuxt3 environment"
    print "  olivia-app-nuxt2         - Install, build, and run Nuxt2 dev server"
    print "  olivia-app-nuxt2 --clean - Clean before Nuxt2 setup"
    print "  olivia-app-django        - Run Django development server"
    print "  olivia-celery            - Run Celery worker\n"
    print "Virtual Environments:"
    print "  create-olivia-venvs [version] - Create pyenv venvs (e.g., create-olivia-venvs 3.11.7)"
    print "  activate-core    - Activate core Python venv"
    print "  activate-ui      - Activate UI Python venv"
    print "  deactivate-venv  - Deactivate current pyenv virtual environment\n"
    print "Django:"
    print "  migrate        - Run migrations"
    print "  makemigrations - Create migrations"
    print "  makemigrations_merge - Merge migrations\n"
    print "Logs:"
    print "  log_core       - Tail core logs"
    print "  log_ui         - Tail UI logs"
    print "  del_log        - Truncate all project logs"
}

# -------------------------------------------------------------------
# Path constants
# -------------------------------------------------------------------
const OLIVIA_SRC_ROOT = ("~/Workday/Olivia/SourceCode" | path expand)
const CORE_VENV = ("~/.pyenv/versions/olivia-core-3117" | path expand)
const UI_VENV = ("~/.pyenv/versions/olivia-ui-3117" | path expand)
const PYENV_ROOT = ("~/.pyenv" | path expand)

# -------------------------------------------------------------------
# Directory navigation aliases
# -------------------------------------------------------------------
export alias olivia-core = cd $"($OLIVIA_SRC_ROOT)/olivia-core"
export alias olivia-ui = cd $"($OLIVIA_SRC_ROOT)/olivia"
export alias paradox-docker = cd $"($OLIVIA_SRC_ROOT)/paradox-docker"

# -------------------------------------------------------------------
# Django management commands
# -------------------------------------------------------------------
export alias migrate = python $"($env.OLIVIA_CORE)/src/manage.py" migrate
export alias makemigrations = python $"($env.OLIVIA_CORE)/src/manage.py" makemigrations
export alias makemigrations_merge = python $"($env.OLIVIA_CORE)/src/manage.py" makemigrations --merge
export alias log_core = tail -500f $"($env.OLIVIA_CORE)/logs/aicore.log"
export alias log_ui = tail -500f $"($env.OLIVIA_UI)/logs/aipublic.log"

# -------------------------------------------------------------------
# Python virtual environment activation helpers
# -------------------------------------------------------------------
# Note: Poetry is configured globally with:
#   - virtualenvs.prefer-active-python = true
#   - virtualenvs.options.system-site-packages = true
# This ensures Poetry uses the active pyenv environment
export def --env activate-core [] {
    if not ($CORE_VENV | path exists) {
        error make { msg: $"Core venv not found at ($CORE_VENV)" }
    }

    # Check if already active
    if ($env.PYENV_VERSION? == "olivia-core-3117") {
        return
    }

    # Activate pyenv environment
    $env.PYENV_VERSION = "olivia-core-3117"
    $env.VIRTUAL_ENV = $CORE_VENV

    # print "✓ Activated core venv (olivia-core-3117)"
}

export def --env activate-ui [] {
    if not ($UI_VENV | path exists) {
        error make { msg: $"UI venv not found at ($UI_VENV)" }
    }

    # Check if already active
    if ($env.PYENV_VERSION? == "olivia-ui-3117") {
        return
    }

    # Activate pyenv environment
    $env.PYENV_VERSION = "olivia-ui-3117"
    $env.VIRTUAL_ENV = $UI_VENV

    # print "✓ Activated ui venv (olivia-ui-3117)"
}

export def --env deactivate-venv [] {
    # Check if a pyenv virtual environment is active
    if ($env.PYENV_VERSION? == null) and ($env.VIRTUAL_ENV? == null) {
        print "No pyenv virtual environment is currently active"
        return
    }

    # Unset the environment variables
    hide-env PYENV_VERSION
    hide-env VIRTUAL_ENV

    print "✓ Deactivated pyenv virtual environment"
}

# Create pyenv virtual environments for Olivia projects
# Usage: create-olivia-venvs [python_version]
# Example: create-olivia-venvs 3.11.7  - Creates olivia-core-3117 and olivia-ui-3117
export def create-olivia-venvs [
    python_version: string = "3.11.7"  # Python version to use (e.g., 3.11.7)
] {
    # Extract version numbers without dots (e.g., 3.11.7 -> 3117)
    let version_short = ($python_version | str replace --all '.' '')
    let core_venv_name = $"olivia-core-($version_short)"
    let ui_venv_name = $"olivia-ui-($version_short)"

    print $"🐍 Creating pyenv virtual environments with Python ($python_version)\n"

    # Check if Python version is installed
    let installed_versions = (pyenv versions --bare | lines)
    if not ($python_version in $installed_versions) {
        print $"⚠️  Python ($python_version) is not installed"
        print $"📦 Installing Python ($python_version)..."
        pyenv install $python_version
    }

    # Create olivia-core venv
    print $"📦 Creating ($core_venv_name)..."
    try {
        pyenv virtualenv $python_version $core_venv_name
        print $"✅ Created ($core_venv_name)"
    } catch {
        print $"⚠️  ($core_venv_name) may already exist or failed to create"
    }

    # Create olivia-ui venv
    print $"📦 Creating ($ui_venv_name)..."
    try {
        pyenv virtualenv $python_version $ui_venv_name
        print $"✅ Created ($ui_venv_name)"
    } catch {
        print $"⚠️  ($ui_venv_name) may already exist or failed to create"
    }

    print $"\n✅ Virtual environments setup complete!"
    print $"\nTo activate:"
    print $"  activate-core  - Activate ($core_venv_name)"
    print $"  activate-ui    - Activate ($ui_venv_name)"
}

# -------------------------------------------------------------------
# Utility functions
# -------------------------------------------------------------------

# Truncate all log files in project logs directories
export def del_log [] {
    print "🧹 Truncating Olivia logs..."

    # Truncate all logs in olivia-core/logs
    let core_logs = $"($env.OLIVIA_CORE)/logs"
    if ($core_logs | path exists) {
        let core_log_files = (ls $core_logs | where type == file and name =~ '\.log$')
        for log in $core_log_files {
            "" | save -f $log.name
            print $"✓ Truncated ($log.name | path basename)"
        }
    }

    # Truncate all logs in olivia/logs
    let ui_logs = $"($env.OLIVIA_UI)/logs"
    if ($ui_logs | path exists) {
        let ui_log_files = (ls $ui_logs | where type == file and name =~ '\.log$')
        for log in $ui_log_files {
            "" | save -f $log.name
            print $"✓ Truncated ($log.name | path basename)"
        }
    }

    print "✅ All log files truncated"
}

# Setup Olivia UI Nuxt3 environment
# Usage: olivia-app-nuxt3       - Install dependencies and setup Nuxt3 environment
#        olivia-app-nuxt3 --clean - Clean before install
export def olivia-app-nuxt3 [
    --clean (-c)  # Run cleanup before install
] {
    if not ($env.OLIVIA_UI? | is-empty) {
        cd $env.OLIVIA_UI

        if $clean {
            print "🧹 Running cleanup..."
            pnpm cleanup

            print "📦 Installing dependencies..."
            pnpm i
        }

        print "⚙️  Setting up environment..."
        pnpm env-nx @paradoxai/olivia:dev

        print "✅ Olivia Nuxt3 setup complete!"
    } else {
        error make { msg: "OLIVIA_UI environment variable not set" }
    }
}

# Setup Olivia UI Nuxt2 environment and run dev server
# Usage: olivia-app-nuxt2       - Install dependencies, build, and run Nuxt2 dev server
#        olivia-app-nuxt2 --clean - Clean before install
export def olivia-app-nuxt2 [
    --clean (-c)  # Run cleanup before install
] {
    if not ($env.OLIVIA_UI? | is-empty) {
        cd $env.OLIVIA_UI

        if $clean {
            print "🧹 Running cleanup..."
            pnpm cleanup
        }

        print "📂 Entering client directory..."
        cd client

        print "📦 Installing dependencies..."
        pnpm i

        print "🔨 Building (CI mode)..."
        pnpm build:ci

        print "🚀 Starting development server..."
        pnpm dev
    } else {
        error make { msg: "OLIVIA_UI environment variable not set" }
    }
}

# Run Olivia Django development server
# Usage: olivia-app-django - Run Django server on localhost:8000
export def olivia-app-django [] {
    if not ($env.OLIVIA_UI? | is-empty) {
        cd $env.OLIVIA_UI

        print "🐍 Starting Django development server..."
        python ./src/manage.py runserver localhost:8000
    } else {
        error make { msg: "OLIVIA_UI environment variable not set" }
    }
}

# Run Olivia Celery worker
# Usage: olivia-celery - Run Celery worker with test queues
export def olivia-celery [] {
    if not ($env.OLIVIA_CORE? | is-empty) {
        cd $env.OLIVIA_CORE

        print "🌿 Starting Celery worker..."
        celery --workdir=src -A ai_queue worker -c3 -E -l INFO -n worker-1@%h -Q test.olivia.queue.primary,test.olivia.queue.communication,test.olivia.queue.general,test.olivia.queue.adhoc,test.olivia.queue.compaign
    } else {
        error make { msg: "OLIVIA_CORE environment variable not set" }
    }
}

