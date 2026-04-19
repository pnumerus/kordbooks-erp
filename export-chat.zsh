#!/bin/zsh
set -e  # Exit on any error

# ==========================================
# CONFIGURATION
# ==========================================
OUTPUT_FILE="project_chat.md"
CHAR_LIMIT=39000
# Reserve chars for pre-prompt text and markdown overhead
EFFECTIVE_LIMIT=$((CHAR_LIMIT - 10000))

# Temporary directory for handling file splits
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

FILE_LIST=(
#   ".gitignore"
  ".pre-commit-config.yaml"
  "pyproject.toml"
#   "README.md"
#   "client_portal/.gitignore"
#   "client_portal/index.html"
#   "client_portal/package.json"
#   "client_portal/README.md"
  "client_portal/src/main.ts"
#   "client_portal/src/style.css"
#   "client_portal/tsconfig.app.json"
#   "client_portal/tsconfig.json"
#   "client_portal/tsconfig.node.json"
#   "client_portal/vite.config.ts"
#   "client_portal/.vscode/extensions.json"
)

# ==========================================
# HELPER FUNCTIONS
# ==========================================

# Function to get the formatted content size of a file
get_formatted_size() {
  local content=$1
  local file_path=$2
  local ext="${file_path##*.}"
  # Estimate markdown wrapper overhead
  local header="### File: $file_path"$'\n'"\`\`\`$ext"$'\n'"\`\`\`"$'\n'
  echo $(( ${#content} + ${#header} ))
}

# ==========================================
# PRE-CALCULATION & PACKING
# ==========================================

echo "🔄 Analyzing files and calculating sizes..."

# Arrays to hold the groups of files
typeset -a chunks
typeset -a current_chunk_files
current_chunk_size=0
chunk_idx=1

# Function to save current chunk
flush_chunk() {
  if (( ${#current_chunk_files[@]} > 0 )); then
    eval "chunk_${chunk_idx}_files=(\"\${current_chunk_files[@]}\")"
    ((chunk_idx++))
    current_chunk_files=()
    current_chunk_size=0
  fi
}

for file in "${FILE_LIST[@]}"; do
  if [[ -f "$file" ]]; then
    
    # 1. Read and clean content to determine real size
    raw_content=$(sed '/^[[:space:]]*$/d' "$file")
    content_len=${#raw_content}
    
    formatted_size=$(get_formatted_size "$raw_content" "$file")

    # ---------------------------------------------------------
    # SCENARIO A: MASSIVE FILE (Needs splitting)
    # ---------------------------------------------------------
    if (( formatted_size > EFFECTIVE_LIMIT )); then
      echo "⚠️  Huge file detected: $file ($formatted_size chars). Splitting..."
      
      # Flush pending chunk
      flush_chunk

      # Calculate parts
      SPLIT_LIMIT=$((EFFECTIVE_LIMIT - 500))
      num_parts=$(( (content_len + SPLIT_LIMIT - 1) / SPLIT_LIMIT ))

      # Slice and Dice
      for (( p=1; p<=num_parts; p++ )); do
        start_idx=$(( (p-1) * SPLIT_LIMIT + 1 ))
        end_idx=$(( p * SPLIT_LIMIT ))
        
        # Zsh string slicing is 1-based [start, end]
        sub_content="${raw_content[$start_idx,$end_idx]}"
        
        # Create a temp file
        split_name="$(basename "$file").__split__${p}_${num_parts}"
        split_path="$TEMP_DIR/$split_name"
        
        echo "$sub_content" > "$split_path"
        
        # Add to its OWN exclusive chunk
        # Format: SPLIT|OriginalPath|TempPath|PartNum|TotalParts
        eval "chunk_${chunk_idx}_files=(\"SPLIT|$file|$split_path|$p|$num_parts\")"
        ((chunk_idx++))
      done

    # ---------------------------------------------------------
    # SCENARIO B: NORMAL FILE
    # ---------------------------------------------------------
    else
      # Check if adding this file exceeds remaining space
      if (( (current_chunk_size + formatted_size) > EFFECTIVE_LIMIT )); then
        flush_chunk
      fi

      current_chunk_files+=("$file")
      ((current_chunk_size += formatted_size))
    fi

  else
    echo "⚠️  Skipping (not found): $file"
  fi
done

# Save the last chunk if it has files
flush_chunk

# Adjust total parts count
TOTAL_PARTS=$((chunk_idx - 1))

echo "📊 Total Content Split into $TOTAL_PARTS prompt(s)."

# ==========================================
# GENERATION & COPYING
# ==========================================

for (( i=1; i<=TOTAL_PARTS; i++ )); do
  # Retrieve files for this chunk
  files_var="chunk_${i}_files"
  current_files=("${(@P)files_var}")

  # Clear/Init output file for this part
  : > "$OUTPUT_FILE"

  # 1. GENERATE PROMPT HEADER
  {
    echo "I am providing code context for my upcoming query. Please ingest and analyze the files below."
    
    if (( TOTAL_PARTS == 1 )); then
      echo "**Instruction:** If this context provides sufficient information for you to generate a complete solution, then proceed. However, if you identify missing imports, types, or dependencies that are critical to the solution, please list exactly which additional files or definitions you need me to provide next instead of guessing."
    
    elif (( i < TOTAL_PARTS )); then
      echo "**Instruction:** This is part [$i/$TOTAL_PARTS] of the code. Do NOT generate a solution yet. Just ingest the files and confirm. I will provide the remaining parts in the next $((TOTAL_PARTS - i)) prompt(s)."
    
    else
      echo "**Instruction:** This is the final part [$i/$TOTAL_PARTS] of the code exports. You may now fully analyze all the code provided and generate a response. If this context provides sufficient information for you to generate a complete solution, then proceed. However, if you identify missing imports, types, or dependencies that are critical to the solution, please list exactly which additional files or definitions you need me to provide next instead of guessing."
    fi
    
    echo ""
    echo "## File Contents"
    echo ""
  } >> "$OUTPUT_FILE"

  # 2. ADD FILES
  for item in "${current_files[@]}"; do
    
    # Check if this is a SPLIT instruction (QUOTED FIX HERE)
    if [[ "$item" == "SPLIT|"* ]]; then
      
      # Safer Zsh array splitting
      # s/|/ splits the string by |
      local -a parts
      parts=("${(@s/|/)item}")
      
      # Zsh arrays are 1-based
      # 1=SPLIT, 2=OriginalPath, 3=TempPath, 4=PartNum, 5=TotalParts
      local original_path="${parts[2]}"
      local temp_path="${parts[3]}"
      local part_num="${parts[4]}"
      local total_parts="${parts[5]}"
      
      echo "   📄 Adding Huge File Part: $(basename "$original_path") [$part_num/$total_parts]"
      ext="${original_path##*.}"
      
      {
        echo "### File: $original_path (Part $part_num of $total_parts)"
        echo '```'"$ext"
        cat "$temp_path"
        echo ""
        echo '```'
        echo "" 
      } >> "$OUTPUT_FILE"

    else
      # NORMAL FILE
      file="$item"
      echo "   📄 Adding: $file"
      ext="${file##*.}"
      {
        echo "### File: $file"
        echo '```'"$ext"
        sed '/^[[:space:]]*$/d' "$file"
        echo ""
        echo '```'
        echo "" 
      } >> "$OUTPUT_FILE"
    fi
  done

  # 3. STATS
  char_count=$(wc -m < "$OUTPUT_FILE" | tr -d ' ')
  echo "✅ Part $i/$TOTAL_PARTS Ready! ($char_count chars)"

  # 4. COPY TO CLIPBOARD
  if command -v pbcopy &> /dev/null; then
    pbcopy < "$OUTPUT_FILE"
    echo "📋 Copied Part $i to clipboard!"
  else
    echo "❌ 'pbcopy' not found. Please copy contents of $OUTPUT_FILE manually."
  fi

  # 5. WAIT FOR USER (If not the last part)
  if (( i < TOTAL_PARTS )); then
    echo ""
    echo "👉 Paste this into the chat."
    
    # Loop indefinitely until 'n' is pressed
    while true; do
      read -k 1 "key?⌨️  Press 'n' to generate and copy Part $((i+1))... "
      echo "" 
      
      if [[ "$key" == "n" ]]; then
        break
      fi
    done
  fi

done

echo "🎉 All parts exported and copied!"
