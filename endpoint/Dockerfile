FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
      openssh-server \
      openssh-client \
      curl \
      ca-certificates \
      gnupg \
      procps \
      iproute2 \
      rsyslog && \
    mkdir -p /run/sshd && \
    curl -fsSL https://packages.wazuh.com/key/GPG-KEY-WAZUH \
      | gpg --dearmor -o /usr/share/keyrings/wazuh.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" \
      > /etc/apt/sources.list.d/wazuh.list && \
    apt-get update && \
    WAZUH_MANAGER="wazuh.manager" \
    WAZUH_AGENT_NAME="security-endpoint-01" \
      apt-get install -y wazuh-agent && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN printf '%s\n' \
    'PermitRootLogin no' \
    'PasswordAuthentication no' \
    'LogLevel VERBOSE' \
    > /etc/ssh/sshd_config.d/99-lab.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]

# Collect SSH authentication events.
RUN python3 - <<'PY'
from pathlib import Path

path = Path("/var/ossec/etc/ossec.conf")
config = path.read_text()

entry = """
  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/auth.log</location>
  </localfile>
"""

if "<location>/var/log/auth.log</location>" not in config:
    if "</ossec_config>" not in config:
        raise RuntimeError("Wazuh configuration closing tag not found")
    config = config.replace(
        "</ossec_config>",
        entry + "\n</ossec_config>",
        1
    )
    path.write_text(config)
PY
