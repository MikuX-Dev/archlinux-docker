FROM archlinux/base:latest
WORKDIR /root
SHELL ["/bin/sh", "-c"]

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

RUN curl https://raw.githubusercontent.com/MikuX-Dev/docker-archiso/main/blackarch-mirrorlist -o /etc/pacman.d/blackarch-mirrorlist && \
    sh -c "curl https://archlinux.org/mirrorlist/\?country=all\&protocol=http\&protocol=https\&ip_version=4\&ip_version=6\&use_mirror_status=on -o /etc/pacman.d/mirrorlist && sed -i 's/#S/S/g' /etc/pacman.d/mirrorlist"

RUN curl -O https://blackarch.org/strap.sh && \
    bash strap.sh --noconfirm --quiet && \
    rm -rf strap.sh

RUN pacman -Syyu --noconfirm --quiet

RUN pacman -Syyu --noconfirm --quiet --needed base base-devel archiso mkinitcpio-archiso devtools dosfstools mtools \
    fakeroot fakechroot linux-firmware net-tools ntp git docker docker-compose docker-buildx docker-scan docker-machine gcc \
    perl automake curl sed arch-install-scripts squashfs-tools libisoburn btrfs-progs lynx mkinitcpio-nfs-utils glibc \
    nasm yasm yarn cargo bash ripgrep nodejs npm wget gzip curl neovim man-pages man-db vim zsh

RUN pacman -Scc --noconfirm --quiet && \
    rm -rf /var/cache/pacman/pkg/*

COPY .zshrc .zshrc
COPY .zsh_aliases .zsh_aliases
COPY .zsh_history .zsh_history
COPY work work

FROM base
SHELL ["/bin/zsh", "-c"]
WORKDIR /root/work/
CMD ["/bin/zsh"]