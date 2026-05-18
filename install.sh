#!/usr/bin/env bash
set -euo pipefail

reset="\e[0m"
bold="\e[1m"

red="\e[31m"
green="\e[32m"
yellow="\e[33m"
blue="\e[34m"
magenta="\e[35m"
cyan="\e[36m"

log() {
    echo -e "\n${cyan}==>${reset} ${bold}$1${reset}"
}

ok() {
    echo -e "${green}[ok]${reset} $1"
}

warn() {
    echo -e "${yellow}[!]${reset} $1"
}

fail() {
    echo -e "${red}[error]${reset} $1"
}

clear_screen() {
    if command -v clear >/dev/null 2>&1; then
        clear
    else
        printf "\033[2J\033[H"
    fi
}

pause() {
    echo
    read -rp "press enter to return to menu..."
}

check_fedora() {
    if [[ ! -f /etc/fedora-release ]]; then
        fail "this does not look like fedora. exiting."
        exit 1
    fi
}

show_menu() {
    clear_screen
    echo -e "${magenta}=========================${reset}"
    echo -e "${bold}${magenta}          uokik          ${reset}"
    echo -e "${magenta}=========================${reset}"
    echo
    echo -e "${green}1)${reset} basic ${yellow}(dev + brave + vscodium)${reset}"
    echo -e "${green}2)${reset} dev ${yellow}(go, python, node, java, build tools)${reset}"
    echo -e "${green}3)${reset} brave"
    echo -e "${green}4)${reset} vscodium"
    echo -e "${green}5)${reset} desktop ${yellow}(flatpak, discord, vlc, localsend, flatseal)${reset}"
    echo -e "${red}0)${reset} exit"
    echo
}

setup_flatpak() {
    log "installing flatpak and adding flathub"

    sudo dnf install -y flatpak

    flatpak remote-add --if-not-exists flathub \
        https://flathub.org/repo/flathub.flatpakrepo

    ok "flatpak ready"
}

install_desktop() {
    log "installing desktop apps"

    setup_flatpak

    flatpak install -y flathub \
        com.discordapp.Discord \
        com.github.tchx84.Flatseal \
        org.videolan.VLC \
        org.localsend.localsend_app

    ok "desktop apps installed"
}

install_dev() {
    log "installing dev tools"

    sudo dnf install -y \
        golang \
        python3 \
        python3-pip \
        python3-virtualenv \
        gcc \
        gcc-c++ \
        make \
        cmake \
        just \
        nodejs \
        npm \
        java-latest-openjdk

    ok "dev tools installed"
}

install_brave() {
    log "installing brave"

    sudo dnf install -y dnf-plugins-core
    sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    sudo dnf install -y brave-browser

    ok "brave installed"
}

install_vscodium() {
    log "installing vscodium"

    sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg

    sudo tee /etc/yum.repos.d/vscodium.repo > /dev/null <<'EOF'
[gitlab.com_paulcarroty_vscodium_repo]
name=download.vscodium.com
baseurl=https://download.vscodium.com/rpms/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
metadata_expire=1h
EOF

    sudo dnf install -y codium

    ok "vscodium installed"
}

install_basic() {
    log "installing basic setup"

    sudo dnf upgrade --refresh -y
    install_dev
    install_brave
    install_vscodium

    ok "basic setup done"
}

main() {
    check_fedora

    while true; do
        show_menu
        read -rp "choose option: " choice

        case "$choice" in
            1)
                install_basic
                pause
                ;;
            2)
                install_dev
                pause
                ;;
            3)
                install_brave
                pause
                ;;
            4)
                install_vscodium
                pause
                ;;
            5)
                install_desktop
                pause
                ;;
            0)
                echo "bye."
                exit 0
                ;;
            *)
                warn "invalid option."
                sleep 1
                ;;
        esac
    done
}

main "$@"
