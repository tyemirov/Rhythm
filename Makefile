SHELL := /bin/bash
.DEFAULT_GOAL := help

BUILD_DIR ?= .build
CONFIGURATION ?= Debug
TEST_TARGET ?= FlowTests
GOVERNOR_SKILL ?= $(HOME)/.codex/skills/mprlab-governor
MPRLAB_GATEWAY_EXECUTABLE ?= $(shell command -v mprlab-gateway)

.PHONY: help build run icons test test-ui lint governance docs-check privacy-check cloud-plan ci
.NOTPARALLEL: ci

help:
	@printf '%s\n' 'make build          Build Flow locally.' 'make run            Build and open Flow.' 'make test           Execute headless core and persistence tests.' 'make lint           Check project metadata and whitespace.' 'make privacy-check  Check the built privacy manifest.' 'make cloud-plan     Check the store cloud request without provider calls.' 'make governance     Check Governor guidance.' 'make docs-check     Check technical documents.' 'make ci             Execute all local checks.'
	@printf '%s\n' 'make icons          Generate the Great Wave icon assets.' 'make test-ui        Execute native application tests.'

build:
	xcodebuild -quiet -project Flow.xcodeproj -scheme Flow -configuration "$(CONFIGURATION)" -derivedDataPath "$(BUILD_DIR)/Xcode" build

run: build
	open "$(BUILD_DIR)/Xcode/Build/Products/$(CONFIGURATION)/Flow.app"

icons:
	swift scripts/generate-icons.swift

test:
	xcodebuild -quiet -project Flow.xcodeproj -scheme Flow -configuration Debug -destination 'platform=macOS' -derivedDataPath "$(BUILD_DIR)/Xcode" -only-testing:"$(TEST_TARGET)" test

test-ui:
	xcodebuild -quiet -project Flow.xcodeproj -scheme Flow -configuration Debug -destination 'platform=macOS' -derivedDataPath "$(BUILD_DIR)/Xcode" -only-testing:FlowUITests test

lint:
	plutil -lint Flow.xcodeproj/project.pbxproj
	xmllint --noout Flow.xcodeproj/xcshareddata/xcschemes/Flow.xcscheme
	git diff --check

governance:
	"$(GOVERNOR_SKILL)/scripts/normalize-mprlab" --repo "$(CURDIR)" --check --json

docs-check:
	"$(GOVERNOR_SKILL)/scripts/prepare-ste-reference" --json
	"$(GOVERNOR_SKILL)/scripts/check-ste" AGENTS.md README.md docs artwork .mprlab

privacy-check: build
	swift scripts/check-privacy.swift "$(BUILD_DIR)/Xcode/Build/Products/$(CONFIGURATION)/Flow.app"

cloud-plan:
	MPRLAB_GATEWAY_EXECUTABLE="$(MPRLAB_GATEWAY_EXECUTABLE)" /bin/sh scripts/build-macos.sh --config "$(CURDIR)/.mprlab/apple-build.json" --target macos-store --git-ref refs/heads/master --version 0.1.0 --output "$(CURDIR)/$(BUILD_DIR)/apple-store" --plan

ci: lint privacy-check test cloud-plan governance docs-check
