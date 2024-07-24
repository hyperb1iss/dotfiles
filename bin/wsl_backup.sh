#!/bin/bash

# Set variables
SOURCE_DIR="$HOME"
BACKUP_DIR="/mnt/d/WSL2_Backups"
DATE=$(date +"%Y-%m-%d")
LATEST_LINK="$BACKUP_DIR/latest"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Perform the backup
echo "Creating incremental backup of $SOURCE_DIR..."
rsync -avh --delete \
    --exclude=".cache" \
    --exclude="*/caches/*" \
    --exclude=".local/share/Trash" \
    --exclude="*/node_modules" \
    --exclude="*/.venv" \
    --exclude="*/venv" \
    --exclude="*/__pycache__" \
    --link-dest="$LATEST_LINK" \
    "$SOURCE_DIR/" "$BACKUP_DIR/$DATE/"

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "Backup completed successfully: $BACKUP_DIR/$DATE/"
    
    # Update the "latest" symlink
    ln -snf "$BACKUP_DIR/$DATE" "$LATEST_LINK"
else
    echo "Backup failed!"
    exit 1
fi

# Remove backups older than 30 days
find "$BACKUP_DIR" -maxdepth 1 -type d -name "20*-*-*" -mtime +30 -exec rm -rf {} +

# Print disk usage
echo "Current backup disk usage:"
du -sh "$BACKUP_DIR"

echo "Backup process completed."
