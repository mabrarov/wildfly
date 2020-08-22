#!/bin/bash

set -e

# shellcheck source=travis_retry.sh
source "${TRAVIS_BUILD_DIR}/travis/travis_retry.sh"

if [[ "${MAVEN_WRAPPER}" -ne 0 ]]; then
  build_cmd="\"${TRAVIS_BUILD_DIR}/mvnw\""
else
  build_cmd="mvn"
fi

build_cmd="${build_cmd} -f "${TRAVIS_BUILD_DIR}/pom.xml" --batch-mode clean install"
maven_profiles=""

if [[ "${COVERAGE_BUILD}" -ne 0 ]]; then
  maven_profiles="${maven_profiles:+${maven_profiles},}jacoco"
fi

if ! [[ "${maven_profiles}" = "" ]]; then
  build_cmd="${build_cmd} -P \"${maven_profiles}\""
fi

build_cmd="${build_cmd}${MAVEN_BUILD_OPTIONS:+ }${MAVEN_BUILD_OPTIONS}"

echo "Building with: ${build_cmd}"
eval "${build_cmd}"

if [[ "${COPILOT_BUILD}" -ne 0 ]]; then
  bash <(curl -s https://copilot.blackducksoftware.com/ci/travis/scripts/upload)
fi
