#!/bin/bash

# This script fully uninstalls Jellyfin from Debian-based systems.
# It stops the service, purges packages, removes configuration/data directories,
# and removes the APT repository source and GPG key.

# WARNING: This script will permanently delete all Jellyfin data and configurations.
# Ensure you have backed up any important data before proceeding.

echo "Starting Jellyfin full uninstallation process..."

# 1. Stop the Jellyfin service
echo "1. Stopping Jellyfin service..."
sudo systemctl stop jellyfin || echo "Jellyfin service not running or failed to stop, continuing..."

# 2. Purge all Jellyfin-related packages
# The '*' ensures all associated packages (server, web, ffmpeg) are removed.
echo "2. Purging Jellyfin packages and configurations..."
sudo apt purge -y "jellyfin*"

# 3. Remove unused dependencies that were installed with Jellyfin
echo "3. Removing unused dependencies..."
sudo apt autoremove -y

# 4. Manually remove remaining Jellyfin data and configuration directories
# These directories might contain user data, logs, and other residual files.
echo "4. Removing residual Jellyfin directories..."
sudo rm -rf /var/lib/jellyfin \
            /var/log/jellyfin \
            /var/cache/jellyfin \
            /etc/jellyfin \
            /usr/share/jellyfin \
            /etc/systemd/system/multi-user.target.wants/jellyfin.service \
            /etc/systemd/system/jellyfin.service.d \
            /etc/default/jellyfin \
            /usr/lib/jellyfin \
            /usr/lib/jellyfin-ffmpeg/ \
            /usr/lib/systemd/system/jellyfin.service

# Remove user-specific configuration if it exists (less common for system-wide installs)
# This assumes the user running the script is the one who might have created these.
if [ -d "$HOME/.config/jellyfin" ]; then
    echo "   Removing user-specific config: $HOME/.config/jellyfin"
    rm -rf "$HOME/.config/jellyfin"
fi
if [ -d "$HOME/.local/share/jellyfin" ]; then
    echo "   Removing user-specific data: $HOME/.local/share/jellyfin"
    rm -rf "$HOME/.local/share/jellyfin"
fi

# 5. Remove the Jellyfin APT repository source file
echo "5. Removing Jellyfin APT repository source file..."
JELLYFIN_REPO_FILE="/etc/apt/sources.list.d/jellyfin.list"
if [ -f "$JELLYFIN_REPO_FILE" ]; then
    sudo rm "$JELLYFIN_REPO_FILE"
    echo "   Removed: $JELLYFIN_REPO_FILE"
else
    echo "   Jellyfin repository file not found at $JELLYFIN_REPO_FILE, continuing..."
fi

JELLYFIN_SOURCES_FILE="/etc/apt/sources.list.d/jellyfin.sources"
if [ -f "$JELLYFIN_SOURCES_FILE" ]; then
    sudo rm "$JELLYFIN_SOURCES_FILE"
    echo "   Removed: $JELLYFIN_SOURCES_FILE"
else
    echo "   Jellyfin sources file not found at $JELLYFIN_SOURCES_FILE, continuing..."
fi


# 6. Remove the Jellyfin GPG key
echo "6. Removing Jellyfin GPG key..."
JELLYFIN_GPG_KEY="/etc/apt/keyrings/jellyfin.gpg"
if [ -f "$JELLYFIN_GPG_KEY" ]; then
    sudo rm "$JELLYFIN_GPG_KEY"
    echo "   Removed: $JELLYFIN_GPG_KEY"
else
    echo "   Jellyfin GPG key not found at $JELLYFIN_GPG_KEY, continuing..."
fi

# 7. Update APT package lists to reflect changes
echo "7. Updating APT package lists..."
sudo apt update

echo "Jellyfin uninstallation complete."
echo "Your system should now be free of Jellyfin and its associated files."
