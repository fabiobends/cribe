#!/bin/bash

# Coverage requirement
MINIMUM_COVERAGE=80

# Check coverage requirements
failed_files=$(grep -E "^SF:|^LF:|^LH:" coverage/lcov.info | paste - - - | awk -F'\t' -v min_cov="$MINIMUM_COVERAGE" '
{
    sf=$1; lf=$2; lh=$3;
    gsub("SF:", "", sf);
    gsub("LF:", "", lf);
    gsub("LH:", "", lh);
    
    if(lf > 0) {
        coverage = (lh/lf)*100;
        if(coverage < min_cov) {
            print sf " " coverage;
        }
    }
}')

if [ -n "$failed_files" ]; then
    echo "❌ Coverage below ${MINIMUM_COVERAGE}% detected:"
    echo "$failed_files" | while read file coverage; do
        printf "   %-60s (%.1f%%)\n" "$file" "$coverage"
    done
    echo ""
    echo "💡 Files in lib/core/, logger_service.dart, and feature_flags_provider.dart are excluded from coverage requirements"
    exit 1
else
    echo "✅ All files meet ${MINIMUM_COVERAGE}% coverage requirement (excluding lib/core/ files and data exceptions)"
fi