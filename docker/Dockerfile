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
    jq \
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

# ---- mise (version manager) ----
RUN curl https://mise.run | sh
ENV PATH="/home/${USERNAME}/.local/share/mise/shims:/home/${USERNAME}/.local/bin:${PATH}"

# ---- Node.js via mise ----
RUN mise use -g node@lts

# ---- Salesforce CLI ----
RUN npm install -g @salesforce/cli

# ---- JDK via mise ----
RUN mise use -g java@temurin-21

RUN mkdir -p /home/${USERNAME}/.config/claude && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.config

# ---- entrypoint: installs Claude Code on first start (persisted via volume) ----
COPY --chown=${USERNAME}:${USERNAME} entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# ---- zsh config ----
WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["zsh"]
