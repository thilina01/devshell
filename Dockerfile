# Stage 1: Nano-Specific Version
FROM alpine:latest AS nano

# Install Nano and its dependencies
RUN apk update && apk add --no-cache \
    git \
    nano \
    fontconfig \
    && rm -rf /var/cache/apk/*

# Enhance Nano with syntax highlighting
RUN git clone https://github.com/scopatz/nanorc.git /root/.nano \
    && echo "include /root/.nano/*.nanorc" >> /root/.nanorc

# Set /data as a default working directory for editing
WORKDIR /data

# Set Nano-specific shell
CMD ["nano"]

# Stage 2: Full DevShell Version
FROM nano AS devshell

# Install additional tools for DevShell
RUN apk add --no-cache \
    zsh \
    tmux \
    bat \
    curl \
    wget \
    && rm -rf /var/cache/apk/*

# Install Oh My Zsh
RUN sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" --unattended

# Install plugins for Oh My Zsh
RUN git clone https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Set up .zshrc with Oh My Zsh and plugins
RUN echo "export ZSH=/root/.oh-my-zsh" > /root/.zshrc && \
    echo "source /root/.oh-my-zsh/oh-my-zsh.sh" >> /root/.zshrc && \
    echo "ZSH_THEME=\"robbyrussell\"" >> /root/.zshrc && \
    echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting)" >> /root/.zshrc && \
    echo "autoload -U compinit && compinit" >> /root/.zshrc && \
    echo "export TERM=xterm-256color" >> /root/.zshrc

# Force Zsh to source .zshrc on startup
RUN echo "source /root/.zshrc" >> /root/.zshenv

# Set Zsh as the default shell
CMD ["/bin/zsh"]

# docker build --target nano -t thilina01/devshell:nano .
# docker build -t thilina01/devshell:nano .

# docker image ls thilina01/devshell:latest
# docker image ls thilina01/devshell:nano

# docker push thilina01/devshell:latest
# docker push thilina01/devshell:nano

# docker run -it --rm thilina01/devshell:latest
# docker run -it --rm thilina01/devshell:nano

# docker run --rm -it -v openresty_config:/data thilina01/devshell:latest
# docker run --rm -it -v openresty_config:/data thilina01/devshell:nano sh -c "nano system_config.json"