# A Makefile template for Go projects.
# Heavily modified version of:
# https://about.gitlab.com/blog/2017/11/27/go-tools-and-gitlab-how-to-do-continuous-integration-like-a-boss/

# Edit those lines to fit your project
PROJECT_NAME := "project-name"
PKG := "package-path/${PROJECT_NAME}"
OUT := "${PROJECT_NAME}.out"

LINTER := golint
LINTER_FLAGS := -set_exit_status
LINT := ${LINTER} ${LINTER_FLAGS}
FORMATTER := gofmt
FORMATTER_FLAGS := -l -s -w
$FORMAT := ${FORMATTER} ${FORMATTER_FLAGS}

PKG_LIST := $(shell go list ${PKG}/... | grep -v '/vendor/')
COVERAGE_FILE := "${PKG}/coverage.out"
VENDOR := "./vendor"
GO_FILES := $(shell find -O3 . -path ${VENDOR} -prune -o -name '*.go' -print | grep -v _test.go)
TEST_FILES := $(shell find -O3 . -path ${VENDOR} -prune -o -name '*_test.go' -print)

.PHONY: all lint lint-all format fmt format-all fmt-all test-short unit-short test unit race-short race msan-short msan coverage cover heatmap heat report-coverage report report-browser report-html dep deps build force-build force clean help

all: build

lint:	# Lint the source files
	@${LINT} ${GO_FILES}

lint-all:	# Lint all the files, code and tests
	@${LINT} ${GO_FILES}
	@${LINT} ${TEST_FILES}

format fmt:	# Format the source files
	@${FORMAT} ${GO_FILES}

format-all fmt-all:	# Format all the files, code and tests
	@${FORMAT} ${GO_FILES}
	@${FORMAT} ${TEST_FILES}

test-short unit-short:	# Run the short suite of unittests
	@go test -v -short ${PKG_LIST}

test unit:	# Run the normal suite of unitests
	@go test -v ${PKG_LIST}

race-short: dep	# Run the data race detector on the short suite of tests
	@go test -v -race -short ${PKG_LIST}

race: dep	# Run the data race detector
	@go test -v -race ${PKG_LIST}

msan-short: dep	# Run the memory sanitizer on the short suite of tests
	@go test -v -msan -short @{PKG_LIST}

msan: dep	# Run the memory sanitizer
	@go test -v -msan @{PKG_LIST}

coverage cover:	# Generate global code coverage report
	@go test -coverprofile="${COVERAGE_FILE}"

heatmap heat:	# Generate global heat map for code coverage
	@go test -covermode=count -coverprofile="${COVERAGE_FILE}"

report-coverage report:	# Print the coverage report on a per function basis
	@go tool cover -func="${COVERAGE_FILE}"

report-browser report-html:	# Display the coverage report on the browser
	@go tool cover -html="${COVERAGE_FILE}"

dep deps:	# Get the dependencies
	@go get -v -d ./...

build: dep	# Build the binary file
	@go build -o ${OUT} -i -v ${PKG}

force-build force: dep	# Re-build the entire project
	@go build -i -v -a ${PKG}

clean:	# Remove previous build
	@rm -f ${PROJECT_NAME}

help:	# Display a list of all the targets
	@grep -h -E '^[a-z_-]+[: ]' ${MAKEFILE_LIST} | awk 'BEGIN {FS = ":.*?"}; {printf "\033[36m%-30s\033[0m\n", $$1}'
