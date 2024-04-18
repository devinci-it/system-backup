#!/bin/bash

# Set HOME explicitly to /home/vince
HOME=/home/vince

# Define backup directory
DATE=$(date +"%Y%m%d")
BACKUP_DIR="$HOME/SystemBackup/storage/$DATE"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Log file
LOG_FILE="$BACKUP_DIR/backup_$DATE.log"

# Status file
STATUS_FILE="$BACKUP_DIR/.status"

# Function to log messages
log_message() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

# Function to print step banner
print_banner() {
    echo "============================================================"
    echo " $1"
    echo "============================================================"
}

# Print script start banner
print_banner "Starting backup script..."

# Logging start of backup process
log_message "Starting backup process..."

# Perform incremental backup using rsync
print_banner "Performing incremental backup..."
sudo rsync -av --exclude="$BACKUP_DIR" --delete --backup --backup-dir="$BACKUP_DIR/incremental_backup" /etc /var /srv /home "$BACKUP_DIR/full_backup" >> "$LOG_FILE" 2>&1
echo "Incremental backup completed."

# Backup list of installed packages
print_banner "Backing up list of installed packages..."
apt list --installed > "$BACKUP_DIR/apt_installed_packages.txt"
echo "List of installed packages backed up."

# Backup MariaDB databases and tables
print_banner "Backing up MariaDB databases and tables..."
sudo mysqldump -u root -p --all-databases > "$BACKUP_DIR/mariadb_all_databases.sql"
echo "MariaDB databases and tables backed up."

# Archive the log file
print_banner "Archiving log file..."
tar -czf "$HOME/SystemBackup/backup_$DATE_log.tar.gz" "$LOG_FILE"
echo "Log file archived."

# Calculate backup size
print_banner "Calculating backup size..."
backup_size=$(du -sh "$BACKUP_DIR" | awk '{print $1}')
echo "Backup size calculated: $backup_size"

# Write status to status file
print_banner "Writing status to status file..."
echo "Backup Status: Completed" > "$STATUS_FILE"
echo "Last Run Path to Backup: $BACKUP_DIR" >> "$STATUS_FILE"
echo "Exit Code: $?" >> "$STATUS_FILE"
echo "Next Run: $(date -d "+1 day" +"%Y-%m-%d")" >> "$STATUS_FILE"
echo "Time Taken: $(($(date +%s) - $(date -d "$DATE" +%s))) seconds" >> "$STATUS_FILE"
echo "Backup Size: $backup_size" >> "$STATUS_FILE"
echo "Status written to status file."

# Create symbolic link to status file in the SystemBackup directory
ln -s "$STATUS_FILE" "$HOME/SystemBackup/.status"
echo "Symbolic link to status file created."

# Logging end of backup process
log_message "Backup completed successfully."

# Print script end banner
print_banner "Backup script completed successfully."

# Supplemental full backup script
echo "Would you like to perform a supplemental full backup? (y/n)"
read choice

if [ "$choice" = "y" ]; then
    echo "Performing a dry run of the supplemental full backup..."
    
    echo "Dry run: sudo rsync --dry-run -av --exclude='$BACKUP_DIR' /etc /var /srv /home $BACKUP_DIR/full_backup"
    
    echo "Proceed with the supplemental full backup? (y/n)"
    read confirm
    if [ "$confirm" = "y" ]; then
        echo "Performing the supplemental full backup..."
        sudo rsync -av --exclude="$BACKUP_DIR" /etc /var /srv /home "$BACKUP_DIR/full_backup"
        echo "Supplemental full backup completed successfully."
    else
        echo "Supplemental full backup cancelled."
    fi
fi

head -n  50  "$BACKUP_DIR/.status"
