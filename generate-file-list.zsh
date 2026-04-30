#!/bin/zsh

# bash generate-file-list.zsh

# Script to generate file list for export-project.zsh
# Run this to see all source files in your project, then copy the output

set -e

echo "==================================="
echo "FILE LIST FOR export-project.zsh"
echo "==================================="
echo ""

# Create temporary files for sorting
tmp_root=$(mktemp)
tmp_subdirs=$(mktemp)
tmp_output=$(mktemp)

# Find all relevant files, excluding common directories
find . -type f \
  \( -name "*.ts" -o -name "*.tsx"  -o -name "*.vue" -o -name "*.js" -o -name "*.jsx" -o -name "*.css" \
  -o -name "*.json" -o -name "*.md" -o -name "*.toml" -o -name "*.yaml" \
  -o -name "*.yml" -o -name "*.py" -o -name "*.html" -o -name "*.env" -o -name ".gitignore" -o -name "*.env.*" \
  -o -name "*.mjs" -o -name "*.config.*" -o -name "*.sql" -o -name ".dev.vars" -o -name "*.dev.vars.*" -o -name "*.cjs" \
  -o -name "_headers" -o -name "*.sh" -o -name "*.conf" \) \
  ! -path "*/node_modules/*" \
  ! -path "*/.git/*" \
  ! -path "*/dist/*" \
  ! -path "*/build/*" \
  ! -path "*/.next/*" \
  ! -path "*/.turbo/*" \
  ! -path "*/coverage/*" \
  ! -name "pnpm-lock.yaml" \
  ! -name "package-lock.json" \
  ! -name "__init__.py" \
  ! -name "yarn.lock" \
  | sed 's|^\./||' \
  | while read -r file; do
      # Check if file is in root directory (no slash in path)
      if [[ "$file" != */* ]]; then
        echo "$file" >> "$tmp_root"
      else
        echo "$file" >> "$tmp_subdirs"
      fi
    done

# Build the output
echo 'FILE_LIST=(' > "$tmp_output"

# Print root files first (sorted)
if [[ -f "$tmp_root" ]]; then
  sort "$tmp_root" | awk '{print "  \"" $0 "\""}' | tee -a "$tmp_output"
fi

# Print subdirectory files (sorted)
if [[ -f "$tmp_subdirs" ]]; then
  sort "$tmp_subdirs" | awk '{print "  \"" $0 "\""}' | tee -a "$tmp_output"
fi

echo ')' >> "$tmp_output"

# Display the output
cat "$tmp_output"
echo ""

# Calculate total
total=$(cat "$tmp_root" "$tmp_subdirs" 2>/dev/null | wc -l | tr -d ' ')

echo "==================================="
echo "Total files found: $total"
echo "==================================="
echo ""

# Copy to clipboard
cat "$tmp_output" | pbcopy

echo "✅ FILE_LIST copied to clipboard!"
echo "💡 Paste it into export-project.zsh and comment out files you don't want"
echo ""

# Cleanup
rm -f "$tmp_root" "$tmp_subdirs" "$tmp_output"