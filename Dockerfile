# Use the Arch Linux base image with development tools
FROM archlinux:base-devel

RUN pacman-key --init && \
    pacman-key --populate

RUN \
if grep -q "\[multilib\]" /etc/pacman.conf; then \
  sed -i '/^\[multilib\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf; \
else \
  echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf; \
fi

RUN \
if grep -q "\[community\]" /etc/pacman.conf; then \
  sed -i '/^\[community\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf; \
else \
  echo -e "[community]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf; \
fi

RUN sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen && \
    locale-gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf

RUN echo 'KEYMAP=us' > /etc/vconsole.conf

# Update the system and install essential packages
RUN pacman -Syy --noconfirm --quiet --needed archlinux-keyring

# Initialize and populate Pacman keyring
RUN pacman-key --init && \
    pacman-key --populate

RUN pacman -Syy --noconfirm --quiet --needed reflector rsync curl wget && \
    reflector --latest 10 -f 10 -n 10 --age 10 --protocol https --download-timeout 25 --sort rate --save /etc/pacman.d/mirrorlist && \
    pacman -Syy

# Install BlackArch keyring and configure pacman
# RUN curl -O https://blackarch.org/strap.sh && \
    # bash strap.sh --noconfirm --quiet && \
    # rm -rf strap.sh && \
    # pacman -Syyu --noconfirm --quiet --needed

# Install a comprehensive list of packages
RUN pacman -Syyu --noconfirm --quiet --needed base base-devel archiso mkinitcpio-archiso devtools dosfstools mtools \
    fakeroot fakechroot linux-firmware net-tools ntp git git-lfs docker docker-compose docker-buildx docker-scan docker-machine gcc \
    perl automake curl sed arch-install-scripts squashfs-tools libisoburn btrfs-progs lynx mkinitcpio-nfs-utils glibc \
    nasm yasm yarn cargo bash ripgrep nodejs npm wget gzip curl neovim man-pages man-db vim zsh tmux ack xarchiver p7zip zip \
    unzip gzip tar bzip3 unrar xz zstd f2fs-tools automake gawk gammu gnome-keyring mtools dosfstools devtools multilib-devel npm \
    make go lua perl ruby rust rustup cmake gcc gcc-libs gdb ppp rp-pppoe pptpclient reiserfsprogs clang llvm ccache curl wget sed

# firmware
RUN git clone https://aur.archlinux.org/pikaur.git && \
   cd pikaur && \
   makepkg -si --noconfirm --needed && \
   cd .. && rm -rf pikaur && \
   pikaur -S --needed --noconfirm mkinitcpio-firmware

# Clean up the Pacman cache
RUN pacman -Scc --noconfirm --quiet && \
    rm -rf /var/cache/pacman/pkg/*

# Create builder user
RUN useradd -m builder && \
    echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Change to user builder
USER builder

# Command to run build
ENTRYPOINT ["bash"]
