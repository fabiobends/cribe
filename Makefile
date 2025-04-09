.PHONY: test

test:
	flutter test

# Git hooks
setup-hooks:
	@echo "Setting up Git hooks..."

	@mkdir -p .git/hooks
	@cp scripts/pre-commit .git/hooks/pre-commit
	@cp scripts/pre-push .git/hooks/pre-push
	@chmod +x .git/hooks/pre-commit .git/hooks/pre-push

	@echo "Git hooks installed successfully!"