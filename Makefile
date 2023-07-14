PLATFORM ?= iOS Simulator,name=iPhone 14 Pro Max

.PHONY: test-library
test-library:
	xcodebuild test \
		-scheme functions-swift \
		-destination platform="$(PLATFORM)"

.PHONY: format
format:
	swift format -i -r ./Sources ./Tests ./Package.swift
