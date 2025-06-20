#!/bin/bash
# Comprehensive Error Detection for NeuroVision

PROJECT_ROOT="/Users/gagelaporta/Desktop/NeuroVision-Repo"
OUTPUT_FILE="$PROJECT_ROOT/error_report_$(date +%Y%m%d_%H%M%S).txt"

echo "NeuroVision Comprehensive Error Report" > "$OUTPUT_FILE"
echo "Generated: $(date)" >> "$OUTPUT_FILE"
echo "========================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Function to add section header
add_section() {
    echo "" >> "$OUTPUT_FILE"
    echo "=== $1 ===" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
}

# 1. GDScript Syntax Errors
add_section "GDScript Syntax Issues"
echo "Checking for Python-style syntax..." >> "$OUTPUT_FILE"
find "$PROJECT_ROOT" -name "*.gd" -type f | while read file; do
    if grep -n "try:\|except:\|finally:" "$file" > /dev/null 2>&1; then
        echo "File: $file" >> "$OUTPUT_FILE"
        grep -n "try:\|except:\|finally:" "$file" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
done

# 2. Missing Node References
add_section "Potential Missing Node References"
echo "Checking for get_node calls..." >> "$OUTPUT_FILE"
find "$PROJECT_ROOT" -name "*.gd" -type f | while read file; do
    if grep -n 'get_node("' "$file" | grep -v "get_node_or_null" > /dev/null 2>&1; then
        echo "File: $file" >> "$OUTPUT_FILE"
        grep -n 'get_node("' "$file" | grep -v "get_node_or_null" | head -10 >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
done

# 3. Resource Loading Issues
add_section "Resource Loading Without Validation"
echo "Checking for unvalidated resource loads..." >> "$OUTPUT_FILE"
find "$PROJECT_ROOT" -name "*.gd" -type f | while read file; do
    if grep -n 'load("res://' "$file" | grep -v "ResourceLoader.exists" > /dev/null 2>&1; then
        echo "File: $file" >> "$OUTPUT_FILE"
        grep -n 'load("res://' "$file" | grep -v "ResourceLoader.exists" | head -10 >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
done

# 4. Signal Connection Issues
add_section "Signal Connections Without Error Handling"
echo "Checking for signal connections..." >> "$OUTPUT_FILE"
find "$PROJECT_ROOT" -name "*.gd" -type f | while read file; do
    if grep -n "\.connect(" "$file" | grep -v "if.*connect\|connected" > /dev/null 2>&1; then
        echo "File: $file" >> "$OUTPUT_FILE"
        grep -n "\.connect(" "$file" | grep -v "if.*connect\|connected" | head -10 >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
done

# 5. Shader Compilation Errors
add_section "Shader Issues"
echo "Checking shader files..." >> "$OUTPUT_FILE"
find "$PROJECT_ROOT" -name "*.gdshader" -type f | while read file; do
    echo "Shader: $file" >> "$OUTPUT_FILE"
    # Check for common shader issues
    grep -n "error\|ERROR\|undefined\|UNDEFINED" "$file" >> "$OUTPUT_FILE" 2>/dev/null || echo "  No obvious errors found" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
done

# 6. Scene File Issues
add_section "Scene File Validation"
echo "Checking scene files for broken dependencies..." >> "$OUTPUT_FILE"
find "$PROJECT_ROOT" -name "*.tscn" -type f | while read file; do
    # Check for missing script references
    if grep "script = ExtResource" "$file" > /dev/null 2>&1; then
        script_ids=$(grep -o 'script = ExtResource( *"[^"]*" *)' "$file" | grep -o '"[^"]*"' | tr -d '"')
        for id in $script_ids; do
            if ! grep -q "id=\"$id\"" "$file"; then
                echo "Missing script reference in: $file (ID: $id)" >> "$OUTPUT_FILE"
            fi
        done
    fi
done

# 7. Autoload Dependencies
add_section "Autoload Usage Analysis"
echo "Checking autoload dependencies..." >> "$OUTPUT_FILE"
autoloads=("UnifiedColorManager" "CoreSystemManager" "UISystemManager" "EducationalPlatformManager" "ResourceManager" "KnowledgeService" "ProgressTracker")
for autoload in "${autoloads[@]}"; do
    echo "Autoload: $autoload" >> "$OUTPUT_FILE"
    count=$(find "$PROJECT_ROOT" -name "*.gd" -type f -exec grep -l "$autoload" {} \; | wc -l)
    echo "  Used in $count files" >> "$OUTPUT_FILE"
done

# 8. Performance Concerns
add_section "Performance Concerns"
echo "Checking for potential performance issues..." >> "$OUTPUT_FILE"
find "$PROJECT_ROOT" -name "*.gd" -type f | while read file; do
    # Check for process without delta usage
    if grep -n "func _process(" "$file" | grep -A 10 "_process" | grep -v "delta" > /dev/null 2>&1; then
        echo "Unused delta in _process: $file" >> "$OUTPUT_FILE"
    fi
    
    # Check for heavy operations in _ready
    if grep -n "func _ready(" "$file" | grep -A 20 "_ready" | grep -E "for.*in.*range\(.*[0-9]{3,}" > /dev/null 2>&1; then
        echo "Heavy loop in _ready: $file" >> "$OUTPUT_FILE"
    fi
done

# 9. Memory Leaks
add_section "Potential Memory Leaks"
echo "Checking for potential memory leaks..." >> "$OUTPUT_FILE"
find "$PROJECT_ROOT" -name "*.gd" -type f | while read file; do
    # Check for new() without queue_free()
    new_count=$(grep -c "\.new()" "$file" 2>/dev/null || echo 0)
    free_count=$(grep -c "queue_free\|free()" "$file" 2>/dev/null || echo 0)
    if [ "$new_count" -gt "$free_count" ]; then
        echo "File: $file - new() calls: $new_count, free() calls: $free_count" >> "$OUTPUT_FILE"
    fi
done

# 10. TODO and FIXME Comments
add_section "TODO/FIXME Comments"
echo "Finding TODO and FIXME comments..." >> "$OUTPUT_FILE"
find "$PROJECT_ROOT" -name "*.gd" -type f | while read file; do
    if grep -n "TODO\|FIXME\|HACK\|XXX" "$file" > /dev/null 2>&1; then
        echo "File: $file" >> "$OUTPUT_FILE"
        grep -n "TODO\|FIXME\|HACK\|XXX" "$file" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
done

# Summary
add_section "Summary"
echo "Total GDScript files: $(find "$PROJECT_ROOT" -name "*.gd" -type f | wc -l)" >> "$OUTPUT_FILE"
echo "Total scenes: $(find "$PROJECT_ROOT" -name "*.tscn" -type f | wc -l)" >> "$OUTPUT_FILE"
echo "Total shaders: $(find "$PROJECT_ROOT" -name "*.gdshader" -type f | wc -l)" >> "$OUTPUT_FILE"
echo "Total resources: $(find "$PROJECT_ROOT" -name "*.tres" -type f | wc -l)" >> "$OUTPUT_FILE"

echo ""
echo "Error report generated: $OUTPUT_FILE"
echo "Opening in default editor..."
open "$OUTPUT_FILE"