# DevPilot Migration Rollback Procedures
## Emergency Recovery and Rollback Guide

**Document Version:** 1.0.0  
**Date:** 2024-08-31  
**Owner:** DevPilot Operations Team  
**Status:** Ready for Implementation

---

## Executive Summary

This document provides comprehensive rollback procedures for the DevPilot migration. It covers detection, decision-making, execution, and recovery processes to ensure minimal downtime and data integrity during any rollback scenario.

## 1. Rollback Triggers

### 1.1 Automatic Triggers
These conditions automatically initiate rollback:

| Condition | Threshold | Detection Method | Auto-Rollback |
|-----------|-----------|------------------|---------------|
| Error Rate | > 5% for 5 minutes | Monitoring system | Yes |
| Response Time | > 3x baseline for 10 minutes | Performance metrics | Yes |
| Memory Usage | > 90% sustained for 15 minutes | System monitoring | Yes |
| Critical Service Down | Any core service for 2 minutes | Health checks | Yes |
| Data Corruption | Any detected | Integrity checks | Yes |

### 1.2 Manual Triggers
Require human decision:

- User satisfaction score < 2/5
- Security vulnerability discovered
- Breaking change in critical workflow
- Team consensus for rollback
- Stakeholder directive

## 2. Pre-Rollback Checklist

### 2.1 Assessment Phase (5 minutes)
```bash
# 1. Capture current state
.migration/scripts/capture-state.sh

# 2. Generate diagnostics report
.migration/scripts/diagnostics.sh > /tmp/rollback-reason.log

# 3. Check rollback readiness
.migration/scripts/rollback-check.sh
```

### 2.2 Communication (2 minutes)
- [ ] Alert on-call team via PagerDuty
- [ ] Post to #devpilot-migration Slack channel
- [ ] Update status page to "Investigating"
- [ ] Notify stakeholders via email template

### 2.3 Preparation (3 minutes)
- [ ] Ensure backup integrity
- [ ] Verify rollback scripts are current
- [ ] Confirm team availability
- [ ] Document rollback reason

## 3. Rollback Execution Procedures

### 3.1 Phase-Specific Rollback

#### Phase 1: Foundation Rollback
```bash
#!/usr/bin/env bash
# Time: 2 minutes

# Stop all migration processes
killall -9 migration-worker 2>/dev/null

# Remove migration infrastructure
rm -rf .migration/

# Restore git state
git checkout main
git branch -D migration/devpilot-transform

# Clear any partial changes
git clean -fd
git reset --hard HEAD
```

#### Phase 2: Structure Rollback
```bash
#!/usr/bin/env bash
# Time: 5 minutes

# Stop active processes
.migration/scripts/stop-migration.sh

# Restore from checkpoint
CHECKPOINT=$(cat .migration/state/last-checkpoint.txt)
.migration/scripts/restore-checkpoint.sh "$CHECKPOINT"

# Remove new directories
rm -rf core/ onboard/ pilot/ profiles/ projects/ studio/ insights/ academy/ .devpilot/

# Restore original structure
tar -xzf .migration/backups/structure-backup.tar.gz
```

#### Phase 3: File Migration Rollback
```bash
#!/usr/bin/env bash
# Time: 10 minutes

# Load migration map
MAP=".migration/state/migration-map.json"

# Reverse each migration
jq -r '.migrations[] | "\(.destination) \(.source)"' "$MAP" | while read dest src; do
    if [[ -f "$dest" ]]; then
        mv "$dest" "$src"
        echo "Restored: $src"
    fi
done

# Restore permissions
chmod +x setup_all.sh install_*.sh scripts/*.sh
```

#### Phase 4: Compatibility Layer Rollback
```bash
#!/usr/bin/env bash
# Time: 3 minutes

# Remove wrapper scripts
find . -maxdepth 1 -name "*.wrapper.sh" -delete

# Restore direct script access
for script in setup_all.sh install_*.sh validate_*.sh; do
    if [[ -f ".migration/backups/$script.backup" ]]; then
        cp ".migration/backups/$script.backup" "$script"
    fi
done
```

#### Phase 5: Testing Rollback
```bash
#!/usr/bin/env bash
# Time: 2 minutes

# Simply revert to previous commit
git reset --hard HEAD~1

# Or restore from tag
git checkout v0-legacy
```

#### Phase 6: Canary Rollback
```bash
#!/usr/bin/env bash
# Time: 5 minutes

# Update feature flags
jq '.features.devpilot_new = false' .devpilot/config/features.json > /tmp/features.json
mv /tmp/features.json .devpilot/config/features.json

# Route all traffic to old system
echo "rollback" > .migration/state/routing-mode.txt

# Notify canary users
.migration/scripts/notify-canary-users.sh --message "Reverting to previous version"
```

### 3.2 Full System Rollback
```bash
#!/usr/bin/env bash
# Complete rollback: 15 minutes

set -euo pipefail

echo "[$(date)] Starting full rollback..."

# 1. Create rollback checkpoint
BACKUP_NAME="rollback-$(date +%Y%m%d-%H%M%S)"
tar -czf "/tmp/$BACKUP_NAME.tar.gz" . 2>/dev/null

# 2. Stop all services
systemctl stop devpilot 2>/dev/null || true
killall -9 devpilot 2>/dev/null || true

# 3. Restore from master backup
BACKUP_FILE=".migration/backups/master-backup.tar.gz"
if [[ ! -f "$BACKUP_FILE" ]]; then
    echo "ERROR: Master backup not found!"
    exit 1
fi

# 4. Extract backup
tar -xzf "$BACKUP_FILE" --strip-components=1

# 5. Reset git state
git reset --hard origin/main
git clean -fd

# 6. Restore permissions
find . -name "*.sh" -exec chmod +x {} \;

# 7. Clear caches
rm -rf ~/.cache/devpilot
rm -rf /tmp/devpilot-*

# 8. Restart services
systemctl start devpilot 2>/dev/null || true

echo "[$(date)] Rollback complete"
```

## 4. Post-Rollback Procedures

### 4.1 Immediate Actions (30 minutes)

#### Verification
```bash
# Test core functionality
./setup_all.sh --test-only
./validation/validate_agents.sh
./scripts/doctor.sh

# Check user access
curl -s http://localhost:8080/health | jq '.status'

# Verify data integrity
.migration/scripts/verify-data.sh
```

#### Communication
1. Update status page: "Operational"
2. Send all-clear to Slack
3. Email stakeholders with summary
4. Create incident report ticket

### 4.2 Root Cause Analysis (2 hours)

#### Data Collection
```bash
# Gather logs
mkdir -p /tmp/rca-$(date +%Y%m%d)
cp -r .migration/logs/* /tmp/rca-$(date +%Y%m%d)/
journalctl -u devpilot --since "2 hours ago" > /tmp/rca-$(date +%Y%m%d)/system.log

# Capture metrics
.migration/scripts/export-metrics.sh > /tmp/rca-$(date +%Y%m%d)/metrics.json

# User feedback
.migration/scripts/collect-feedback.sh > /tmp/rca-$(date +%Y%m%d)/feedback.txt
```

#### Analysis Template
```markdown
## Incident Report: Migration Rollback

**Date:** [DATE]
**Duration:** [START] - [END]
**Impact:** [USERS AFFECTED]

### Timeline
- [TIME]: Initial trigger detected
- [TIME]: Decision to rollback
- [TIME]: Rollback initiated
- [TIME]: Rollback completed
- [TIME]: Service restored

### Root Cause
[Detailed explanation]

### Contributing Factors
1. [Factor 1]
2. [Factor 2]

### Lessons Learned
- What went well
- What went wrong
- What was missing

### Action Items
- [ ] Fix identified issue
- [ ] Update rollback procedures
- [ ] Improve monitoring
- [ ] Update documentation
```

### 4.3 Recovery Planning (4 hours)

1. **Fix Issues**
   - Address root cause
   - Update migration scripts
   - Add missing tests
   - Improve monitoring

2. **Update Plan**
   - Revise migration timeline
   - Add additional checkpoints
   - Enhance validation steps
   - Update risk assessment

3. **Team Debrief**
   - Conduct blameless postmortem
   - Document lessons learned
   - Update runbooks
   - Train on improvements

## 5. Rollback Automation Scripts

### 5.1 Master Rollback Script
```bash
#!/usr/bin/env bash
# .migration/scripts/rollback.sh

set -euo pipefail

# Configuration
LOG_FILE=".migration/logs/rollback-$(date +%Y%m%d-%H%M%S).log"
STATE_FILE=".migration/state/config.json"

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    if [[ ! -f "$STATE_FILE" ]]; then
        log "ERROR: State file not found"
        exit 1
    fi
    
    if [[ ! -d ".migration/backups" ]]; then
        log "ERROR: Backups directory not found"
        exit 1
    fi
    
    log "Prerequisites check passed"
}

# Determine rollback phase
get_current_phase() {
    jq -r '.current_phase // "unknown"' "$STATE_FILE"
}

# Execute phase-specific rollback
rollback_phase() {
    local phase="$1"
    log "Rolling back phase: $phase"
    
    case "$phase" in
        "foundation")
            rollback_foundation
            ;;
        "structure")
            rollback_structure
            ;;
        "migration")
            rollback_migration
            ;;
        "compatibility")
            rollback_compatibility
            ;;
        "testing")
            rollback_testing
            ;;
        "canary")
            rollback_canary
            ;;
        *)
            log "ERROR: Unknown phase: $phase"
            exit 1
            ;;
    esac
}

# Main execution
main() {
    log "=== Starting Rollback ==="
    
    check_prerequisites
    
    CURRENT_PHASE=$(get_current_phase)
    log "Current phase: $CURRENT_PHASE"
    
    # Stop ongoing operations
    log "Stopping migration processes..."
    pkill -f migration || true
    
    # Execute rollback
    rollback_phase "$CURRENT_PHASE"
    
    # Verify rollback
    log "Verifying rollback..."
    if ./validation/validate_agents.sh > /dev/null 2>&1; then
        log "Rollback verification passed"
    else
        log "WARNING: Rollback verification failed"
    fi
    
    # Update state
    jq '.status = "rolled_back"' "$STATE_FILE" > /tmp/state.json
    mv /tmp/state.json "$STATE_FILE"
    
    log "=== Rollback Complete ==="
    log "Next steps:"
    log "1. Review logs at: $LOG_FILE"
    log "2. Run validation: ./validation/validate_agents.sh"
    log "3. Check user access"
    log "4. Document incident"
}

# Run main function
main "$@"
```

### 5.2 Monitoring Script
```bash
#!/usr/bin/env bash
# .migration/scripts/monitor.sh

set -euo pipefail

# Thresholds
ERROR_RATE_THRESHOLD=5
RESPONSE_TIME_THRESHOLD=1000  # ms
MEMORY_THRESHOLD=90  # percent

# Check error rate
check_error_rate() {
    local error_rate
    error_rate=$(curl -s http://localhost:8080/metrics | jq '.error_rate')
    
    if (( $(echo "$error_rate > $ERROR_RATE_THRESHOLD" | bc -l) )); then
        echo "ERROR: Error rate $error_rate% exceeds threshold"
        return 1
    fi
    return 0
}

# Check response time
check_response_time() {
    local response_time
    response_time=$(curl -s -w "%{time_total}" -o /dev/null http://localhost:8080/health)
    response_time_ms=$(echo "$response_time * 1000" | bc)
    
    if (( $(echo "$response_time_ms > $RESPONSE_TIME_THRESHOLD" | bc -l) )); then
        echo "ERROR: Response time ${response_time_ms}ms exceeds threshold"
        return 1
    fi
    return 0
}

# Check memory usage
check_memory() {
    local memory_usage
    memory_usage=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
    
    if [[ $memory_usage -gt $MEMORY_THRESHOLD ]]; then
        echo "ERROR: Memory usage $memory_usage% exceeds threshold"
        return 1
    fi
    return 0
}

# Main monitoring loop
while true; do
    if ! check_error_rate || ! check_response_time || ! check_memory; then
        echo "ALERT: Triggering automatic rollback"
        .migration/scripts/rollback.sh --auto
        exit 1
    fi
    sleep 30
done
```

## 6. Rollback Testing

### 6.1 Test Scenarios

| Scenario | Test Method | Expected Result | Recovery Time |
|----------|-------------|-----------------|---------------|
| Phase 1 failure | Simulate error in foundation | Clean rollback | < 2 min |
| Phase 3 partial migration | Stop mid-migration | Restore all files | < 10 min |
| Canary user issues | Report critical bug | Route to old system | < 5 min |
| Performance degradation | Load test failure | Auto-rollback triggers | < 5 min |
| Data corruption | Inject bad data | Integrity check fails, rollback | < 15 min |

### 6.2 Rollback Drill Schedule

- **Weekly**: Test phase-specific rollback (rotating)
- **Monthly**: Full system rollback drill
- **Quarterly**: Disaster recovery exercise

## 7. Emergency Contacts

### On-Call Rotation
| Role | Primary | Secondary | Escalation |
|------|---------|-----------|------------|
| DevOps Lead | [Name] +1-xxx-xxx-xxxx | [Name] +1-xxx-xxx-xxxx | CTO |
| Engineering Lead | [Name] +1-xxx-xxx-xxxx | [Name] +1-xxx-xxx-xxxx | VP Eng |
| Product Owner | [Name] +1-xxx-xxx-xxxx | [Name] +1-xxx-xxx-xxxx | CPO |
| Security | [Name] +1-xxx-xxx-xxxx | [Name] +1-xxx-xxx-xxxx | CISO |

### External Support
- AWS Support: [Case URL]
- GitHub Support: [Ticket URL]
- Monitoring Vendor: [Contact]

## 8. Appendices

### Appendix A: Rollback Decision Tree
```
Start
├── Auto-trigger?
│   ├── Yes → Execute immediate rollback
│   └── No → Manual assessment
│       ├── Critical issue?
│       │   ├── Yes → Execute rollback
│       │   └── No → Continue monitoring
│       └── Team consensus?
│           ├── Yes → Execute rollback
│           └── No → Implement fixes
```

### Appendix B: Communication Templates

#### Rollback Initiation
```
Subject: [URGENT] DevPilot Migration Rollback Initiated

Team,

We are initiating a rollback of the DevPilot migration due to [REASON].

Current Status: Rolling back
Estimated Time: [X] minutes
Impact: [DESCRIPTION]

Updates will be posted in #devpilot-migration
```

#### Rollback Complete
```
Subject: [RESOLVED] DevPilot Migration Rollback Complete

Team,

The rollback has been completed successfully.

Service Status: Operational
Root Cause: Under investigation
Next Steps: RCA meeting at [TIME]

Thank you for your patience.
```

---

**Document Control:**
- Review: After each rollback event
- Training: Monthly drills
- Updates: As procedures change
- Distribution: All team members