VERSION := $(shell cat VERSION.txt)

.PHONY: install uninstall release check-version build

check-version:
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make release VERSION=x.y.z"; \
		exit 1; \
	fi
	@CURRENT_VERSION=$$(cat VERSION.txt); \
	if ! echo "$$CURRENT_VERSION\n$(VERSION)" | sort -C -V; then \
		echo "Error: New version ($(VERSION)) must be greater than current version ($$CURRENT_VERSION)"; \
		exit 1; \
	fi

build:
	pip install build
	python -m build

release: check-version
	@if git diff-index --quiet HEAD --; then \
		VERSION_TAG="v$(VERSION)"; \
		echo "$(VERSION)" > VERSION.txt; \
		sed -i '' "s/version = \".*\"/version = \"$(VERSION)\"/" pyproject.toml; \
		sed -i '' "s|/tags/v.*\.tar\.gz|/tags/$$VERSION_TAG.tar.gz|" Formula/lsdir.rb; \
		git add VERSION.txt pyproject.toml Formula/lsdir.rb; \
		git commit -m "Bump version to $(VERSION)"; \
		git tag -a $$VERSION_TAG -m "Release $$VERSION_TAG"; \
		git push origin main; \
		git push origin $$VERSION_TAG; \
		sleep 2; \
		SHA256=$$(curl -L "https://github.com/sodium-hydroxide/lsdir/archive/refs/tags/$$VERSION_TAG.tar.gz" | shasum -a 256 | awk '{print $$1}'); \
		sed -i '' "s/sha256 \".*\"/sha256 \"$$SHA256\"/" Formula/lsdir.rb; \
		git add Formula/lsdir.rb; \
		git commit -m "Update SHA256 for $$VERSION_TAG"; \
		git push origin main; \
		echo "Release $$VERSION_TAG complete!"; \
		echo "SHA256: $$SHA256"; \
	else \
		echo "Error: Working directory not clean. Commit changes first."; \
		exit 1; \
	fi
