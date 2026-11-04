# Wazuh SIEM Deployment Hardening

## Environment
- Wazuh 4.14.9, single-node Docker deployment
- Ubuntu on WSL2
- Docker Compose
- Wazuh Manager, Indexer, and Dashboard

## Finding 1: Unnecessarily Broad Network Bindings

### Initial condition
Docker published the following ports on all host interfaces:
- 443/TCP - Dashboard
- 9200/TCP - Indexer
- 55000/TCP - Manager API
- 1514/TCP - Agent communication
- 1515/TCP - Agent enrollment
- 514/UDP - Syslog

### Risk
Broad host bindings can unnecessarily expose management
interfaces and security services to reachable networks.

### Remediation
Changed Docker Compose published port bindings to
127.0.0.1 for this local lab.

### Validation
Verified the new bindings using docker compose ps.
Confirmed the dashboard remained accessible.

## Finding 2: Default Administrator Credentials

### Initial condition
The deployment used the default administrator credentials.

### Risk
Known default credentials increase the risk of unauthorized
access when management interfaces are reachable.

### Remediation
- Generated a strong replacement administrator password.
- Generated a bcrypt password hash using the Wazuh utility.
- Updated administrator credentials in the deployment configuration.
- Applied the updated internal users configuration using
  the Wazuh security administration utility.

### Validation
Successfully authenticated to the dashboard with the
new administrator credentials.

## Remaining Improvements
- Separate administrator and service-to-service accounts.
- Move secrets out of Docker Compose configuration.
- Verify Windows-side network exposure.
- Review TLS certificate management.

## Security Notes
No credentials, password hashes, private keys, or sensitive
event data are included in this repository.
