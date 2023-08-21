FROM archlinux/archlinux

RUN if grep -q "\[multilib\]" /etc/pacman.conf; then \
    sed -i '/^\[multilib\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf; \
else \
    echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf; \
fi

RUN if grep -q "\[community\]" /etc/pacman.conf; then \
    sed -i '/^\[community\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf; \
else \
    echo -e "[community]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf; \
fi

RUN sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen && \
    locale-gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf

RUN sed -i 's/#KEYMAP=us/KEYMAP=us/g' /etc/vconsole.conf

RUN pacman -Syyu --noconfirm --quiet --needed pacman-contrib && \
    curl -O https://blackarch.org/strap.sh && \
    bash strap.sh --noconfirm --quiet && \
    pacman -Fyy --noconfirm --quiet && \
    pacman -Syyu --noconfirm --quiet archlinux-keyring blackarch-keyring && \
    pacman -S --noconfirm --quiet --needed base base-devel archiso mkinitcpio-archiso blackarch devtools dosfstools mtools fakeroot fakechroot

RUN useradd -m builder && echo "builder:builder" | chpasswd
USER builder

WORKDIR /home/builder

CMD ["/bin/bash"]
