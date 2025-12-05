# Install all base packages
mapfile -t packages < <(grep -v '^#' "./delete_unwanted.packages" | grep -v '^$')
sudo pacman -S --noconfirm --delete "${packages[@]}"
