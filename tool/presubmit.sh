#!/bin/bash

# Make sure dartfmt is run on everything
# This assumes you have dart_style as a dev_dependency
echo "Checking dartfmt..."
if [ "$TRAVIS_DART_VERSION" = "stable" ]; then
  NEEDS_DARTFMT="$(find lib test -name "*.dart" | xargs dartfmt -n)"
  if [[ ${NEEDS_DARTFMT} != "" ]]
  then
    echo "FAILED"
    echo "${NEEDS_DARTFMT}"
    exit 1
  fi
  echo "PASSED"
else
  echo "SKIPPED"
fi

# Make sure we pass the analyzer
echo "Checking dartanalyzer..."
FAILS_ANALYZER="$(find lib test -name "*.dart" | xargs dartanalyzer --options .analysis_options)"
if [[ $FAILS_ANALYZER == *"[error]"* ]]
then
  echo "FAILED"
  echo "${FAILS_ANALYZER}"
  exit 1
fi
echo "PASSED"

# Fail on anything that fails going forward.
set -e

pub run test
