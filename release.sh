#!/bin/bash

function release {
  ./docker.sh build || exit 1
  ./docker.sh push || exit 1
  
  RELEASE_VERSION=$(git rev-list HEAD --first-parent --count)
  echo "Release version: ${RELEASE_VERSION}"
  
  git commit -m "version release: ${RELEASE_VERSION}" || exit 1
  git tag "v${RELEASE_VERSION}" || exit 1
  git push -u origin master --tags || exit 1
}

release

