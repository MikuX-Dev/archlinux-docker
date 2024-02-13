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
  # Install the primary key for chaotic-aur repository
  pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com && \
  pacman-key --lsign-key 3056513887B78AEB && \
  # Install chaotic-aur keyring and mirrorlist
  pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' && \
  pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

RUN \
if grep -q "\[chaotic-aur\]" /etc/pacman.conf; then \
  sed -i '/^\[chaotic-aur\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf; \
else \
  echo -e "[chaotic-aur]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf; \
fi

RUN sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen && \
    locale-gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    echo 'KEYMAP=us' > /etc/vconsole.conf

# Update the system and install essential packages
RUN pacman -Syy --noconfirm --quiet --needed archlinux-keyring

RUN pacman -Syyu --noconfirm --quiet --needed reflector rsync curl wget eza bc base-devel devtools sudo git namcap fakeroot audit grep diffutils base base-devel archiso devtools dosfstools mtools fakeroot fakechroot linux-firmware ntp git git-lfs docker docker-compose docker-buildx docker-scan docker-machine perl automake curl sed arch-install-scripts squashfs-tools libisoburn btrfs-progs lynx mkinitcpio-nfs-utils glibc nasm yeza bat yarn cargo ripgrep nodejs npm wget gzip curl neovim man-pages man-db vim zsh tmux ack xarchiver p7zip zip unzip gzip tar bzip3 unrar xz zstd f2fs-tools automake gawk gammu gnome-keyring multilib-devel npm make go lua perl ruby rust cmake gcc gcc-libs gdb ppp rp-pppoe pptpclient reiserfsprogs clang llvm ccache curl wget sed

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
    rm -rf yay-bin* && \
    yay -S paru powerpill rate-mirrors-bin --noconfirm --needed

RUN paru -Scc --noconfirm && yay -Scc --noconfirm && \
    paru -Syy

RUN \
# Download and install nerd-fonts
fonts_url="https://github.com/ryanoasis/nerd-fonts/releases/latest" \
font_files=("CascadiaCode.tar.xz" "JetBrainsMono.tar.xz" "RobotoMono.tar.xz") \
font_file_names=("CascadiaCode" "JetBrainsMono" "RobotoMono") \
for ((i = 0; i < ${#font_files[@]}; i++)); do \
  font_file=${font_files[i]} \
  font_name=${font_file_names[i]} \
  font_url=$(curl -sL ${fonts_url} | grep -o -E "https://.*${font_file}") \
  # Create a folder with the font name
  mkdir -p "${font_name}" \
  # Download and extract the font
  curl -L -o "${font_file}" "${font_url}" \
  tar -xvf "${font_file}" -C "${font_name}" \
  rm "${font_file}" \
  # Move the font folder to /usr/share/fonts/
  mv "${font_name}" $US/fonts/ \
done

USER root

RUN chown -R builder:builder /home/builder/
