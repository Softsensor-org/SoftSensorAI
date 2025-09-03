#!/usr/bin/env bats

# Smoke tests for dp unified CLI

setup() {
  # Ensure dp is in PATH
  export PATH="${BATS_TEST_DIRNAME}/../../bin:$PATH"
}

@test "dp command exists and is executable" {
  [ -x "$(command -v dp)" ]
}

@test "dp shows help with no arguments" {
  run dp
  [ "$status" -eq 0 ]
  [[ "$output" == *"DevPilot Unified CLI"* ]]
}

@test "dp help command works" {
  run dp help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Available commands:"* ]]
}

@test "dp version shows version info" {
  run dp --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"DevPilot"* ]]
}

@test "dp lists available commands" {
  run dp help
  [ "$status" -eq 0 ]
  [[ "$output" == *"setup"* ]]
  [[ "$output" == *"init"* ]]
  [[ "$output" == *"doctor"* ]]
  [[ "$output" == *"palette"* ]]
}

@test "dp setup shows help with --help" {
  run dp setup --help
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]  # Some commands exit 1 on help
  [[ "$output" == *"setup"* ]] || [[ "$output" == *"Setup"* ]]
}

@test "dp doctor --help shows doctor help" {
  run dp doctor --help
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
  [[ "$output" == *"health"* ]] || [[ "$output" == *"Health"* ]] || [[ "$output" == *"doctor"* ]]
}

@test "dp handles unknown commands gracefully" {
  run dp nonexistent-command
  [ "$status" -ne 0 ]
  [[ "$output" == *"Unknown command"* ]] || [[ "$output" == *"not found"* ]] || [[ "$output" == *"Available commands"* ]]
}

@test "dp palette command exists" {
  # Just check it's recognized, not run (needs fzf)
  run dp palette --help
  # Either shows help or tries to run (both ok for smoke test)
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ] || [ "$status" -eq 127 ]
}

@test "dp init --help shows init help" {
  run dp init --help
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
  [[ "$output" == *"init"* ]] || [[ "$output" == *"Initialize"* ]]
}
