#!/bin/bash

# Coverage requirement
MINIMUM_COVERAGE=80

# Patterns to exclude from coverage requirements
EXCLUDE_PATTERNS=(
    "lib/core/"
    "lib/main.dart"
    "lib/data/services/logger_service.dart"
    "lib/data/providers/feature_flags_provider.dart"
    "lib/ui/dev_helper/"
    "/fake_"
    "/base_"
    ".g.dart"
    ".freezed.dart"
)

# Function to check if a file should be excluded
should_exclude() {
    local file="$1"
    
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        if [[ "$file" == *"$pattern"* ]]; then
            return 0
        fi
    done
    return 1
}

# Get all Dart files in lib/ (excluding test files and generated files)
all_dart_files=$(find lib -name "*.dart" -not -name "*_test.dart" -not -name "*.g.dart" -not -name "*.freezed.dart" | sort)

# Create temporary file for coverage data
temp_coverage=$(mktemp)
grep -E "^SF:|^LF:|^LH:" coverage/lcov.info | paste - - - > "$temp_coverage"

# Track untested and low coverage files
untested_count=0
low_coverage_count=0
untested_list=""
low_coverage_list=""

# Check each Dart file
for file in $all_dart_files; do
    # Skip excluded files
    if should_exclude "$file"; then
        continue
    fi
    
    # Check if file is in coverage report
    coverage_line=$(grep "^SF:$file	" "$temp_coverage")
    
    if [ -z "$coverage_line" ]; then
        # File not in coverage report
        untested_list="${untested_list}${file}\n"
        ((untested_count++))
    else
        # Extract coverage percentage
        lf=$(echo "$coverage_line" | awk -F'\t' '{print $2}' | sed 's/LF://')
        lh=$(echo "$coverage_line" | awk -F'\t' '{print $3}' | sed 's/LH://')
        
        if [ "$lf" -gt 0 ]; then
            coverage=$(awk "BEGIN {printf \"%.1f\", ($lh/$lf)*100}")
            
            # Check if coverage is below threshold
            if [ $(echo "$coverage < $MINIMUM_COVERAGE" | bc) -eq 1 ]; then
                low_coverage_list="${low_coverage_list}${file}:${coverage}\n"
                ((low_coverage_count++))
            fi
        fi
    fi
done

# Cleanup
rm "$temp_coverage"

# Report results
has_errors=0

if [ $untested_count -gt 0 ]; then
    echo "❌ Files without any test coverage ($untested_count files):"
    echo -e "$untested_list" | while read -r file; do
        if [ -n "$file" ]; then
            printf "   %-60s (0.0%%)\n" "$file"
        fi
    done
    echo ""
    has_errors=1
fi

if [ $low_coverage_count -gt 0 ]; then
    echo "❌ Files with coverage below ${MINIMUM_COVERAGE}% ($low_coverage_count files):"
    echo -e "$low_coverage_list" | while read -r entry; do
        if [ -n "$entry" ]; then
            file=$(echo "$entry" | cut -d':' -f1)
            coverage=$(echo "$entry" | cut -d':' -f2)
            printf "   %-60s (%.1f%%)\n" "$file" "$coverage"
        fi
    done
    echo ""
    has_errors=1
fi

if [ $has_errors -eq 0 ]; then
    echo "✅ All files meet ${MINIMUM_COVERAGE}% coverage requirement"
    echo "💡 Excluded: lib/core/, main.dart, logger_service.dart, feature_flags_provider.dart, dev_helper/, fake_*, and base_* files"
else
    echo "💡 Excluded: lib/core/, main.dart, logger_service.dart, feature_flags_provider.dart, dev_helper/, fake_*, and base_* files"
    exit 1
fi