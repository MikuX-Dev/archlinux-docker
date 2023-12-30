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
RUN pacman -Syyu --noconfirm --quiet --needed base-devel archiso mkinitcpio-archiso devtools

# Clean up the Pacman cache
RUN pacman -Scc --noconfirm --quiet && \
    rm -rf /var/cache/pacman/pkg/*

# Add builder User
RUN useradd -r -m -s /bin/bash -G wheel builder && \
    sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# chown user
RUN chown -R builder:builder /home/builder/

# Change to user builder
USER builder

# Set the working directory
WORKDIR /home/builder

# install yay which can be used to install AUR dependencies
RUN git clone https://aur.archlinux.org/yay-bin.git
RUN cd yay-bin && makepkg -scf --needed --noconfirm 
RUN cd ~/ && rm -rf yay-bin

ENTRYPOINT [ "./build.sh" ]
CMD [ "sh", "./build.sh" ]
