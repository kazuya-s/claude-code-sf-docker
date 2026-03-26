#!/bin/bash
set -e

CLAUDE_BIN="${HOME}/.local/bin/claude"
CLAUDE_VERSIONS_DIR="${HOME}/.local/share/claude/versions"

# If symlink is missing but a versioned binary exists in the volume, recreate the symlink
if [ ! -x "${CLAUDE_BIN}" ] && [ -d "${CLAUDE_VERSIONS_DIR}" ]; then
    latest=$(ls "${CLAUDE_VERSIONS_DIR}" 2>/dev/null | sort -V | tail -1)
    if [ -n "${latest}" ] && [ -x "${CLAUDE_VERSIONS_DIR}/${latest}" ]; then
        mkdir -p "${HOME}/.local/bin"
        ln -sf "${CLAUDE_VERSIONS_DIR}/${latest}" "${CLAUDE_BIN}"
        echo "[entrypoint] Linked Claude Code ${latest} from volume."
    fi
fi

# Install Claude Code if still not available (first start on a fresh machine)
if [ ! -x "${CLAUDE_BIN}" ]; then
    echo "[entrypoint] Claude Code not found. Installing..."
    curl -fsSL https://claude.ai/install.sh | bash
    echo "[entrypoint] Claude Code installed."
else
    echo "[entrypoint] Claude Code ready: $(${CLAUDE_BIN} --version 2>/dev/null || echo 'unknown version')"
fi

exec "$@"
