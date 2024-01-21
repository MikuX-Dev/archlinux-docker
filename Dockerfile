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

RUN sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen && \
    locale-gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    echo 'KEYMAP=us' > /etc/vconsole.conf

# Update the system and install essential packages
RUN pacman -Syy --noconfirm --quiet --needed archlinux-keyring

RUN pacman -Syyu --noconfirm --quiet --needed reflector rsync curl wget base-devel devtools sudo git namcap fakeroot audit grep diffutils && \
    reflector --latest 21 -f 21 --protocol https --download-timeout 55 --sort rate --save /etc/pacman.d/mirrorlist && \
    pacman -Syy

# Add builder User
RUN useradd -m -d /home/builder -s /bin/bash -G wheel builder && \
    sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# chown user
RUN chown -R builder:builder /home/builder/

USER builder
WORKDIR /home/builder

ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/core_perl"

# chown user
RUN sudo chown -R builder:builder /home/builder/

# install yay
RUN \
    cd /home/builder && \
    curl -O -s https://aur.archlinux.org/cgit/aur.git/snapshot/yay-bin.tar.gz && \
    tar xf yay-bin.tar.gz && \
    cd yay-bin && makepkg -is --skippgpcheck --noconfirm && cd - && \
    rm -rf yay-bin && rm yay-bin.tar.gz

USER root

RUN chown -R builder:builder /home/builder/

RUN pacman -Scc --noconfirm

RUN pacman -Syy

RUN chown -R builder:builder /home/builder/

RUN pacman -Scc --noconfirm
