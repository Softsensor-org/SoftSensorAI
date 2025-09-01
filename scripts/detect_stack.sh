#!/usr/bin/env bash
# Detect technology stack from repository files
set -euo pipefail

detect_languages() {
  local languages=()

  # Check for common language files
  [ -f "package.json" ] && languages+=("Node.js")
  [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ] && languages+=("Python")
  [ -f "go.mod" ] && languages+=("Go")
  [ -f "Cargo.toml" ] && languages+=("Rust")
  [ -f "pom.xml" ] || [ -f "build.gradle" ] && languages+=("Java")
  [ -f "Gemfile" ] && languages+=("Ruby")
  [ -f "composer.json" ] && languages+=("PHP")
  [ -f "pubspec.yaml" ] && languages+=("Dart/Flutter")

  # Check for specific file extensions if no obvious indicators
  if [ ${#languages[@]} -eq 0 ]; then
    find . -type f -name "*.js" -o -name "*.ts" | head -1 >/dev/null && languages+=("JavaScript")
    find . -type f -name "*.py" | head -1 >/dev/null && languages+=("Python")
    find . -type f -name "*.go" | head -1 >/dev/null && languages+=("Go")
    find . -type f -name "*.rs" | head -1 >/dev/null && languages+=("Rust")
    find . -type f -name "*.java" | head -1 >/dev/null && languages+=("Java")
    find . -type f -name "*.rb" | head -1 >/dev/null && languages+=("Ruby")
    find . -type f -name "*.php" | head -1 >/dev/null && languages+=("PHP")
    find . -type f -name "*.sh" | head -1 >/dev/null && languages+=("Shell")
  fi

  # Default if nothing found
  [ ${#languages[@]} -eq 0 ] && languages+=("Unknown")

  # Join array elements with /
  local IFS="/"
  echo "${languages[*]}"
}

detect_frameworks() {
  local frameworks=()

  # Check package.json for JS frameworks
  if [ -f "package.json" ]; then
    if grep -q "\"react\"" package.json; then
      frameworks+=("React")
    fi
    if grep -q "\"express\"" package.json; then
      frameworks+=("Express")
    fi
    if grep -q "\"next\"" package.json; then
      frameworks+=("Next.js")
    fi
    if grep -q "\"vue\"" package.json; then
      frameworks+=("Vue.js")
    fi
    if grep -q "\"angular\"" package.json; then
      frameworks+=("Angular")
    fi
  fi

  # Check for Python frameworks
  if [ -f "requirements.txt" ]; then
    if grep -q "django" requirements.txt; then
      frameworks+=("Django")
    fi
    if grep -q "flask" requirements.txt; then
      frameworks+=("Flask")
    fi
    if grep -q "fastapi" requirements.txt; then
      frameworks+=("FastAPI")
    fi
  fi

  # Check for specific files
  [ -f "manage.py" ] && frameworks+=("Django")
  [ -f "app.py" ] && frameworks+=("Flask")

  if [ ${#frameworks[@]} -gt 0 ]; then
    local IFS="+"
    echo " (${frameworks[*]})"
  fi
}

detect_environment() {
  local env_indicators=()

  # Check for containerization
  [ -f "Dockerfile" ] && env_indicators+=("Docker")
  [ -f "docker-compose.yml" ] && env_indicators+=("Docker-Compose")

  # Check for Kubernetes
  if [ -d ".k8s" ] || [ -d "k8s" ] || [ -d "kubernetes" ]; then
    env_indicators+=("Kubernetes")
  fi

  # Check for cloud providers
  find . -name "*.tf" | head -1 >/dev/null && env_indicators+=("Terraform")
  ls .github/workflows/*.yml 2>/dev/null | head -1 >/dev/null && env_indicators+=("GitHub-Actions")
  [ -f ".gitlab-ci.yml" ] && env_indicators+=("GitLab-CI")

  # Default
  [ ${#env_indicators[@]} -eq 0 ] && env_indicators+=("Local")

  local IFS="+"
  echo "${env_indicators[*]}"
}

# Main detection
languages_str=$(detect_languages)
frameworks_str=$(detect_frameworks)
# environment=$(detect_environment)  # Not used currently

echo "${languages_str}${frameworks_str}"
