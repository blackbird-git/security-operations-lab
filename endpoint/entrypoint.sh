#!/bin/bash
set -e

# Restore persistent Wazuh agent identity.
if [ -s /agent-keys/client.keys ]; then
    cp /agent-keys/client.keys /var/ossec/etc/client.keys
    chown wazuh:wazuh /var/ossec/etc/client.keys
    chmod 640 /var/ossec/etc/client.keys
fi

# Ensure SSH authentication log exists before Wazuh starts.
touch /var/log/auth.log
chown syslog:adm /var/log/auth.log
chmod 640 /var/log/auth.log

# Start logging and monitoring services.
/usr/sbin/rsyslogd
/var/ossec/bin/wazuh-control start

# Keep SSH running as the container's main process.
exec /usr/sbin/sshd -D
