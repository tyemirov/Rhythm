SHELL := /bin/bash
.DEFAULT_GOAL := help

BUILD_DIR ?= .build
CONFIGURATION ?= Debug
TEST_TARGET ?= RhythmTests
GOVERNOR_SKILL ?= $(HOME)/.codex/skills/mprlab-governor
MPRLAB_GATEWAY_EXECUTABLE ?= $(shell command -v mprlab-gateway)

.PHONY: help build run test test-ui lint governance docs-check privacy-check cloud-plan ci
.NOTPARALLEL: ci

help:
	@printf '%s\n' 'make build          Build Rhythm locally.' 'make run            Build and open Rhythm.' 'make test           Execute headless core and persistence tests.' 'make lint           Check project metadata and whitespace.' 'make privacy-check  Check the built privacy manifest.' 'make cloud-plan     Check the store cloud request without provider calls.' 'make governance     Check Governor guidance.' 'make docs-check     Check technical documents.' 'make ci             Execute all local checks.'
	@printf '%s\n' 'make test-ui        Execute native application tests.'

build:
	xcodebuild -quiet -project Rhythm.xcodeproj -scheme Rhythm -configuration "$(CONFIGURATION)" -derivedDataPath "$(BUILD_DIR)/Xcode" build

run: build
	open "$(BUILD_DIR)/Xcode/Build/Products/$(CONFIGURATION)/Rhythm.app"

test:
	xcodebuild -quiet -project Rhythm.xcodeproj -scheme Rhythm -configuration Debug -destination 'platform=macOS' -derivedDataPath "$(BUILD_DIR)/Xcode" -only-testing:"$(TEST_TARGET)" test

test-ui:
	xcodebuild -quiet -project Rhythm.xcodeproj -scheme Rhythm -configuration Debug -destination 'platform=macOS' -derivedDataPath "$(BUILD_DIR)/Xcode" -only-testing:RhythmUITests test

lint:
	plutil -lint Rhythm.xcodeproj/project.pbxproj
	xmllint --noout Rhythm.xcodeproj/xcshareddata/xcschemes/Rhythm.xcscheme
	git diff --check

governance:
	"$(GOVERNOR_SKILL)/scripts/normalize-mprlab" --repo "$(CURDIR)" --check --json

docs-check:
	"$(GOVERNOR_SKILL)/scripts/prepare-ste-reference" --json
	"$(GOVERNOR_SKILL)/scripts/check-ste" AGENTS.md README.md docs .mprlab

privacy-check: build
	swift scripts/check-privacy.swift "$(BUILD_DIR)/Xcode/Build/Products/$(CONFIGURATION)/Rhythm.app"

cloud-plan:
	MPRLAB_GATEWAY_EXECUTABLE="$(MPRLAB_GATEWAY_EXECUTABLE)" /bin/sh scripts/build-macos.sh --config "$(CURDIR)/.mprlab/apple-build.json" --target macos-store --source-commit "$$(git rev-parse HEAD)" --git-ref refs/heads/master --version 0.1.0 --output "$(CURDIR)/$(BUILD_DIR)/apple-store" --plan

ci: lint privacy-check test cloud-plan governance docs-check
