FROM node:20-slim

RUN apt-get update && \
    apt-get install -y git curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI
RUN curl -fsSL https://claude.ai/install.sh | bash

# Create non-root user for Claude CLI (--dangerously-skip-permissions requires non-root)
RUN useradd -m appuser

# Copy Claude CLI binary to appuser's home (PATH will be set below after USER switch)
RUN cp -r /root/.local/bin /home/appuser/.local && \
    chown -R appuser:appuser /home/appuser/.local

# Clone bridge repo as appuser to avoid root-owned files
USER appuser
WORKDIR /app
RUN git clone https://github.com/brizenchi/openclaw-claude-bridge.git . && \
    npm install

# Skip onboarding (appuser's home)
RUN echo '{"hasCompletedOnboarding":true}' > /home/appuser/.claude.json
ENV CLAUDE_CODE_SKIP_ONBOARDING=1
ENV PATH="/home/appuser/.local/bin:${PATH}"

EXPOSE 3456 3458

CMD ["npm", "start"]
