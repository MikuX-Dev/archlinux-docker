# Use the Arch Linux base image with development tools
FROM archlinux:base-devel

# Set the shell to bash
SHELL ["/bin/bash"]

# Initialize and populate Pacman keyring
RUN pacman-key --init && \
    pacman-key --populate

# Enable multilib repository if not already enabled
RUN \
if grep -q "\[multilib\]" /etc/pacman.conf; then \
  sed -i '/^\[multilib\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf; \
else \
  echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf; \
fi

# Enable community repository if not already enabled
RUN \
if grep -q "\[community\]" /etc/pacman.conf; then \
  sed -i '/^\[community\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf; \
else \
  echo -e "[community]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf; \
fi

# Configure the locale settings
RUN sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen && \
    locale-gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set the keymap to US
RUN echo 'KEYMAP=us' > /etc/vconsole.conf

# Configure Pacman repositories
RUN curl https://raw.githubusercontent.com/MikuX-Dev/docker-archiso/main/blackarch-mirrorlist -o /etc/pacman.d/blackarch-mirrorlist && \
    sh -c "curl https://archlinux.org/mirrorlist/\?country=all\&protocol=http\&protocol=https\&ip_version=4\&ip_version=6\&use_mirror_status=on -o /etc/pacman.d/mirrorlist && sed -i 's/#S/S/g' /etc/pacman.d/mirrorlist"

# Install essential packages and update mirrors
RUN curl -O https://blackarch.org/strap.sh && \
    bash strap.sh --noconfirm --quiet && \
    rm -rf strap.sh && \
    pacman -Syyu --noconfirm --quiet --needed reflector rsync curl && \
    reflector --latest 10 -f 10 -n 10 --sort age --sort rate --save /etc/pacman.d/mirrorlist

# Install a comprehensive list of packages
RUN pacman -Syyu --noconfirm --quiet --needed base base-devel archiso mkinitcpio-archiso devtools dosfstools mtools \
    fakeroot fakechroot linux-firmware net-tools ntp git git-lfs docker docker-compose docker-buildx docker-scan docker-machine gcc \
    perl automake curl sed arch-install-scripts squashfs-tools libisoburn btrfs-progs lynx mkinitcpio-nfs-utils glibc \
    nasm yasm yarn cargo bash ripgrep nodejs npm wget gzip curl neovim man-pages man-db vim zsh tmux ack xarchiver p7zip zip \
    unzip gzip tar bzip3 unrar xz zstd archiso f2fs-tools automake gawk gammu gnome-keyring mtools dosfstools devtools multilib-devel npm \
    qemu-tools qemu-emulators-full qemu-system-x86-firmware cargo make go lua perl ruby rust rustup cmake gcc gcc-libs gdb ppp \
    rp-pppoe pptpclient reiserfsprogs clang llvm ccache curl wget sed zsh zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting \
    zsh-completions bash-completion xdg-user-dirs-gtk xdg-desktop-portal-gtk openssh gnupg arch-wiki-docs pkgfile intel-ucode ntfs-3g \
    base smartmontools base-devel linux-lts-docs linux-hardened-docs gvfs-mtp gvfs apache udisks2 cronie irqbalance plocate arch-install-scripts \
    bind brltty broadcom-wl clonezilla darkhttpd diffutils dmraid dnsmasq edk2-shell profile-sync-daemon pacman-contrib pkgfile hexedit

# Clean up the Pacman cache
RUN pacman -Scc --noconfirm --quiet && \
    rm -rf /var/cache/pacman/pkg/*