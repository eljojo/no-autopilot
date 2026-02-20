.PHONY: bump-patch bump-minor bump-major update-major-tag

# Bump version tags and update the major version pointer.
# Users pin to @v1 (moving tag) or @v1.2.3 (immutable tag).
#
# Usage:
#   make bump-patch    # v1.0.0 -> v1.0.1, updates v1 tag
#   make bump-minor    # v1.0.1 -> v1.1.0, updates v1 tag
#   make bump-major    # v1.1.0 -> v2.0.0, updates v2 tag

bump-patch:
	@git fetch --tags; \
	current=$$(git describe --tags --match 'v*.*.*' --abbrev=0 2>/dev/null || echo "v0.0.0"); \
	major=$$(echo $$current | cut -d. -f1 | tr -d v); \
	minor=$$(echo $$current | cut -d. -f2); \
	patch=$$(echo $$current | cut -d. -f3); \
	new="v$$major.$$minor.$$((patch + 1))"; \
	echo "Bumping $$current -> $$new"; \
	git tag -a $$new -m "Release $$new"; \
	git push origin $$new; \
	echo "Updating v$$major tag"; \
	git tag -f "v$$major" $$new; \
	git push origin "v$$major" --force

bump-minor:
	@git fetch --tags; \
	current=$$(git describe --tags --match 'v*.*.*' --abbrev=0 2>/dev/null || echo "v0.0.0"); \
	major=$$(echo $$current | cut -d. -f1 | tr -d v); \
	minor=$$(echo $$current | cut -d. -f2); \
	new="v$$major.$$((minor + 1)).0"; \
	echo "Bumping $$current -> $$new"; \
	git tag -a $$new -m "Release $$new"; \
	git push origin $$new; \
	echo "Updating v$$major tag"; \
	git tag -f "v$$major" $$new; \
	git push origin "v$$major" --force

bump-major:
	@git fetch --tags; \
	current=$$(git describe --tags --match 'v*.*.*' --abbrev=0 2>/dev/null || echo "v0.0.0"); \
	major=$$(echo $$current | cut -d. -f1 | tr -d v); \
	new="v$$((major + 1)).0.0"; \
	echo "Bumping $$current -> $$new"; \
	git tag -a $$new -m "Release $$new"; \
	git push origin $$new; \
	echo "Updating v$$((major + 1)) tag"; \
	git tag -f "v$$((major + 1))" $$new; \
	git push origin "v$$((major + 1))" --force
