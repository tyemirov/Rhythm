SHELL := /bin/bash
.DEFAULT_GOAL := help

BUILD_DIR ?= .build
CONFIGURATION ?= Debug
GOVERNOR_SKILL ?= $(HOME)/.codex/skills/mprlab-governor

.PHONY: help build run test lint governance docs-check ci
.NOTPARALLEL: ci

help:
	@printf '%s\n' 'make build       Build Rhythm locally.' 'make run         Build and open Rhythm.' 'make test        Execute core tests.' 'make lint        Check project metadata and whitespace.' 'make governance  Check Governor guidance.' 'make docs-check  Check technical documents.' 'make ci          Execute all local checks.'

build:
	xcodebuild -quiet -project Rhythm.xcodeproj -scheme Rhythm -configuration "$(CONFIGURATION)" -derivedDataPath "$(BUILD_DIR)/Xcode" build

run: build
	open "$(BUILD_DIR)/Xcode/Build/Products/$(CONFIGURATION)/Rhythm.app"

test:
	xcodebuild -quiet -project Rhythm.xcodeproj -scheme Rhythm -configuration Debug -destination 'platform=macOS' -derivedDataPath "$(BUILD_DIR)/Xcode" test

lint:
	plutil -lint Rhythm.xcodeproj/project.pbxproj
	xmllint --noout Rhythm.xcodeproj/xcshareddata/xcschemes/Rhythm.xcscheme
	git diff --check

governance:
	"$(GOVERNOR_SKILL)/scripts/normalize-mprlab" --repo "$(CURDIR)" --check --json

docs-check:
	"$(GOVERNOR_SKILL)/scripts/prepare-ste-reference" --json
	"$(GOVERNOR_SKILL)/scripts/check-ste" AGENTS.md README.md docs .mprlab

ci: lint build test governance docs-check
