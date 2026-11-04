# Investigation 001: Invalid SSH User Authentication

## Executive Summary

A controlled security test generated five invalid-user SSH
authentication attempts against an Ubuntu endpoint monitored
by Wazuh.

Wazuh detected the activity using rule 5710, classified as
"sshd: Attempt to login using a non-existent user."

The activity originated from the endpoint's loopback address
(127.0.0.1) and was intentionally generated for testing.

**Disposition:** Authorized security test; no incident.

## Environment

- SIEM: Wazuh 4.14.9
- Endpoint: Ubuntu 24.04 Docker container
- Agent: security-endpoint-01
- Agent ID: 002
- Log source: /var/log/auth.log
- Detection rule: 5710
- Detection severity: Level 5

## Detection Evidence

An observed alert contained:

- Timestamp: 2026-11-04 00:58:19 UTC
- Rule ID: 5710
- Description: sshd: Attempt to login using a non-existent user
- Rule level: 5
- Rule firedtimes: 5
- Source IP: 127.0.0.1
- Source username: nonexistent-lab-user
- Source port: 33688
- Agent: security-endpoint-01

Original event:

    2026-11-04T00:58:19.580323+00:00 security-endpoint-01 sshd[3728]: Invalid user nonexistent-lab-user from 127.0.0.1 port 33688

## MITRE ATT&CK Mapping

Wazuh associated the detection with:

- T1110.001: Password Guessing
- T1021.004: SSH

These mappings describe potentially relevant adversary
techniques. They do not establish that password guessing,
lateral movement, or compromise occurred.

## Investigation

### Initial Observation

Wazuh generated alerts for SSH authentication attempts
involving a nonexistent username.

### Source Analysis

The source IP was 127.0.0.1, indicating that the connection
originated from the endpoint itself.

### Authentication Analysis

The SSH server rejected the nonexistent username.

The available evidence does not demonstrate a successful
authentication or system compromise.

The test used SSH batch mode with password authentication
disabled for the client, so the observed activity should
not be described as confirmed password brute forcing.

### Context

The events were deliberately generated as part of an
authorized security monitoring exercise.

### Assessment

The alert accurately identified invalid-user SSH activity.

Given the known testing context, loopback source, and absence
of evidence of successful authentication, incident escalation
was not warranted.

## Outcome

**Classification:** Authorized simulation

**Incident status:** No confirmed security incident

**Action:** Documented detection and validated the monitoring
pipeline.

## Engineering Findings

During deployment, the following issues were identified:

1. SSH authentication logs were initially not collected.
2. Container recreation caused duplicate agent enrollment.
3. Wazuh attempted to open auth.log before the file existed.

Remediation included:

- Explicit Wazuh collection of /var/log/auth.log.
- Persistent agent registration using a Docker named volume.
- Startup initialization of auth.log before Wazuh starts.
- Revalidation of agent connectivity after container rebuild.

## Limitations and Next Steps

- Test traffic originated from localhost, not a remote host.
- No successful authentication was demonstrated.
- No actual password brute-force sequence was performed.
- The lab uses a single endpoint and a single-node Wazuh stack.
- Future testing should include controlled remote-source
  authentication failures and correlation-based detections.

## Key Takeaway

An alert's severity and MITRE mappings must be interpreted
alongside the underlying logs, source context, and known
authorized activity before determining whether an incident
occurred.

## Post-Rebuild Validation

After rebuilding the endpoint, the following controls were verified:

- Wazuh agent ID 002 persisted across container recreation.
- Agent successfully reconnected to the Wazuh Manager.
- SSH authentication log collection initialized automatically.
- A new invalid-user SSH event generated a rule 5710 alert.

### Verified Event

- Event timestamp: 2026-11-04 01:10:06.974 UTC
- Alert timestamp: 2026-11-04 01:10:07.210 UTC
- Rule: 5710
- Severity: Level 5
- Source IP: 127.0.0.1
- Source port: 49378
- Username: nonexistent-lab-user
- Agent ID: 002

The alert was generated approximately 235 milliseconds after
the original event timestamp.

### Troubleshooting Observation

An earlier test event was not detected after the rebuild.

Investigation confirmed:

1. The SSH event existed in /var/log/auth.log.
2. The Wazuh agent was connected to the Manager.
3. The Wazuh rule engine correctly matched rule 5710.
4. The missing event coincided with a log collector restart.
5. A subsequent test successfully generated an alert.

The collector restart may explain the missing event, but
the root cause was not conclusively established.

### Final Result

End-to-end SSH detection was successfully revalidated
after container recreation.
