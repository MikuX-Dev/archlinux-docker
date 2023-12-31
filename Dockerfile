# Use the Arch Linux base image with development tools
FROM archlinux:base-devel

RUN pacman-key --init

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
    reflector --latest 21 -f 21 -n 21 --age 21 --protocol https --download-timeout 55 --sort rate --save /etc/pacman.d/mirrorlist && \
    pacman -Syy

# Add builder User
RUN useradd -r -m -s /bin/bash -G wheel builder && \
    sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# chown user
RUN chown -R builder:builder /home/builder/
RUN chown -R builder:builder /github/home

USER builder
WORKDIR /home/builder

# chown user
RUN sudo chown -R builder:builder /home/builder/

# install yay which can be used to install AUR dependencies
RUN git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -scf --needed --noconfirm && cd ~/ && rm -rf yay-bin

RUN yay -Syy mkinitcpio-firmware --noconfirm --needed
RUN yay -Scc --noconfirm

# chown user
RUN sudo chown -R builder:builder /home/builder/

# RUN su -m builder -c "./pkg-aur.sh"
ENTRYPOINT [ "./pkg-aur.sh" ]
