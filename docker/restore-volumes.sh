#!/bin/bash
set -e

echo "=== Docker Volume Restore Script ==="
echo "This script will restore all backed up volumes to Docker Desktop"
echo ""

BACKUP_DIR=$HOME/Workday/MacSetup/dotfiles/docker

# Function to restore a volume
restore_volume() {
    local volume_name=$1
    local backup_file=$2
    
    echo "Restoring $volume_name..."
    
    # Create volume if it doesn't exist
    docker volume create $volume_name
    
    # Restore data
    docker run --rm \
        -v $volume_name:/data \
        -v $BACKUP_DIR:/backup \
        alpine sh -c "cd /data && tar xzf /backup/$backup_file"
    
    echo "✓ $volume_name restored"
}

echo "Starting volume restoration..."
echo ""

restore_volume "paradox-docker_mysql-data" "paradox-mysql.tar.gz"
restore_volume "paradox-docker_mongo-data" "paradox-mongo.tar.gz"
restore_volume "paradox-docker_redis-data" "paradox-redis.tar.gz"
restore_volume "paradox-docker_elasticsearch-data" "paradox-elasticsearch.tar.gz"
restore_volume "paradox-docker_localstack" "paradox-localstack.tar.gz"
restore_volume "paradox-docker_es-snapshots" "paradox-es-snapshots.tar.gz"

echo ""
echo "=== Restoration Complete ==="
echo "All volumes have been restored successfully!"
echo ""
echo "Next steps:"
echo "1. Navigate to your docker compose directory (ex: cd ~/Workday/Projects/paradox-docker)"
echo "2. Start services: docker-compose -f docker-compose.service.yml up -d"
