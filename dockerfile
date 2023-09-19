FROM mikuxdev/archlnux:latest
WORKDIR /root
SHELL ["/bin/sh", "-c"]

RUN pacman -Syyu --noconfirm

COPY ~/.zshrc .zshrc
COPY ~/.zsh_aliases .zsh_aliases
COPY ~/.zsh_history .zsh_history
COPY ~/Data-Linux/work/ work

FROM base
SHELL ["/bin/zsh", "-c"]
WORKDIR /root/work/
CMD ["/bin/zsh"]