#!/bin/bash

# Remove excluded files from coverage report
lcov --remove coverage/lcov.info 'lib/core/*' '*/logger_service.dart' '*/feature_flags_provider.dart' -o coverage/lcov.info

# Generate coverage summary from lcov.info
grep -E "^SF:|^LF:|^LH:" coverage/lcov.info | paste - - - | awk -F'\t' '
{
    sf=$1; lf=$2; lh=$3;
    gsub("SF:", "", sf);
    gsub("LF:", "", lf);
    gsub("LH:", "", lh);
    
    if(lf > 0) {
        coverage = (lh/lf)*100;
        printf "%-60s %3s/%3s (%5.1f%%)\n", sf, lh, lf, coverage;
    }
}' | sort -k3 -n

echo "📊 Coverage data generated at coverage/lcov.info"

# Generate HTML coverage report using genhtml
if command -v genhtml >/dev/null 2>&1; then
    echo "📊 Generating HTML coverage report..."
    genhtml coverage/lcov.info -o coverage/html
    echo "📊 HTML coverage report generated at coverage/html/index.html"
else
    echo "💡 To generate HTML coverage reports, install lcov: brew install lcov"
fi