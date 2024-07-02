PRODUCT_NAME := BusdesNativeiOS
PROJECT_NAME := ${PRODUCT_NAME}.xcodeproj
SCHEME_NAME := ${PRODUCT_NAME}

.DEFAULT_GOAL := help

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?# .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":[^#]*? #| #"}; {printf "%-42s%s\n", $$1 $$3, $$2}'

.PHONY: setup
setup: # Install tools
	$(MAKE) install-mint
	$(MAKE) xcodegen
	$(MAKE) open

.PHONY: install-mint
install-mint: # Install Mint dependencies
	brew install mint
	mint bootstrap
		
.PHONY: xcodegen
xcodegen: # Generate Xcode project with xcodegen
	mint run xcodegen

.PHONY: open
open: # Open workspace in Xcode
	open ./${PROJECT_NAME}

.PHONY: clean
clean: # Delete cache
	xcodebuild clean -project ${PROJECT_NAME}
