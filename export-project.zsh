#!/bin/zsh

set -e  # Exit on any error

OUTPUT_FILE="project_export.md"

FILE_LIST=(
  # ".gitignore"
  "package.json"
  "postcss.config.js"
  ".pre-commit-config.yaml"
  # "project_export.md"
  "pyproject.toml"
  # "README.md"
  "tailwind.config.js"
  "client_portal/.gitignore"
  "client_portal/index.html"
  "client_portal/package.json"
  "client_portal/postcss.config.js"
  "client_portal/README.md"
  "client_portal/src/App.vue"
  "client_portal/src/main.ts"
  "client_portal/src/style.css"
  "client_portal/src/views/Dashboard.vue"
  "client_portal/src/views/Invoices.vue"
  "client_portal/src/views/NotFound.vue"
  "client_portal/tailwind.config.js"
  "client_portal/tsconfig.app.json"
  "client_portal/tsconfig.json"
  "client_portal/tsconfig.node.json"
  "client_portal/vite.config.ts"
  # "client_portal/.vscode/extensions.json"
)



# Get project name from current directory
PROJECT_NAME=$(basename "$PWD")

# Remove old file if it exists
rm -f "$OUTPUT_FILE"

# Create new file
touch "$OUTPUT_FILE"

echo "📁 Exporting project structure..."

# Add project name and structure
{
  echo "# Project: $PROJECT_NAME"
  echo ""
  echo "## Project Structure"
  echo '```bash'
  tree -L 5 -n -a -I 'node_modules|.git|__pycache__|*.log|.turbo|assets' --dirsfirst | sed "1s/./$PROJECT_NAME/"
  echo '```'
  echo ""
  echo "## File Contents"
  echo ""
} > "$OUTPUT_FILE"

# Add file contents
for file in "${FILE_LIST[@]}"; do
  if [[ -f "$file" ]]; then
    file_size=$(stat -c %s "$file")
    echo "📄 Adding: ($file_size bytes) $file"
    
    # Get extension for syntax highlighting (e.g., .ts -> ts)
    ext="${file##*.}"
    
    # CHANGE 2: Use Markdown formatting with code blocks
    {
      echo "### File: $file"
      echo '```'"$ext"
      cat "$file"
      echo "" # Ensure newline before closing block
      echo '```'
      echo ""
    } >> "$OUTPUT_FILE"
  else
    echo "⚠️  Skipping (not found): $file"
    {
      echo "### File: $file"
      echo "> ⚠️ FILE NOT FOUND"
      echo ""
    } >> "$OUTPUT_FILE"
  fi
done

file_size=$(wc -c < "$OUTPUT_FILE" | tr -d ' ')
echo ""
echo "✅ Export complete!"
echo "📊 File: $OUTPUT_FILE"
echo "📊 Size: $file_size bytes"

# cd kordbooks-web-userfrontend

# To run this script, save it as export-project.zsh, give it execute permissions with chmod +x export-project.zsh, and then execute it with ./export-project.zsh
# ./export-project.zsh