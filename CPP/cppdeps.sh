#!/usr/bin/env bash
#
# LICENSED MATERIALS - PROPERTY OF IBM
# "RESTRICTED MATERIALS OF IBM"
# (C) COPYRIGHT IBM CORPORATION 2026. ALL RIGHTS RESERVED
# US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
# OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
# CONTRACT WITH IBM CORPORATION
#
# cppdeps.sh - list transitive user header dependencies for all git-modified .C and .cpp files
# Output: CPP/cppdeps.txt (sorted, deduplicated; includes C++ sources and their user headers,
#         e.g. .h and .hpp files)
#
# Compatible with: macOS, Linux, Windows Git Bash (requires clang on PATH)
# Usage: run from the repository root
#   bash CPP/cppdeps.sh [file1.C file2.cpp ...]
#
# Optional arguments: space-separated list of .C or .cpp files (relative to repo root) that
# are always included in the dependency scan regardless of their git modified status.

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"
OUTPUT="$SCRIPT_DIR/cppdeps.txt"

# Parse extra files passed as arguments
extra=("$@")

# On Windows, git rev-parse returns /c/... POSIX paths.
# Convert to a native path only when passing to clang, which may be a Windows binary.
# Detect Windows Git Bash by checking for MSYS/MINGW environment.
is_windows() {
  [[ "$(uname -s)" == MINGW* ]] || [[ "$(uname -s)" == MSYS* ]] || [[ "$(uname -s)" == CYGWIN* ]]
}

to_native() {
  if is_windows; then
    # cygpath converts /c/foo -> C:/foo (forward slashes, safe for clang on Windows)
    cygpath -m "$1"
  else
    echo "$1"
  fi
}

# Collect all modified .C and .cpp files reported by git status.
# Deleted files are skipped since there is nothing left to compile.
modified=()
while IFS= read -r line; do
  modified+=("$line")
done < <(
  git -C "$REPO_ROOT" status --porcelain \
    | grep -v '^.D\|^D' \
    | awk '{print $NF}' \
    | grep -E '\.(C|cpp)$' \
    || true
)

# Merge modified + extra files, deduplicating by path.
# Write candidate paths to a temp file first to avoid set -e killing empty-array checks
# inside pipes/subshells (bash 3 compat).
candidates=$(mktemp)
[[ ${#modified[@]} -gt 0 ]] && printf '%s\n' "${modified[@]}" >> "$candidates" || true
[[ ${#extra[@]}    -gt 0 ]] && printf '%s\n' "${extra[@]}"    >> "$candidates" || true

seen_tmp=$(mktemp)
all_files=()
while IFS= read -r f; do
  if ! grep -qxF "$f" "$seen_tmp" 2>/dev/null; then
    echo "$f" >> "$seen_tmp"
    all_files+=("$f")
  fi
done < "$candidates"
rm -f "$candidates" "$seen_tmp"

if [[ ${#all_files[@]} -eq 0 ]]; then
  echo "No .C or .cpp files to process (no modified files and no extra files specified)."
  exit 0
fi

echo "Modified .C/.cpp files found:"
[[ ${#modified[@]} -gt 0 ]] && printf '  %s\n' "${modified[@]}"

if [[ ${#all_files[@]} -gt ${#modified[@]} ]]; then
  echo "Extra .C/.cpp files included:"
  [[ ${#extra[@]} -gt 0 ]] && printf '  %s\n' "${extra[@]}"
fi

# For each modified file, collect its user-only transitive includes
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

for src in "${all_files[@]}"; do
  rel_src_dir="$(dirname "$src")"
  src_basename="$(basename "$src")"
  src_stem="${src_basename%.*}"

  # On Windows, clang is a native binary and needs Windows-style paths.
  # Use cygpath -m to convert /c/foo -> C:/foo (forward slashes clang accepts).
  # On macOS/Linux keep paths relative so clang emits relative paths in output.
  if is_windows; then
    native_abs="$(cygpath -m "$REPO_ROOT/$src")"
    native_inc="$(cygpath -m "$REPO_ROOT/$rel_src_dir")"
    native_root="$(cygpath -m "$REPO_ROOT")/"
  else
    native_abs="$src"
    native_inc="$rel_src_dir"
    native_root=""
  fi

  # Add the source file itself
  echo "$src" >> "$tmp"

  # Remove CR and the trailing " \" line continuations first, then normalise Windows
  # backslash path separators to forward slashes (clang on Windows emits C:\dir\file),
  # and finally split the dependency list on spaces, one path per line.
  clang -MM -I"$native_inc" "$native_abs" \
    | sed -e 's/\r//' -e 's/ \\$//' -e 's|\\|/|g' \
    | tr ' ' '\n' \
    | grep -v '\.json$' \
    | grep -v "^${src_stem}\.o:$" \
    | grep -v '^$' \
    | if [[ -n "$native_root" ]]; then
        # On Windows clang emits absolute C:/... paths; strip the repo root prefix
        # (case-insensitive, drive letter case may differ) to produce repo-relative
        # paths matching the POSIX side behaviour.
        sed "s|^${native_root}||I"
      else
        cat
      fi \
    | grep -v '^/' \
    | grep -v '^[A-Za-z]:' \
    | grep -v "^${src}$" \
    >> "$tmp"
done

# Sort and deduplicate, write output
sort -u "$tmp" > "$OUTPUT"

echo "Header dependencies written to: $OUTPUT"
cat "$OUTPUT"
