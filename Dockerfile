# Use the Arch Linux base image with development tools
FROM archlinux:base-devel

# Install BlackArch keyring and configure pacman
RUN curl https://raw.githubusercontent.com/Athena-OS/package-source/main/packages/aegis/strap.sh -o strap.sh; chmod +x strap.sh; ./strap.sh; rm -rf strap.sh && \
    pacman -Syyu --noconfirm --quiet --needed

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
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    echo 'KEYMAP=us' > /etc/vconsole.conf

RUN pacman -Syy --noconfirm --quiet --needed reflector rsync curl wget && \
    reflector --latest 21 -f 21 --protocol https --download-timeout 55 --sort rate --save /etc/pacman.d/mirrorlist && \
    pacman -Syy 

RUN pacman -Syy base base-devel archiso devtools dosfstools mtools fakeroot fakechroot linux-firmware ntp git git-lfs docker docker-compose docker-buildx docker-scan docker-machine perl automake curl sed arch-install-scripts squashfs-tools libisoburn btrfs-progs lynx mkinitcpio-nfs-utils glibc nasm yasm yarn cargo ripgrep nodejs npm wget gzip curl neovim man-pages man-db vim zsh tmux ack xarchiver p7zip zip unzip gzip tar bzip3 unrar xz zstd f2fs-tools automake gawk gammu gnome-keyring multilib-devel npm make go lua perl ruby rust cmake gcc gcc-libs gdb ppp rp-pppoe pptpclient reiserfsprogs clang llvm ccache curl wget sed

# Add builder User
RUN useradd -m -d /home/user -s /bin/bash -G wheel user && \
    sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers && \
    echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# chown user
RUN chown -R user:user /home/user

USER user
WORKDIR /home/user

ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/core_perl"

# chown user
RUN sudo chown -R user:user /home/user

# install yay
RUN \
    cd /home/user && \
    curl -O -s https://aur.archlinux.org/cgit/aur.git/snapshot/yay-bin.tar.gz && \
    tar xf yay-bin.tar.gz && \
    cd yay-bin && makepkg -is --skippgpcheck --noconfirm && cd - && \
    rm -rf yay-bin && rm yay-bin.tar.gz

USER root

RUN chown -R user:user /home/user/

RUN pacman -Scc --noconfirm

RUN pacman -Syy
