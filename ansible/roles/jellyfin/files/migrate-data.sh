#!/usr/bin/env bash
# One-time migration of a bare-metal Jellyfin install into the container volume layout.
#
# NON-DESTRUCTIVE: this only copies. It never deletes or modifies the originals
# at /var/lib/jellyfin or /etc/jellyfin.
#
# Official jellyfin/jellyfin image layout:
#   /config        <- data dir   (bare-metal /var/lib/jellyfin)
#   /config/config <- config dir (bare-metal /etc/jellyfin)
#   /cache         <- cache      (starts empty; transcodes regenerate here)
#
# Verify these paths against the image before trusting the mapping:
#   docker inspect jellyfin/jellyfin:latest --format '{{range .Config.Env}}{{println .}}{{end}}' | grep JELLYFIN
set -euo pipefail

JELLYFIN_HOME="${JELLYFIN_HOME:-$HOME/dev/tools/jellyfin}"
SRC_DATA="/var/lib/jellyfin"
SRC_CONFIG="/etc/jellyfin"
DST="$JELLYFIN_HOME/config"

echo "Source data:   $SRC_DATA"
echo "Source config: $SRC_CONFIG"
echo "Destination:   $DST (originals will NOT be touched)"
read -r -p "Proceed? [y/N] " reply
[ "$reply" = "y" ] || { echo "Aborted."; exit 1; }

sudo mkdir -p "$DST/config"

# Data dir -> /config. Exclude transcodes; those belong in /cache and regenerate.
sudo rsync -aH --info=progress2 --exclude 'transcodes/' "$SRC_DATA/" "$DST/"

# Config dir -> /config/config.
sudo rsync -aH --info=progress2 "$SRC_CONFIG/" "$DST/config/"

# The container cache is /cache, not /var/cache/jellyfin. Clear the stale temp
# path so Jellyfin falls back to the default under /cache.
enc="$DST/config/encoding.xml"
if [ -f "$enc" ]; then
  sudo sed -i 's#<TranscodingTempPath>[^<]*</TranscodingTempPath>#<TranscodingTempPath></TranscodingTempPath>#' "$enc"
fi

echo
echo "Copy complete. Originals remain at $SRC_DATA and $SRC_CONFIG."
echo "Next: set your media path in docker-compose.yaml, then start the container (see README)."
