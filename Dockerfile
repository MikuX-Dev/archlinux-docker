FROM archlinux:base-devel

#ENV work=$HOME/iso_build/
#ENV out=$HOME/iso_out/
#ENV iso=$HOME/iso/ 

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

RUN curl -O https://blackarch.org/strap.sh && \
    bash strap.sh --noconfirm --quiet && \
    rm -rf strap.sh && \
    pacman-key --init && \
    pacman-key --populate archlinux-keyring blackarch-keyring && \
    pacman -Syyu --noconfirm --quiet 

RUN curl https://raw.githubusercontent.com/MikuX-Dev/docker-archiso/main/blackarch-mirrorlist -o /etc/pacman.d/blackarch-mirrorlist && \
    sh -c "curl https://archlinux.org/mirrorlist/\?country=all\&protocol=http\&protocol=https\&ip_version=4\&ip_version=6\&use_mirror_status=on -o /etc/pacman.d/mirrorlist && sed -i 's/#S/S/g' /etc/pacman.d/mirrorlist"

RUN pacman -Syy --noconfirm --quiet --needed base base-devel archiso mkinitcpio mkinitcpio-archiso devtools dosfstools mtools \
    fakeroot fakechroot linux-firmware net-tools ntp git docker docker-compose docker-buildx docker-scan docker-machine gcc \
    perl automake curl sed arch-install-scripts squashfs-tools libisoburn btrfs-progs lynx mkinitcpio-nfs-utils glibc systemd

RUN pacman -Scc --noconfirm --quiet && \
    rm -rf /var/cache/pacman/pkg/* 

RUN useradd -m -d /iso -G wheel -g users builder -s /bin/bash && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER builder

WORKDIR /src

COPY --chown=builder:users . .

CMD ["/bin/bash"]
