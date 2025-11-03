.PHONY: test format-fix

test:
	@echo "🧪 Running tests with coverage..."
	@flutter test --coverage
	@echo "📊 Coverage summary:"
	@scripts/coverage-summary.sh
	@echo "🔍 Checking coverage requirements..."
	@scripts/coverage-check.sh
	@if command -v genhtml >/dev/null 2>&1; then \
		echo "📊 Generating HTML coverage report..."; \
		genhtml coverage/lcov.info -o coverage/html; \
		echo "✅ Tests completed! Coverage report available at coverage/html/index.html"; \
	else \
		echo "💡 To generate HTML coverage reports, install lcov: brew install lcov"; \
		echo "✅ Tests completed! Coverage data available at coverage/lcov.info"; \
	fi

view-coverage:
	@if [ -f coverage/html/index.html ]; then \
		open coverage/html/index.html; \
	else \
		echo "❌ HTML coverage report not found. Please run 'make test' first."; \
	fi

# Format and fix all Dart code
format-fix:
	@echo "🎨 Formatting and fixing Dart code..."
	@echo "📝 Formatting all Dart files..."
	@dart format .
	@echo "🔧 Applying automatic fixes..."
	@dart fix --apply
	@echo "🔍 Running analysis..."
	@flutter analyze
	@echo "✅ All checks passed!"
	@echo "🎉 Code is ready!"

# Git hooks
setup-hooks:
	@echo "Setting up Git hooks..."

	@mkdir -p .git/hooks
	@cp scripts/pre-commit .git/hooks/pre-commit
	@cp scripts/pre-push .git/hooks/pre-push
	@chmod +x .git/hooks/pre-commit .git/hooks/pre-push

	@echo "Git hooks installed successfully!"