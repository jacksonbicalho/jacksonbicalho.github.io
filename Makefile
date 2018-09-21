SHELL := /bin/bash
NPM := npm
VENDOR_DIR_CSS = assets/vendor/css/
VENDOR_DIR_JS = assets/vendor/js/
JEKYLL := jekyll

PROJECT_DEPS := package.json

.PHONY: all clean install update

all : serve

check:
	$(JEKYLL) doctor
	$(HTMLPROOF) --check-html \
		--http-status-ignore 999 \
		--internal-domains localhost:4000 \
		--assume-extension \
		_site

install: $(PROJECT_DEPS)
	$(NPM) install

update: $(PROJECT_DEPS)
	$(NPM) update

include-npm-deps:
	# mkdir -p $(VENDOR_DIR_CSS)
	# cp node_modules/bootstrap/dist/css/bootstrap.min.css $(VENDOR_DIR_CSS)
	mkdir -p $(VENDOR_DIR_JS)
	cp node_modules/jquery-slim/dist/jquery.slim.min.js $(VENDOR_DIR_JS)
	cp node_modules/jquery-slim/dist/jquery.slim.min.js $(VENDOR_DIR_JS)

build: include-npm-deps
	$(JEKYLL) build

serve: include-npm-deps
	JEKYLL_ENV=production $(JEKYLL) serve
