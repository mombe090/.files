#!/usr/bin/env bash
# Install Docker Engine on Ubuntu only
set -e

# Path resolution - Script is at: _scripts/unix/installers/ — 3 levels up to repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Source Unix libraries
source "$DOTFILES_ROOT/_scripts/unix/lib/init.sh"

# ===== OS DETECTION =====
check_os() {
    if [[ ! -f /etc/os-release ]]; then
        log_error "Cannot detect OS. /etc/os-release not found."
        exit 1
    fi

    source /etc/os-release

    if [[ "$ID" != "ubuntu" ]]; then
        log_error "This script only supports Ubuntu."
        log_error "Detected OS: $ID $VERSION_ID"
        log_info "For other distributions, visit: https://docs.docker.com/engine/install/"
        exit 1
    fi

    # Check Ubuntu version
    case "$VERSION_ID" in
        25.10|25.04|24.04|22.04)
            log_info "Detected: Ubuntu $VERSION_ID ($VERSION_CODENAME)"
            ;;
        *)
            log_warn "Ubuntu $VERSION_ID is not officially tested."
            log_warn "Officially supported versions: 25.10, 25.04, 24.04 (LTS), 22.04 (LTS)"
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
            ;;
    esac
}

# ===== CHECK IF DOCKER IS ALREADY INSTALLED =====
check_existing_docker() {
    if command -v docker &> /dev/null; then
        log_warn "Docker is already installed: $(docker --version)"
        read -p "Reinstall Docker? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping Docker installation."
            exit 0
        fi
    fi
}

# ===== UNINSTALL CONFLICTING PACKAGES =====
uninstall_conflicting_packages() {
    log_step "Removing conflicting packages..."

    local conflicting_packages=(
        "docker.io"
        "docker-compose"
        "docker-compose-v2"
        "docker-doc"
        "podman-docker"
        "containerd"
        "runc"
    )

    local installed_packages=()
    for pkg in "${conflicting_packages[@]}"; do
        if dpkg -l | grep -q "^ii.*$pkg"; then
            installed_packages+=("$pkg")
        fi
    done

    if [[ ${#installed_packages[@]} -eq 0 ]]; then
        log_info "No conflicting packages found."
        return 0
    fi

    log_warn "Found conflicting packages: ${installed_packages[*]}"
    sudo apt-get remove -y "${installed_packages[@]}" 2>/dev/null || true
    log_success "Conflicting packages removed."
}

# ===== SET UP DOCKER APT REPOSITORY =====
setup_docker_repository() {
    log_step "Setting up Docker apt repository..."

    # Install prerequisites
    log_info "Installing prerequisites..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl

    # Create keyrings directory
    sudo install -m 0755 -d /etc/apt/keyrings

    # Download Docker GPG key
    log_info "Downloading Docker GPG key..."
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add Docker repository
    log_info "Adding Docker repository..."
    source /etc/os-release
    sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME:-$VERSION_CODENAME}
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    # Update apt cache
    sudo apt-get update

    log_success "Docker repository configured."
}

# ===== INSTALL DOCKER ENGINE =====
install_docker() {
    log_step "Installing Docker Engine..."

    sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin

    log_success "Docker Engine installed."
}

# ===== START DOCKER SERVICE =====
start_docker_service() {
    log_step "Starting Docker service..."

    sudo systemctl enable docker
    sudo systemctl start docker

    # Verify Docker is running
    if sudo systemctl is-active --quiet docker; then
        log_success "Docker service is running."
    else
        log_warn "Docker service failed to start. Trying manual start..."
        sudo systemctl start docker
    fi
}

# ===== VERIFY INSTALLATION =====
verify_installation() {
    log_step "Verifying Docker installation..."

    # Check Docker version
    log_info "Docker version: $(docker --version)"
    log_info "Docker Compose version: $(docker compose version)"

    # Run hello-world
    log_info "Running hello-world container..."
    if sudo docker run --rm hello-world &> /dev/null; then
        log_success "Docker is working correctly!"
    else
        log_error "Docker hello-world test failed."
        exit 1
    fi
}

# ===== CONFIGURE NON-ROOT ACCESS (OPTIONAL) =====
configure_non_root_access() {
    log_step "Configuring non-root Docker access..."

    # Check if docker group exists
    if ! getent group docker > /dev/null; then
        log_info "Creating docker group..."
        sudo groupadd docker
    fi

    # Add current user to docker group
    if groups "$USER" | grep -q '\bdocker\b'; then
        log_info "User '$USER' is already in the docker group."
    else
        log_info "Adding user '$USER' to docker group..."
        sudo usermod -aG docker "$USER"
        log_warn "You need to log out and back in for group changes to take effect."
        log_warn "Or run: newgrp docker"
    fi
}

# ===== SHOW POST-INSTALL INFO =====
show_post_install_info() {
    echo ""
    log_success "Docker installation complete!"
    echo ""
    echo -e "${BOLD}Next steps:${NC}"
    echo "  1. Log out and back in (or run 'newgrp docker') to use Docker without sudo"
    echo "  2. Test Docker: docker run hello-world"
    echo "  3. Check status: systemctl status docker"
    echo ""
    echo -e "${BOLD}Useful commands:${NC}"
    echo "  docker --version          - Show Docker version"
    echo "  docker compose version    - Show Docker Compose version"
    echo "  docker ps                 - List running containers"
    echo "  docker images             - List images"
    echo ""
    echo -e "${BOLD}Documentation:${NC}"
    echo "  https://docs.docker.com/engine/install/linux-postinstall/"
    echo ""
}

# ===== MAIN =====
main() {
    log_info "Docker Engine Installation for Ubuntu"
    echo ""

    check_os
    check_existing_docker
    uninstall_conflicting_packages
    setup_docker_repository
    install_docker
    start_docker_service
    verify_installation
    configure_non_root_access
    show_post_install_info
}

main "$@"
