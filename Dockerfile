FROM node:20-slim

RUN apt-get update && \
    apt-get install -y git curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/root/.local/bin:${PATH}"

# Clone and install bridge
WORKDIR /app
RUN git clone https://github.com/brizenchi/openclaw-claude-bridge.git . && \
    npm install

# Skip onboarding
RUN echo '{"hasCompletedOnboarding":true}' > /root/.claude.json
ENV CLAUDE_CODE_SKIP_ONBOARDING=1

# Create non-root user for Claude CLI (--dangerously-skip-permissions requires non-root)
RUN useradd -m appuser

EXPOSE 3456 3458

USER appuser

CMD ["npm", "start"]
