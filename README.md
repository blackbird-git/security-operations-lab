# Security Operations Lab

A hands-on security operations environment built to develop and demonstrate practical skills in security monitoring, detection analysis, incident investigation, and infrastructure security.

The lab uses Wazuh to collect and analyze Linux endpoint telemetry, generate security alerts, and investigate simulated security activity.

## Objectives

- Deploy and administer a functional SIEM environment.
- Configure Linux endpoint monitoring and log collection.
- Investigate authentication and other security events.
- Validate detection rules against observed evidence.
- Practice incident triage and documentation.
- Troubleshoot monitoring and detection pipeline failures.
- Apply security controls to a containerized lab environment.

## Architecture

```text
Windows 11 / WSL2 / Docker
|
+-- Wazuh Single-Node Stack
|   |
|   +-- Wazuh Manager
|   +-- Wazuh Indexer
|   +-- Wazuh Dashboard
|
+-- Ubuntu 24.04 Endpoint
    |
    +-- OpenSSH Server
    +-- rsyslog
    +-- Wazuh Agent
    +-- /var/log/auth.log
```

The Ubuntu endpoint communicates with the Wazuh Manager over an internal Docker network.

The endpoint does not publish an SSH port to the host.

## Technology Stack

| Component | Technology |
|-----------|------------|
| Host | Windows 11 with WSL2 |
| Container platform | Docker / Docker Compose |
| SIEM | Wazuh 4.14.9 |
| Endpoint | Ubuntu 24.04 |
| Authentication service | OpenSSH |
| Logging | rsyslog |
| Detection framework | Wazuh rules / MITRE ATT&CK |
| Version control | Git / GitHub |

## Repository Structure

```text
security-operations-lab/
├── README.md
├── docs/
│   └── deployment-hardening.md
├── endpoint/
│   ├── Dockerfile
│   ├── compose.yml
│   └── entrypoint.sh
├── investigations/
│   └── 001-ssh-invalid-user.md
├── detections/
├── playbooks/
└── screenshots/
```

The upstream Wazuh Docker deployment is excluded from this repository. Generated certificates, credentials, and agent registration keys are not committed.

## Deployment Overview

### 1. Deploy Wazuh

Deploy the official Wazuh single-node Docker stack using the upstream documentation:

https://documentation.wazuh.com/current/deployment-options/docker/wazuh-container.html

The lab was tested using Wazuh 4.14.9.

The upstream deployment is maintained separately in the local `wazuh-docker/` directory.

### 2. Configure the Endpoint

The `endpoint/` directory contains the Ubuntu endpoint Dockerfile, Compose configuration, and startup script.

The endpoint connects to the external Docker network:

`single-node_default`

Before deploying, create a persistent volume for the Wazuh agent registration:

```bash
docker volume create security-endpoint-agent-keys
```

The endpoint's startup script restores an existing agent registration key from this volume when one is present. Initial enrollment is performed through the Wazuh agent configuration.

For a previously enrolled endpoint, the registration key must be backed up to the volume before container recreation.

Deploy the endpoint:

```bash
cd endpoint
docker compose build
docker compose up -d
```

Verify the agent is registered and Active in Wazuh.

### 3. Access the Dashboard

Open:

https://localhost

Use the credentials configured for the local Wazuh deployment.

Navigate to Threat Hunting to review detected security events.

## Investigation 001: Invalid SSH User Authentication

**Status:** Completed

**Detection:** Wazuh rule 5710, level 5

**Scenario:** Five controlled SSH authentication attempts using a nonexistent username.

### Results

- The endpoint recorded the attempts in `/var/log/auth.log`.
- The Wazuh agent forwarded the events to the Manager.
- Wazuh generated rule 5710 alerts.
- The original five events appeared in Threat Hunting.
- Source IP was `127.0.0.1`, indicating locally generated traffic.
- No successful authentication or compromise was demonstrated.
- Activity was classified as authorized testing.

The rule included MITRE ATT&CK mappings for T1110.001 and T1021.004. These mappings were treated as detection context, not proof that those techniques occurred.

### Post-Rebuild Validation

The endpoint was rebuilt and recreated while preserving agent identity `002`.

A subsequent SSH test generated an alert with:

- Event timestamp: 2026-11-04 01:10:06.974 UTC
- Alert timestamp: 2026-11-04 01:10:07.210 UTC
- Rule: 5710
- Severity: 5

The alert was generated approximately 235 milliseconds after the original log timestamp.

[Read the full investigation](investigations/001-ssh-invalid-user.md)

## Troubleshooting and Engineering Findings

The initial deployment exposed several operational issues:

| Issue | Resolution |
|-------|------------|
| SSH events not appearing in Wazuh | Configured collection of `/var/log/auth.log` |
| Duplicate agent enrollment after rebuild | Persisted agent registration in a Docker named volume |
| Authentication log missing at startup | Initialized the log before starting Wazuh |
| Missing post-rebuild alert | Validated rule matching and investigated collector restart timing |

The missing event coincided with a Wazuh log collector restart. The exact cause was not conclusively established, but subsequent live detection succeeded.

## Security Considerations

The environment is intended for isolated local testing and is not a production-hardened SIEM deployment.

Controls implemented include:

- Wazuh service ports bound to localhost in the local deployment.
- Administrator password rotated from the initial deployment value.
- No published SSH port for the endpoint.
- Persistent agent registration stored outside Git.
- Generated secrets and upstream deployment files excluded from version control.

Remaining improvements include:

- Remove plaintext service credentials from local Compose configuration.
- Separate administrative and service account credentials.
- Verify Windows host and WSL2 network exposure.
- Review TLS and certificate lifecycle management.
- Further restrict unnecessary services and privileges.

[Read deployment hardening notes](docs/deployment-hardening.md)

## Planned Exercises

- Repeated SSH authentication failures from a separate lab endpoint.
- Detection correlation and alert triage.
- Linux privilege escalation monitoring.
- File integrity monitoring.
- Vulnerability detection and remediation validation.
- Investigation playbooks and incident response documentation.

## Disclaimer

All security activity is simulated within a controlled environment owned and operated for educational purposes.

No unauthorized external systems are targeted.
