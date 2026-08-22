# Local tooling for arorasunil.com
#
# macOS system Ruby (2.6) is too old for the pinned Jekyll, so put Homebrew's
# Ruby ahead of it on PATH. Everything below runs through bundler.

RUBY_PREFIX := $(shell brew --prefix ruby 2>/dev/null)
ifneq ($(RUBY_PREFIX),)
export PATH := $(RUBY_PREFIX)/bin:$(PATH)
endif

BUNDLE := bundle
PORT ?= 4000

.DEFAULT_GOAL := help
.PHONY: help install serve build clean new publish check

help: ## Show this help
	@grep -hE '^[a-z-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk -F':.*?## ' '{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo '  make new title="Some Post"        create a draft'
	@echo '  make publish post=_drafts/x.md    move a draft into _posts'

install: ## Install gems into vendor/bundle
	$(BUNDLE) config set --local path vendor/bundle
	$(BUNDLE) install

serve: ## Preview at localhost:4000, drafts included
	$(BUNDLE) exec jekyll serve --drafts --livereload --port $(PORT)

build: ## Build the site into _site/ the way GitHub Pages will
	JEKYLL_ENV=production $(BUNDLE) exec jekyll build

clean: ## Remove build output
	rm -rf _site .jekyll-cache

check: build ## Build and fail on Liquid warnings (catches Hugo shortcode leftovers)
	@if grep -rlE '\{\{[<%]' _archive _posts _drafts 2>/dev/null | grep .; then \
		echo "ERROR: Hugo shortcodes above are not valid Liquid"; exit 1; \
	fi
	@echo "OK: no stray Hugo shortcodes"

new: ## Create a draft (see: make new title="...")
	@test -n "$(title)" || { echo 'usage: make new title="My Post"'; exit 1; }
	@slug=$$(echo "$(title)" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$$//g'); \
	f="_drafts/$$slug.md"; \
	if [ -e "$$f" ]; then echo "already exists: $$f"; exit 1; fi; \
	mkdir -p _drafts; \
	printf -- '---\nlayout: post\ntitle: "%s"\ncategories: \n---\n\n' "$(title)" > "$$f"; \
	echo "created $$f"

publish: ## Move a draft into _posts with today's date (see: make publish post=...)
	@test -n "$(post)" || { echo 'usage: make publish post=_drafts/my-post.md'; exit 1; }
	@test -f "$(post)" || { echo "no such file: $(post)"; exit 1; }
	@d=$$(date +%Y-%m-%d); b=$$(basename "$(post)"); \
	mkdir -p _posts; \
	git mv "$(post)" "_posts/$$d-$$b" && echo "published _posts/$$d-$$b"
