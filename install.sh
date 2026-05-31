#!/usr/bin/env bash
#
# CockpitServerAI - Automatic Compilation-free Installer
# Installs the pre-built AI-powered terminal assistant into Cockpit system-wide or per-user.
#
set -euo pipefail

# Curated shades of purple for the installer theme
GREEN='\033[38;5;177m'  # Lilac / Light Lavender (Success & highlights)
BLUE='\033[38;5;99m'    # Medium Purple / Violet (Headers, steps, & info)
YELLOW='\033[38;5;213m' # Soft Orchid / Light Pink-Purple (Warnings & commands)
RED='\033[38;5;161m'    # Intense Magenta / Berry (Errors)
NC='\033[0m'            # No Color

echo -e "${BLUE}====================================================${NC}"
echo -e "${GREEN}       Installing Cockpit AI Agent System-Wide       ${NC}"
echo -e "${BLUE}====================================================${NC}"

# 1. Determine target directory based on user privileges
# Check if COCKPIT_DIR is already defined by the user
if [ -n "${COCKPIT_DIR:-}" ]; then
    INSTALL_DIR="${COCKPIT_DIR}"
    echo -e "Using custom installation directory: ${BLUE}${INSTALL_DIR}${NC}"
else
    # Default to system-wide if run as root, otherwise local user directory
    if [ "$EUID" -eq 0 ]; then
        INSTALL_DIR="/usr/share/cockpit/cockpit-ai-agent"
        echo -e "Running as root. Target: ${BLUE}${INSTALL_DIR}${NC} (System-Wide)"
    else
        INSTALL_DIR="${HOME}/.local/share/cockpit/cockpit-ai-agent"
        echo -e "Running as regular user. Target: ${BLUE}${INSTALL_DIR}${NC} (User-Local)"
    fi
fi

# 2. Check for required system commands
for cmd in curl tar; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${RED}Error: Required command '${cmd}' is not installed.${NC}"
        echo -e "Please install '${cmd}' and run this script again."
        exit 1
    fi
done

# 3. Determine latest release from GitHub API
REPO="ShaoRou459/CockpitServerAI"
echo -e "${BLUE}[1/4]${NC} Querying GitHub API for the latest release..."

# Fetch the release JSON
RELEASE_JSON=$(curl -sS "https://api.github.com/repos/${REPO}/releases/latest" || true)

if [ -z "$RELEASE_JSON" ] || echo "$RELEASE_JSON" | grep -q "Not Found"; then
    echo -e "${YELLOW}Warning: Could not fetch latest release from GitHub API.${NC}"
    echo -e "This might be due to API rate limits or a private repository."
    echo -e "Attempting to scrape the latest tag from the GitHub page..."
    
    # Fallback to scraping the latest release tag
    TAG_NAME=$(curl -sSL "https://github.com/ShaoRou459/CockpitServerAI/releases" | grep -oE '/releases/tag/[^"]+' | head -n 1 | cut -d'/' -f3 || true)
    
    if [ -z "$TAG_NAME" ]; then
        # Hardcoded fallback as a last resort
        TAG_NAME="1.0.0"
        echo -e "${YELLOW}Fallback to default version: ${TAG_NAME}${NC}"
    else
        echo -e "Found scraped release tag: ${GREEN}${TAG_NAME}${NC}"
    fi
else
    # Parse tag name using grep/tr since jq might not be installed on target machine
    TAG_NAME=$(echo "$RELEASE_JSON" | grep -Po '"tag_name": *\K"[^"]*"' | tr -d '"' || true)
    
    if [ -z "$TAG_NAME" ]; then
        TAG_NAME="1.0.0"
        echo -e "${YELLOW}Could not parse tag from JSON. Fallback: ${TAG_NAME}${NC}"
    else
        echo -e "Found latest release tag: ${GREEN}${TAG_NAME}${NC}"
    fi
fi

# 4. Download pre-compiled assets
TMP_DIR=$(mktemp -d)
TARBALL_URL="https://github.com/ShaoRou459/CockpitServerAI/releases/download/${TAG_NAME}/cockpit-ai-agent-${TAG_NAME}.tar.xz"

# Cleanup temporary folder on exit
trap 'rm -rf "$TMP_DIR"' EXIT

echo -e "${BLUE}[2/4]${NC} Downloading pre-compiled assets..."
echo -e "URL: ${BLUE}${TARBALL_URL}${NC}"

if ! curl -sSL --fail -o "${TMP_DIR}/dist.tar.xz" "$TARBALL_URL"; then
    echo -e "${RED}Error: Failed to download the release asset.${NC}"
    echo -e "Please verify that 'cockpit-ai-agent-dist.tar.xz' is uploaded as a release asset for version ${TAG_NAME}."
    echo -e "If this is a new repository, make sure a release tag has been created and the workflow ran successfully."
    exit 1
fi

# 5. Prepare installation target directory
echo -e "${BLUE}[3/4]${NC} Preparing target directory..."
if [ -d "$INSTALL_DIR" ]; then
    BACKUP_PATH="${INSTALL_DIR}.bak-$(date +%Y%m%d%H%M%S)"
    echo -e "${YELLOW}Existing installation found at ${INSTALL_DIR}.${NC}"
    echo -e "Creating backup at ${BLUE}${BACKUP_PATH}${NC}"
    mv "$INSTALL_DIR" "$BACKUP_PATH"
fi

mkdir -p "$INSTALL_DIR"

# 6. Extract pre-compiled assets
echo -e "${BLUE}[4/4]${NC} Extracting assets into place..."
if ! tar -xJf "${TMP_DIR}/dist.tar.xz" -C "$INSTALL_DIR"; then
    echo -e "${RED}Error: Failed to extract tarball contents.${NC}"
    # Restore backup if it exists
    if [ -d "${BACKUP_PATH:-}" ]; then
        echo -e "Restoring backup..."
        rm -rf "$INSTALL_DIR"
        mv "$BACKUP_PATH" "$INSTALL_DIR"
    fi
    exit 1
fi

# Set appropriate system permissions (only if run as root, else keep user ownership)
if [ "$EUID" -eq 0 ]; then
    echo -e "Setting system permissions (root:root)..."
    chown -R root:root "$INSTALL_DIR"
fi

find "$INSTALL_DIR" -type d -exec chmod 755 {} \;
find "$INSTALL_DIR" -type f -exec chmod 644 {} \;

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}✓ Cockpit AI Agent successfully installed!${NC}"
echo -e "${BLUE}====================================================${NC}"
echo -e "You can now access the AI Agent in Cockpit (https://<your-server-ip>:9090)."
echo -e "If the plugin does not appear in the sidebar, refresh your browser or reload Cockpit:"
echo
if [ "$EUID" -eq 0 ]; then
    echo -e "  ${YELLOW}sudo systemctl daemon-reload && sudo systemctl restart cockpit.socket${NC}"
else
    echo -e "  Since you installed locally as a non-root user, make sure your user has"
    echo -e "  appropriate permissions to access Cockpit."
fi
echo
