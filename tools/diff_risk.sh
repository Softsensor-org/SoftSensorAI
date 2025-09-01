#!/usr/bin/env bash
# Risk-aware diff analyzer - tags PRs with risk categories for smarter AI review
# Output: risk:auth, risk:db, risk:payment, risk:api, risk:security, etc.
set -euo pipefail

# Parse arguments
DIFF_FILE="${1:-}"
OUTPUT_FORMAT="${2:-tags}"  # tags, json, or markdown

if [[ -z "$DIFF_FILE" ]] || [[ ! -f "$DIFF_FILE" ]]; then
  echo "Usage: $0 <diff_file> [tags|json|markdown]" >&2
  exit 1
fi

# Risk detection patterns
declare -A RISK_PATTERNS=(
  # Authentication & Authorization
  ["auth"]="(auth|login|logout|session|token|jwt|oauth|credential|password|secret|api[_-]key|bearer|cookie)"

  # Database & Data
  ["db"]="(database|sql|query|migration|schema|table|column|index|constraint|transaction|lock|deadlock)"
  ["data"]="(pii|personal|sensitive|encrypt|decrypt|hash|salt|gdpr|ccpa|privacy)"

  # Payments & Money
  ["payment"]="(payment|charge|refund|stripe|paypal|billing|invoice|subscription|price|cost|money|currency)"

  # Security
  ["security"]="(security|vulnerability|exploit|injection|xss|csrf|cors|sanitize|escape|validate|permission)"
  ["crypto"]="(crypto|cipher|aes|rsa|sha|md5|random|entropy|certificate|ssl|tls|https)"

  # API & External Services
  ["api"]="(api|endpoint|route|rest|graphql|webhook|external|third[_-]party|integration|sdk)"
  ["network"]="(http|request|response|timeout|retry|circuit[_-]breaker|rate[_-]limit|throttle|ddos)"

  # Infrastructure & Config
  ["infra"]="(docker|kubernetes|k8s|helm|terraform|ansible|deploy|ci[/_-]cd|pipeline|workflow)"
  ["config"]="(config|env|environment|setting|flag|feature[_-]flag|toggle|property|yaml|json|toml)"

  # Machine Learning & AI
  ["ml"]="(model|train|predict|inference|neural|tensor|dataset|epoch|batch|gradient|loss|accuracy)"
  ["ai"]="(llm|gpt|claude|prompt|embedding|vector|rag|langchain|openai|anthropic)"

  # Performance & Scalability
  ["perf"]="(performance|optimize|cache|memory|leak|profile|benchmark|latency|throughput|bottleneck)"
  ["scale"]="(scale|load|concurrent|parallel|async|queue|worker|pool|thread|process)"

  # Frontend & UX
  ["ui"]="(component|render|state|redux|hook|lifecycle|dom|css|style|layout|responsive)"
  ["ux"]="(user[_-]experience|accessibility|a11y|wcag|screen[_-]reader|keyboard|focus|aria)"

  # Business Logic
  ["business"]="(business|logic|rule|workflow|process|calculation|formula|algorithm|validation)"
  ["critical"]="(critical|core|essential|vital|important|production|customer|revenue)"
)

# Files that indicate risk
declare -A FILE_PATTERNS=(
  ["auth"]="(auth|login|session|token).*\.(js|ts|py|go|java|rb)"
  ["db"]="(migration|schema|model|entity|repository).*\.(sql|js|ts|py|go)"
  ["payment"]="(payment|billing|stripe|checkout).*\.(js|ts|py|go)"
  ["security"]="(security|crypto|hash|encrypt).*\.(js|ts|py|go)"
  ["config"]="(config|env|settings|dockerfile|docker-compose|k8s|helm).*\.(yml|yaml|json|toml|env)"
  ["test"]="(test|spec|e2e|integration).*\.(js|ts|py|go)"
)

# High-risk file paths
declare -A PATH_RISKS=(
  ["auth"]="app/auth|src/auth|lib/auth|authentication|authorization"
  ["db"]="database|migrations|models|entities|repositories"
  ["payment"]="payment|billing|checkout|stripe|paypal"
  ["security"]="security|crypto|certificates|keys"
  ["infra"]=".github/workflows|.circleci|jenkins|terraform|k8s|helm"
  ["config"]="config|settings|env|environment"
)

# Analyze diff
RISKS=()
RISK_SCORES=()
RISK_DETAILS=()

# Check file paths first
while IFS= read -r line; do
  if [[ "$line" =~ ^diff\ --git\ a/(.*?)\ b/(.*?)$ ]]; then
    FILE_PATH="${BASH_REMATCH[2]}"

    # Check against path patterns
    for risk in "${!PATH_RISKS[@]}"; do
      if echo "$FILE_PATH" | grep -qiE "${PATH_RISKS[$risk]}"; then
        RISKS+=("$risk")
        RISK_DETAILS+=("Path match: $FILE_PATH")
      fi
    done

    # Check against file patterns
    for risk in "${!FILE_PATTERNS[@]}"; do
      if echo "$FILE_PATH" | grep -qiE "${FILE_PATTERNS[$risk]}"; then
        RISKS+=("$risk")
        RISK_DETAILS+=("File pattern: $FILE_PATH")
      fi
    done
  fi
done < "$DIFF_FILE"

# Check diff content
for risk in "${!RISK_PATTERNS[@]}"; do
  PATTERN="${RISK_PATTERNS[$risk]}"

  # Count matches in added/modified lines
  MATCHES=$(grep -E "^[+]" "$DIFF_FILE" | grep -ciE "$PATTERN" || true)

  if [[ "$MATCHES" -gt 0 ]]; then
    RISKS+=("$risk")
    RISK_SCORES+=("$risk:$MATCHES")

    # Sample matching lines for context
    SAMPLE=$(grep -E "^[+]" "$DIFF_FILE" | grep -iE "$PATTERN" | head -3 | sed 's/^+//' | tr '\n' ' ' | cut -c1-100)
    if [[ -n "$SAMPLE" ]]; then
      RISK_DETAILS+=("Content match ($MATCHES): $SAMPLE...")
    fi
  fi
done

# Deduplicate and sort risks
mapfile -t UNIQUE_RISKS < <(printf '%s\n' "${RISKS[@]}" | sort -u)

# Calculate overall risk level
RISK_COUNT=${#UNIQUE_RISKS[@]}
if [[ "$RISK_COUNT" -eq 0 ]]; then
  RISK_LEVEL="low"
elif [[ "$RISK_COUNT" -le 2 ]]; then
  RISK_LEVEL="medium"
elif [[ "$RISK_COUNT" -le 4 ]]; then
  RISK_LEVEL="high"
else
  RISK_LEVEL="critical"
fi

# Check for specific high-risk combinations
if [[ " ${UNIQUE_RISKS[*]} " =~ " auth " ]] && [[ " ${UNIQUE_RISKS[*]} " =~ " db " ]]; then
  RISK_LEVEL="critical"  # Auth + DB changes are always critical
fi
if [[ " ${UNIQUE_RISKS[*]} " =~ " payment " ]]; then
  RISK_LEVEL="critical"  # Payment changes are always critical
fi
if [[ " ${UNIQUE_RISKS[*]} " =~ " security " ]] && [[ " ${UNIQUE_RISKS[*]} " =~ " api " ]]; then
  RISK_LEVEL="critical"  # Security + API changes need careful review
fi

# Output based on format
case "$OUTPUT_FORMAT" in
  tags)
    # Simple tag format for CLI integration
    if [[ ${#UNIQUE_RISKS[@]} -gt 0 ]]; then
      for risk in "${UNIQUE_RISKS[@]}"; do
        echo -n "risk:$risk "
      done
      echo "level:$RISK_LEVEL"
    else
      echo "risk:none level:low"
    fi
    ;;

  json)
    # JSON format for programmatic use
    echo "{"
    echo "  \"level\": \"$RISK_LEVEL\","
    echo "  \"risks\": ["
    for i in "${!UNIQUE_RISKS[@]}"; do
      echo -n "    \"${UNIQUE_RISKS[$i]}\""
      if [[ $i -lt $((${#UNIQUE_RISKS[@]} - 1)) ]]; then
        echo ","
      else
        echo
      fi
    done
    echo "  ],"
    echo "  \"count\": $RISK_COUNT,"
    echo "  \"details\": ["
    for i in "${!RISK_DETAILS[@]}"; do
      echo -n "    \"${RISK_DETAILS[$i]}\""
      if [[ $i -lt $((${#RISK_DETAILS[@]} - 1)) ]]; then
        echo ","
      else
        echo
      fi
    done
    echo "  ]"
    echo "}"
    ;;

  markdown)
    # Markdown format for human reading
    echo "## Risk Analysis"
    echo ""
    echo "**Overall Risk Level:** $RISK_LEVEL"
    echo ""

    if [[ ${#UNIQUE_RISKS[@]} -gt 0 ]]; then
      echo "### Identified Risks"
      for risk in "${UNIQUE_RISKS[@]}"; do
        case "$risk" in
          auth) echo "- 🔐 **Authentication/Authorization** - Changes to auth flows" ;;
          db) echo "- 🗄️ **Database** - Schema, queries, or migration changes" ;;
          payment) echo "- 💳 **Payment** - Financial transaction handling" ;;
          security) echo "- 🛡️ **Security** - Security-sensitive code" ;;
          api) echo "- 🌐 **API** - External service integration" ;;
          infra) echo "- 🏗️ **Infrastructure** - Deploy, CI/CD, or container changes" ;;
          config) echo "- ⚙️ **Configuration** - Settings or environment changes" ;;
          ml) echo "- 🤖 **Machine Learning** - Model or training changes" ;;
          perf) echo "- ⚡ **Performance** - Performance-critical code" ;;
          ui) echo "- 🎨 **UI/Frontend** - User interface changes" ;;
          data) echo "- 🔒 **Data Privacy** - PII or sensitive data handling" ;;
          *) echo "- ⚠️ **$risk** - Requires attention" ;;
        esac
      done
      echo ""

      if [[ ${#RISK_DETAILS[@]} -gt 0 ]]; then
        echo "### Risk Indicators"
        for detail in "${RISK_DETAILS[@]:0:5}"; do  # Show max 5 details
          echo "- $detail"
        done
        echo ""
      fi

      echo "### Review Focus"
      case "$RISK_LEVEL" in
        critical)
          echo "⛔ **CRITICAL REVIEW REQUIRED**"
          echo "- Thorough security audit needed"
          echo "- Check for data leaks and vulnerabilities"
          echo "- Verify all authentication flows"
          echo "- Test rollback procedures"
          ;;
        high)
          echo "🔴 **High Risk - Careful Review**"
          echo "- Focus on security implications"
          echo "- Check error handling"
          echo "- Verify test coverage"
          ;;
        medium)
          echo "🟡 **Medium Risk - Standard Review**"
          echo "- Check for common issues"
          echo "- Verify functionality"
          ;;
        low)
          echo "🟢 **Low Risk - Quick Review**"
          echo "- Basic sanity checks"
          ;;
      esac
    else
      echo "✅ No significant risks detected"
    fi
    ;;

  *)
    echo "Unknown format: $OUTPUT_FORMAT" >&2
    exit 1
    ;;
esac
