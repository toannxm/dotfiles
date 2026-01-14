#!/bin/bash
set -e

echo "=== Docker Volume Backup Script ==="
echo "This script will backup all Docker volumes to compressed tar.gz files"
echo ""

BACKUP_DIR=$HOME/Workday/MacSetup/dotfiles/docker

# Function to backup a volume
backup_volume() {
    local volume_name=$1
    local backup_file=$2
    
    echo "Backing up $volume_name..."
    
    # Check if volume exists
    if ! docker volume inspect $volume_name >/dev/null 2>&1; then
        echo "⚠ Warning: Volume $volume_name does not exist, skipping..."
        return
    fi
    
    # Backup data (will overwrite existing backup)
    docker run --rm \
        -v $volume_name:/data \
        -v $BACKUP_DIR:/backup \
        alpine sh -c "cd /data && tar czf /backup/$backup_file ."
    
    echo "✓ $volume_name backed up to $backup_file"
}

echo "Starting volume backup..."
echo ""

backup_volume "paradox-docker_mysql-data" "paradox-mysql.tar.gz"
backup_volume "paradox-docker_mongo-data" "paradox-mongo.tar.gz"
backup_volume "paradox-docker_redis-data" "paradox-redis.tar.gz"
backup_volume "paradox-docker_elasticsearch-data" "paradox-elasticsearch.tar.gz"
backup_volume "paradox-docker_localstack" "paradox-localstack.tar.gz"
backup_volume "paradox-docker_es-snapshots" "paradox-es-snapshots.tar.gz"

echo ""
echo "=== Backup Complete ==="
echo "All volumes have been backed up successfully!"
echo "Backup location: $BACKUP_DIR"

