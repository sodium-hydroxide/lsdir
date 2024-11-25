VERSION := $(shell cat VERSION.txt)
.PHONY: install uninstall release check-version build check-formula

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

check-formula:
	@echo "Verifying python-magic SHA256..."
	@MAGIC_SHA256=$$(curl -L "https://files.pythonhosted.org/packages/da/db/0b3e28ac047452d079d375ec6798bf76a036a08182dbb39ed38116a49130/python-magic-0.4.27.tar.gz" | shasum -a 256 | awk '{print $$1}'); \
	if ! grep -q "$$MAGIC_SHA256" Formula/lsdir.rb; then \
		echo "Updating python-magic SHA256..."; \
		sed -i '' "s/sha256 \".*\"/sha256 \"$$MAGIC_SHA256\"/" Formula/lsdir.rb; \
		git add Formula/lsdir.rb; \
		git commit -m "Update python-magic SHA256"; \
	fi

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
		echo "Waiting for GitHub to process the new tag..."; \
		sleep 5; \
		PACKAGE_SHA256=$$(curl -L "https://github.com/sodium-hydroxide/lsdir/archive/refs/tags/$$VERSION_TAG.tar.gz" | shasum -a 256 | awk '{print $$1}'); \
		echo "New package SHA256: $$PACKAGE_SHA256"; \
		MAGIC_SHA256=$$(curl -L "https://files.pythonhosted.org/packages/da/db/0b3e28ac047452d079d375ec6798bf76a036a08182dbb39ed38116a49130/python-magic-0.4.27.tar.gz" | shasum -a 256 | awk '{print $$1}'); \
		if [ "$$PACKAGE_SHA256" = "$$MAGIC_SHA256" ]; then \
			echo "Error: Package SHA256 matches python-magic SHA256. This is likely an error."; \
			exit 1; \
		fi; \
		sed -i '' "/url.*lsdir.*tar\.gz/,/sha256/ s/sha256 \".*\"/sha256 \"$$PACKAGE_SHA256\"/" Formula/lsdir.rb; \
		git add Formula/lsdir.rb; \
		git commit -m "Update package SHA256 for $$VERSION_TAG"; \
		git push origin main; \
		echo "Release $$VERSION_TAG complete!"; \
		echo "Package SHA256: $$PACKAGE_SHA256"; \
		echo "Python-magic SHA256: $$MAGIC_SHA256"; \
	else \
		echo "Error: Working directory not clean. Commit changes first."; \
		exit 1; \
	fi