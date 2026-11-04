# Security Operations Lab

A hands-on cybersecurity lab focused on security monitoring,
endpoint visibility, threat detection, and incident response.

## Objectives

- Deploy and administer a Wazuh SIEM environment
- Collect and analyze Linux security events
- Investigate suspicious activity using logs and alerts
- Explore detection rules and MITRE ATT&CK mappings
- Develop incident response playbooks
- Document findings and remediation recommendations

## Environment

- Windows 11 with WSL2 Ubuntu
- Docker Engine and Docker Compose
- Wazuh single-node deployment
- Linux endpoint monitoring (planned)

## Progress

- [x] Verified Docker and WSL resources
- [x] Deployed Wazuh single-node stack
- [x] Accessed the Wazuh dashboard
- [ ] Hardened local deployment
- [ ] Enrolled a monitored Linux endpoint
- [ ] Investigated simulated security events
- [ ] Documented incident response procedures

## Architecture

The Wazuh deployment uses three components:

- Wazuh Manager: Event collection, analysis, and detection
- Wazuh Indexer: Security event storage and search
- Wazuh Dashboard: Investigation and visualization

The deployment is based on the official Wazuh Docker project.

## Security

This repository contains documentation and sanitized lab
artifacts only. Credentials, certificates, private keys,
raw security logs, and local deployment data are excluded.

All security simulations are performed in an authorized,
isolated lab environment.
