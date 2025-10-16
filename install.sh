#!/bin/bash
set -euo pipefail

# asana-cli installation script
# Usage: curl -fsSL https://raw.githubusercontent.com/tftio/asana-cli/main/install.sh | sh
# Or with custom install directory: INSTALL_DIR=/usr/local/bin curl ... | sh

TOOL_NAME="asana-cli"
REPO_OWNER="${REPO_OWNER:-tftio}"
REPO_NAME="${REPO_NAME:-asana-cli}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
GITHUB_API_URL="https://api.github.com"
GITHUB_DOWNLOAD_URL="https://github.com"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

detect_platform() {
    local os arch target

    case "$(uname -s)" in
        Linux*) os="unknown-linux-gnu" ;;
        Darwin*) os="apple-darwin" ;;
        MINGW*|MSYS*|CYGWIN*) os="pc-windows-msvc" ;;
        *)
            log_error "Unsupported operating system: $(uname -s)"
            exit 1
            ;;
    esac

    case "$(uname -m)" in
        x86_64|amd64) arch="x86_64" ;;
        aarch64|arm64) arch="aarch64" ;;
        *)
            log_error "Unsupported architecture: $(uname -m)"
            exit 1
            ;;
    esac

    target="${arch}-${os}"
    echo "$target"
}

get_latest_version() {
    local api_url="$GITHUB_API_URL/repos/$REPO_OWNER/$REPO_NAME/releases/latest"

    log_info "Fetching latest release information..."

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$api_url" | grep '"tag_name":' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/'
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- "$api_url" | grep '"tag_name":' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/'
    else
        log_error "Neither curl nor wget is available. Please install one of them."
        exit 1
    fi
}

download_and_verify() {
    local download_url="$1"
    local filename="$2"
    local temp_dir="$3"
    local version="$4"

    log_info "Downloading $filename..."

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$download_url" -o "$temp_dir/$filename"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$download_url" -O "$temp_dir/$filename"
    else
        log_error "Neither curl nor wget is available."
        exit 1
    fi

    local base_filename="${filename%.tar.gz}"
    base_filename="${base_filename%.zip}"
    local checksum_url="${GITHUB_DOWNLOAD_URL}/${REPO_OWNER}/${REPO_NAME}/releases/download/${version}/${base_filename}.sha256"
    local checksum_file="$temp_dir/${base_filename}.sha256"

    log_info "Downloading checksum file..."
    if command -v curl >/dev/null 2>&1; then
        if ! curl -fsSL "$checksum_url" -o "$checksum_file" 2>/dev/null; then
            log_error "Checksum file not available at: $checksum_url"
            log_error "Checksum verification is mandatory for security."
            exit 1
        fi
    else
        log_error "curl is required for checksum download."
        exit 1
    fi

    log_info "Verifying checksum..."
    local expected_hash
    expected_hash=$(cut -d' ' -f1 "$checksum_file")
    local actual_hash

    if command -v sha256sum >/dev/null 2>&1; then
        actual_hash=$(sha256sum "$temp_dir/$filename" | cut -d' ' -f1)
    elif command -v shasum >/dev/null 2>&1; then
        actual_hash=$(shasum -a 256 "$temp_dir/$filename" | cut -d' ' -f1)
    else
        log_error "No checksum utility available (sha256sum or shasum required)."
        log_error "Checksum verification is mandatory for security."
        exit 1
    fi

    if [ "$expected_hash" = "$actual_hash" ]; then
        log_success "Checksum verification passed"
    else
        log_error "Checksum verification failed!"
        log_error "Expected: $expected_hash"
        log_error "Actual:   $actual_hash"
        exit 1
    fi
}

extract_archive() {
    local archive_file="$1"
    local temp_dir="$2"

    case "$archive_file" in
        *.tar.gz|*.tgz)
            log_info "Extracting tar.gz archive..."
            tar -xzf "$temp_dir/$archive_file" -C "$temp_dir"
            ;;
        *.zip)
            log_info "Extracting zip archive..."
            if command -v unzip >/dev/null 2>&1; then
                unzip -q "$temp_dir/$archive_file" -d "$temp_dir"
            else
                log_error "unzip is not available. Please install unzip to extract the archive."
                exit 1
            fi
            ;;
        *)
            log_error "Unsupported archive format: $archive_file"
            exit 1
            ;;
    esac
}

check_existing_installation() {
    local install_path="$1"

    if [ -f "$install_path" ]; then
        if [ -t 0 ]; then
            echo -n "$(basename "$install_path") is already installed at $install_path. Replace it? [y/N]: "
            read -r response
            case "$response" in
                [yY]|[yY][eE][sS])
                    return 0
                    ;;
                *)
                    log_info "Installation cancelled by user"
                    exit 0
                    ;;
            esac
        else
            log_warn "$(basename "$install_path") already exists at $install_path, replacing..."
            return 0
        fi
    fi
}

main() {
    log_info "Installing $TOOL_NAME..."

    local target
    target=$(detect_platform)
    log_info "Detected target: $target"

    if [ ! -d "$INSTALL_DIR" ]; then
        log_info "Creating install directory: $INSTALL_DIR"
        mkdir -p "$INSTALL_DIR"
    fi

    local version
    version="${VERSION:-$(get_latest_version)}"
    if [ -z "$version" ]; then
        log_error "Failed to determine latest release. Set VERSION environment variable to override."
        exit 1
    fi
    log_info "Installing version: $version"

    local temp_dir
    temp_dir="$(mktemp -d)"
    trap 'rm -rf "$temp_dir"' EXIT

    local archive_ext="tar.gz"
    if [[ "$target" == *"windows"* ]]; then
        archive_ext="zip"
    fi

    local filename="${TOOL_NAME}-${target}.${archive_ext}"
    local download_url="${GITHUB_DOWNLOAD_URL}/${REPO_OWNER}/${REPO_NAME}/releases/download/${version}/${filename}"

    download_and_verify "$download_url" "$filename" "$temp_dir" "$version"
    extract_archive "$filename" "$temp_dir"

    local extracted_binary="$temp_dir/$TOOL_NAME"
    if [ ! -f "$extracted_binary" ]; then
        extracted_binary="$temp_dir/${TOOL_NAME}.exe"
    fi

    if [ ! -f "$extracted_binary" ]; then
        extracted_binary=$(find "$temp_dir" -maxdepth 2 -type f -name "$TOOL_NAME*" | head -n1)
    fi

    if [ ! -f "$extracted_binary" ]; then
        log_error "Could not locate extracted binary in archive."
        exit 1
    fi

    local install_path="$INSTALL_DIR/$TOOL_NAME"
    if [[ "$target" == *"windows"* ]]; then
        install_path="${install_path}.exe"
    fi

    check_existing_installation "$install_path"

    log_info "Installing to $install_path"
    install "$extracted_binary" "$install_path"

    log_success "$TOOL_NAME has been installed to $install_path"
    echo
    log_info "To uninstall, remove the binary:"
    echo "  rm -f \"$install_path\""
    echo
    log_info "Repository: https://github.com/${REPO_OWNER}/${REPO_NAME}"
}

main "$@"
