# DevPilot Readiness Score (DPRS)

## Overview

The DevPilot Readiness Score (DPRS) is a quantitative measure of repository maturity and production
readiness. It provides an objective assessment across four key dimensions to help teams understand
their progress and identify improvement areas.

## Quick Start

```bash
# Calculate score for current repository
devpilot dprs

# Or use the script directly
~/devpilot/scripts/dprs.sh

# Generate detailed report
devpilot dprs --verbose --output artifacts/
```

## Scoring Dimensions

DPRS evaluates repositories across four equally-weighted categories (25% each):

### 🧪 Tests (25%)

Measures test coverage and quality assurance practices:

- **Test file presence** (tests/, _\_test._, _.spec._)
- **CI/CD configuration** (.github/workflows/, .gitlab-ci.yml)
- **Coverage reports** (coverage/, .coverage)
- **Test configuration** (pytest.ini, jest.config.\*)
- **Pre-commit hooks** (.pre-commit-config.yaml)

**Scoring:**

- 100: Comprehensive test suite with CI/CD and coverage
- 75: Tests with CI pipeline
- 50: Basic test files present
- 25: Test configuration only
- 0: No testing infrastructure

### 🔒 Security (25%)

Evaluates security tooling and practices:

- **Security workflows** (.github/workflows/security\*)
- **Dependency scanning** (.trivyignore, .safety)
- **Secret scanning** (.gitleaks.toml)
- **SAST configuration** (.semgrep.yml)
- **Security policy** (SECURITY.md)

**Scoring:**

- 100: Full security suite with policies
- 75: Multiple security tools configured
- 50: Basic security scanning
- 25: Security configuration present
- 0: No security measures

### 📚 Documentation (25%)

Assesses documentation completeness:

- **Core docs** (README.md, CONTRIBUTING.md)
- **Architecture docs** (docs/, ARCHITECTURE.md)
- **API documentation** (openapi._, swagger._)
- **Change tracking** (CHANGELOG.md)
- **License** (LICENSE)

**Scoring:**

- 100: Comprehensive documentation suite
- 75: Good documentation with guides
- 50: Basic README and docs
- 25: Minimal README only
- 0: No documentation

### 🛠️ Developer Experience (25%)

Measures developer tooling and automation:

- **Task automation** (Justfile, Makefile, Taskfile)
- **Dependency management** (package.json, requirements.txt, go.mod)
- **Environment config** (.envrc, .env.example)
- **Dev containers** (.devcontainer/)
- **Editor config** (.editorconfig, .vscode/)
- **Code formatting** (.prettierrc, .rustfmt.toml)

**Scoring:**

- 100: Full DX suite with automation
- 75: Good tooling and config
- 50: Basic dependency management
- 25: Minimal configuration
- 0: No DX tooling

## Phase Thresholds

DPRS maps scores to DevPilot project phases:

| Phase            | Score | Description                           | Typical Characteristics                                           |
| ---------------- | ----- | ------------------------------------- | ----------------------------------------------------------------- |
| 🚀 **SCALE**     | 90+   | Production-ready with full automation | Complete CI/CD, 80%+ coverage, security gates, comprehensive docs |
| 🧪 **BETA**      | 75-89 | Feature-complete, ready for users     | 60%+ coverage, security scanning, good documentation              |
| ⚡ **MVP**       | 60-74 | Core features working, basic quality  | Basic tests, minimal security, README present                     |
| 🔬 **POC**       | 40-59 | Concept proven, exploring viability   | Some structure, early documentation                               |
| 💡 **INCEPTION** | <40   | Early exploration phase               | Minimal structure, experimenting                                  |

## Integration with DevPilot

### Automatic Profile Selection

DPRS can automatically suggest appropriate skill level and phase:

```bash
# Calculate and apply recommended settings
dprs_score=$(devpilot dprs --json | jq -r '.total_score')

if [[ $dprs_score -ge 90 ]]; then
    devpilot profile --skill expert --phase scale
elif [[ $dprs_score -ge 75 ]]; then
    devpilot profile --skill l2 --phase beta
elif [[ $dprs_score -ge 60 ]]; then
    devpilot profile --skill l1 --phase mvp
else
    devpilot profile --skill beginner --phase poc
fi
```

### CI Integration

Add DPRS to your CI pipeline:

```yaml
# .github/workflows/dprs-report.yml
name: DPRS Report

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  dprs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Calculate DPRS
        run: |
          curl -sL https://raw.githubusercontent.com/Softsensor-org/DevPilot/main/scripts/dprs.sh | bash

      - name: Comment on PR
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const report = fs.readFileSync('artifacts/dprs.md', 'utf8');

            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: report
            });
```

## Output Formats

DPRS generates multiple output formats:

### Markdown Report (artifacts/dprs.md)

Human-readable report with score breakdown and recommendations

### JSON Output (artifacts/dprs.json)

```json
{
  "repository": "my-project",
  "branch": "main",
  "commit": "abc123",
  "date": "2025-01-15",
  "total_score": 71,
  "phase_readiness": "MVP",
  "categories": {
    "tests": {
      "score": 75,
      "weight": 25,
      "weighted_score": 19
    },
    "security": {
      "score": 50,
      "weight": 25,
      "weighted_score": 13
    },
    "documentation": {
      "score": 85,
      "weight": 25,
      "weighted_score": 21
    },
    "developer_experience": {
      "score": 75,
      "weight": 25,
      "weighted_score": 19
    }
  }
}
```

### Console Output

Color-coded summary for terminal display

## Customization

### Custom Weights

Adjust category weights for your organization:

```bash
# In scripts/dprs.sh, modify:
TEST_WEIGHT=30      # Increase test importance
SECURITY_WEIGHT=30  # Increase security importance
DOCS_WEIGHT=20      # Reduce documentation weight
DX_WEIGHT=20        # Reduce DX weight
```

### Additional Signals

Extend DPRS with custom checks:

```bash
# Add to scripts/dprs.sh
check_custom_metric() {
    local score=0

    # Check for performance benchmarks
    if [[ -f "benchmarks/results.json" ]]; then
        score=$((score + 25))
    fi

    # Check for monitoring config
    if [[ -f ".datadog.yml" ]] || [[ -f "prometheus.yml" ]]; then
        score=$((score + 25))
    fi

    echo "$score"
}
```

## Best Practices

### Improving Your Score

**Quick Wins (can add 10-20 points):**

- Add a comprehensive README.md
- Create .pre-commit-config.yaml
- Add a Justfile or Makefile
- Create CONTRIBUTING.md
- Add .env.example

**Medium Effort (can add 20-40 points):**

- Set up GitHub Actions CI
- Add security scanning workflow
- Create test suite with coverage
- Add .devcontainer configuration
- Document architecture in docs/

**Long-term (reaching 90+):**

- Achieve 80%+ test coverage
- Implement comprehensive security gates
- Create full API documentation
- Add performance benchmarks
- Implement automated releases

### Using DPRS for Team Goals

1. **Set quarterly targets:**

   ```
   Q1: Achieve DPRS 60 (MVP ready)
   Q2: Achieve DPRS 75 (Beta ready)
   Q3: Achieve DPRS 90 (Scale ready)
   ```

2. **Track progress in standups:**

   ```bash
   # Add to daily standup notes
   devpilot dprs --brief
   ```

3. **Gate deployments:**
   ```yaml
   # In CI/CD pipeline
   - name: Check DPRS threshold
     run: |
       score=$(devpilot dprs --json | jq -r '.total_score')
       if [[ $score -lt 75 ]]; then
         echo "DPRS too low for production: $score < 75"
         exit 1
       fi
   ```

## Comparison with Other Metrics

| Metric              | Focus                  | DevPilot Integration        |
| ------------------- | ---------------------- | --------------------------- |
| **DPRS**            | Overall maturity       | Native, drives profiles     |
| **Code Coverage**   | Test completeness      | Component of Tests score    |
| **Security Score**  | Vulnerability count    | Component of Security score |
| **Tech Debt Ratio** | Code quality           | Not directly measured       |
| **DORA Metrics**    | Deployment performance | Complementary               |

## FAQ

**Q: How often should we check DPRS?** A: Weekly during active development, monthly for maintenance
projects

**Q: Can DPRS go down?** A: Yes, if you remove tests, documentation, or security configs

**Q: What's a good target score?** A: MVP projects: 60+, Beta products: 75+, Production systems: 90+

**Q: How does DPRS relate to phases?** A: DPRS suggests phases but you can override based on
business needs

## See Also

- [Profiles & Phases](profiles.md) - How DPRS maps to DevPilot profiles
- [CI Integration](ci.md) - Automating DPRS in pipelines
- [Benefits](BENEFITS.md) - ROI and metrics tracking
