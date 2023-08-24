FROM archlinux:base-devel

RUN set -xe; \
    useradd -m --shell=/bin/false build; \
    usermod -L build; \
    echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers; 

USER build

WORKDIR /home/build/

RUN sudo pacman-key --init && \
    sudo pacman-key --populate 

RUN \ 
if grep -q "\[multilib\]" /etc/pacman.conf; then \
  sudo sed -i '/^\[multilib\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf; \
else \
  sudo echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf; \
fi

RUN \ 
if grep -q "\[community\]" /etc/pacman.conf; then \
  sudo sed -i '/^\[community\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf; \
else \
  sudo echo -e "[community]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf; \
fi

RUN RUN sudo sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen && \
    sudo locale-gen && \
    echo "LANG=en_US.UTF-8" | sudo tee /etc/locale.conf > /dev/null

RUN sudo echo 'KEYMAP=us' > /etc/vconsole.conf

RUN sudo curl https://raw.githubusercontent.com/MikuX-Dev/docker-archiso/main/blackarch-mirrorlist -o /etc/pacman.d/blackarch-mirrorlist && \
    sudo sh -c "curl https://archlinux.org/mirrorlist/\?country=all\&protocol=http\&protocol=https\&ip_version=4\&ip_version=6\&use_mirror_status=on -o /etc/pacman.d/mirrorlist && sed -i 's/#S/S/g' /etc/pacman.d/mirrorlist"

RUN sudo curl -O https://blackarch.org/strap.sh && \
    sudo bash strap.sh --noconfirm --quiet 

RUN sudo pacman -Fyy --noconfirm --quiet && \
    sudo pacman -Syy --noconfirm --quiet archlinux-keyring blackarch-keyring

RUN sudo pacman -Syyu --noconfirm --quiet --needed base base-devel archiso mkinitcpio-archiso devtools dosfstools mtools \
    fakeroot fakechroot linux-firmware net-tools ntp git docker docker-compose docker-buildx docker-scan docker-machine gcc \
    perl automake curl sed arch-install-scripts squashfs-tools libisoburn btrfs-progs lynx mkinitcpio-nfs-utils 

RUN sudo pacman -Scc --noconfirm --quiet

CMD ["/bin/bash"]
