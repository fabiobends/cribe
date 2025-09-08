.PHONY: test format-fix

test:
	flutter test

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