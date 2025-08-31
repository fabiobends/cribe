.PHONY: test format-fix

test:
	flutter test

# Format and fix all Dart code
format-fix:
	@echo "🎨 Formatting and fixing Dart code..."
	@scripts/format-and-fix

# Git hooks
setup-hooks:
	@echo "Setting up Git hooks..."

	@mkdir -p .git/hooks
	@cp scripts/pre-commit .git/hooks/pre-commit
	@cp scripts/pre-push .git/hooks/pre-push
	@chmod +x .git/hooks/pre-commit .git/hooks/pre-push

	@echo "Git hooks installed successfully!"