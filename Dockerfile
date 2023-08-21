# Use Arch Linux as base image
FROM archlinux:base

# Enabling multilib repo.
RUN \
if grep -q "\[multilib\]" /etc/pacman.conf; then \
  echo "Multilib repo already enabled"; \
else \
  echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf; \
fi

# Enabling Community repo.
RUN \
if grep -q "\[community\]" /etc/pacman.conf; then \
  echo "Community repo already enabled"; \
else \
  sudo sed -i '/^\[community\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf; \
fi

# Install blackarch repository signing key
RUN curl -O https://blackarch.org/strap.sh && \
    echo "Installing BlackArch keyring..." && \
    sudo bash strap.sh --noconfirm && \
    sudo pacman-key --init --noconfirm && \
    sudo pacman-key --populate --noconfirm archlinux blackarch && \
    sudo pacman -Fyy --noconfirm && \
    sudo pacman -Syyu --noconfirm

# Update and install necessary packages
RUN sudo pacman -S --noconfirm --needed base-devel archiso blackarch devtools dosfstools mtools

# Set locale to avoid issues with package installations
ENV LC_ALL=en_US.UTF-8

# Set up a non-root user
RUN useradd -m builder && echo "builder:builder" | chpasswd
USER builder

# Set the working directory
WORKDIR /home/builder

# Define the entrypoint
CMD ["/bin/bash"]

