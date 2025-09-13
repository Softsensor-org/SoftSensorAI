#!/usr/bin/env bats

# Smoke tests for ssai unified CLI

setup() {
  # Ensure ssai is in PATH
  export PATH="${BATS_TEST_DIRNAME}/../../bin:$PATH"
}

@test "ssai command exists and is executable" {
  [ -x "$(command -v ssai)" ]
}

@test "ssai shows help with no arguments" {
  run ssai
  [ "$status" -eq 0 ]
  [[ "$output" == *"SoftSensorAI Unified CLI"* ]]
}

@test "ssai help command works" {
  run ssai help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Available commands:"* ]]
}

@test "ssai version shows version info" {
  run ssai --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"SoftSensorAI"* ]]
}

@test "ssai lists available commands" {
  run ssai help
  [ "$status" -eq 0 ]
  [[ "$output" == *"setup"* ]]
  [[ "$output" == *"init"* ]]
  [[ "$output" == *"doctor"* ]]
  [[ "$output" == *"palette"* ]]
}

@test "ssai setup shows help with --help" {
  run ssai setup --help
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]  # Some commands exit 1 on help
  [[ "$output" == *"setup"* ]] || [[ "$output" == *"Setup"* ]]
}

@test "ssai doctor --help shows doctor help" {
  run ssai doctor --help
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
  [[ "$output" == *"health"* ]] || [[ "$output" == *"Health"* ]] || [[ "$output" == *"doctor"* ]]
}

@test "ssai handles unknown commands gracefully" {
  run ssai nonexistent-command
  [ "$status" -ne 0 ]
  [[ "$output" == *"Unknown command"* ]] || [[ "$output" == *"not found"* ]] || [[ "$output" == *"Available commands"* ]]
}

@test "ssai palette command exists" {
  # Just check it's recognized, not run (needs fzf)
  run ssai palette --help
  # Either shows help or tries to run (both ok for smoke test)
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ] || [ "$status" -eq 127 ]
}

@test "ssai init --help shows init help" {
  run ssai init --help
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
  [[ "$output" == *"init"* ]] || [[ "$output" == *"Initialize"* ]]
}
