#!/usr/bin/env bash
set -euo pipefail

message_file="${1:-}"
if [[ -z "${message_file}" || ! -f "${message_file}" ]]; then
  echo "usage: scripts/commitlint.sh <commit-msg-file>" >&2
  exit 2
fi

first_line="$(grep -m1 -v '^#' "${message_file}" | tr -d '\r')"

if [[ "${first_line}" =~ ^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9._-]+\))?!?:\ .+ ]]; then
  exit 0
fi

cat >&2 <<'EOF'
Commit message must use Conventional Commits:

  <type>[optional scope]: <description>

Allowed types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
Examples:
  chore: set up rust quality gates
  feat(parser): add hex decoder
EOF
exit 1
