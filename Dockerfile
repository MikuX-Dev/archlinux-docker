FROM archlinux/archlinux

RUN \
if grep -q "\[multilib\]" /etc/pacman.conf; then \
  echo "Multilib repo already enabled"; \
else \
  echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf; \
fi

RUN \
if grep -q "\[community\]" /etc/pacman.conf; then \
  echo "Community repo already enabled"; \
else \
  sed -i '/^\[community\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf; \
fi

RUN curl -O https://blackarch.org/strap.sh && \
    bash strap.sh --noconfirm && \
    pacman -Fyy --noconfirm && \
    pacman -Syyu --noconfirm --needed archlinux-keyring blackarch-keyring

RUN pacman -S --noconfirm --needed base base-devel archiso blackarch devtools dosfstools mtools fakeroot fakechroot

ENV LC_ALL=en_US.UTF-8

RUN useradd -m builder && echo "builder:builder" | chpasswd
USER builder

WORKDIR /home/builder

CMD ["/bin/bash"]

