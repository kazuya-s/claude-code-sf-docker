FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# ---- base packages ----
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    zsh \
    fzf \
    vim \
    locales \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# ---- locale (UTF-8) ----
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# ---- UID / GID sync ----
ARG USERNAME=claude
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid ${USER_GID} --non-unique ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/zsh ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# ---- Claude Code (always latest at build time) ----
RUN curl -fsSL https://claude.ai/install.sh | bash

ENV PATH="/home/${USERNAME}/.local/bin:${PATH}"

# ---- zsh config ----
COPY zshrc /home/${USERNAME}/.zshrc

WORKDIR /workspace
CMD ["zsh"]