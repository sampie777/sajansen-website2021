#!/bin/bash
NAME="sajansen/sajansen-website2021"

VERSION=$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' ./package.json)
progname=$(basename $0)

function usage {
  cat << HEREDOC

     Usage: $progname <command>

     commands:
       run                  Run docker-compose
       build                Build a docker image
       push                 Push current docker image
       version              Print project version

     optional arguments:
       -h, --help           show this help message and exit

HEREDOC
}

function run {
  docker-compose -f docker/docker-compose.yaml up
}

function build {
  echo Building docker image ${NAME}:${VERSION}

if [[ -n "${GITHUB_ACTIONS}" ]]; then
  echo "Running inside a GitHub Actions workflow."
  docker build -t ${NAME} -f docker/Dockerfile . || exit 1
else
  echo "Not running inside a GitHub Actions workflow."
  docker build -t ${NAME} --platform linux/amd64,linux/arm64 -f docker/Dockerfile . || exit 1
fi

  docker tag ${NAME} ${NAME}:${VERSION} || exit 1
}

function push {
  echo Pushing docker image ${NAME}:${VERSION}
  docker push ${NAME}:${VERSION}
  docker push ${NAME}
}

command="$1"
case $command in
  run)
    run
    ;;
  build)
    build
    ;;
  push)
    push
    ;;
  version)
    echo "$VERSION"
    ;;
  -h|--help)
    usage
    ;;
  *)
    echo "Invalid command"
    exit 1
    ;;
esac
