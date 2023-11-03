#!/bin/bash

progname=$(basename $0)

function usage {
  cat << HEREDOC

     Usage: $progname [command]

     commands:
       patch                Release a patch version (0.0.X)
       minor                Release a minor version (0.X.0)
       major                  Release a major version (X.0.0)
       setversion <version>   Change version to <version>
       -h, --help           Show this help message and exit

HEREDOC
}

function setVersion() {
    version="$1"
    buildVersion=$(git rev-list HEAD --first-parent --count)

    npm --no-git-tag-version --allow-same-version version "${version}" || exit 1
}

function releasePatch {
  git checkout master || exit 1
  git pull || exit 1

  # Create patch version
  CURRENT_VERSION=$(sed 's/.*"version": "\(.*\)".*/\1/;t;d' ./package.json)
  RELEASE_VERSION=$(echo ${CURRENT_VERSION} | awk -F'.' '{print $1"."$2"."$3+1}')

  git merge develop || exit 1

  setVersion "${RELEASE_VERSION}" || exit 1

  pushAndRelease
}

function releaseMinor {
  git checkout master || exit 1
  git pull || exit 1
  git merge develop || exit 1

  # Create patch version
  npm --no-git-tag-version version minor || exit 1
  RELEASE_VERSION=$(sed 's/.*"version": "\(.*\)".*/\1/;t;d' ./package.json)

  setVersion "${RELEASE_VERSION}" || exit 1

  pushAndRelease
}

function releaseMajor {
  git checkout master || exit 1
  git pull || exit 1
  git merge develop || exit 1

  # Create patch version
  npm --no-git-tag-version version major || exit 1
  RELEASE_VERSION=$(sed 's/.*"version": "\(.*\)".*/\1/;t;d' ./package.json)

  setVersion "${RELEASE_VERSION}" || exit 1

  pushAndRelease
}

function pushAndRelease {
  RELEASE_VERSION=$(sed 's/.*"version": "\(.*\)".*/\1/;t;d' ./package.json)
  echo "Release version: ${RELEASE_VERSION}"

  git add package.json || exit 1
  git commit -m "version release: ${RELEASE_VERSION}" || exit 1
  git tag "v${RELEASE_VERSION}" || exit 1
  git push -u origin master --tags || exit 1

  ./docker.sh build || exit 1
  ./docker.sh push || exit 1
}

function setNextDevelopmentVersion {
  git checkout develop || exit 1
  git rebase master || exit 1

  # Generate next (minor) development version
  npm --no-git-tag-version version minor || exit 1
  DEV_VERSION=$(sed 's/.*"version": "\(.*\)".*/\1/;t;d' ./package.json)-SNAPSHOT

  echo "Next development version: ${DEV_VERSION}"
  setVersion "${DEV_VERSION}" || exit 1

  git add package.json || exit 1
  git commit -m "next development version" || exit 1
  git push -u origin develop --tags || exit 1
}

command="$1"
case $command in
  patch)
    releasePatch
    setNextDevelopmentVersion
    ;;
  minor)
    releaseMinor
    setNextDevelopmentVersion
    ;;
  major)
    releaseMajor
    setNextDevelopmentVersion
    ;;
  setversion)
    setVersion "$2"
    ;;
  -h|--help)
    usage
    ;;
  *)
    echo "Invalid command"
    exit 1
    ;;
esac
