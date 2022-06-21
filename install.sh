#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

export LC_ALL=C

# DESCRIPTION
#
# Install script for custom keyboard layouts on macOS.
#
# Tested and working on macOS 12 Monterey.
#
# Google Shell Style Guide says you should avoid writing longer shell scripts so
# I will try to keep it brief and focus on getting the job done safely with
# reasonable effort.
#
# AUTHORS
#
# Benjamin Tegge
#
# DEPENDENCIES
#
readonly DEPENDENCIES=(
  "curl"
  "tar"
)
#
# VARIABLES
#
# Colors
readonly NC="\033[0m";
readonly BGRED="\033[41m";
readonly FGWHT="\033[97m";
#
# Constants
readonly LAUNCHER=$(basename "${0}")
readonly PACKAGE_NAME="osx-us-intl-xorg.bundle"
readonly SOURCE_PATH="./src"
readonly MULTI_USER_PATH="/Library/Keyboard Layouts"
readonly REPO_NAME="osx-us-altgr-intl"
readonly REPO_OWNER="lwbt"
readonly REPO_TGZ="${REPO_NAME}.tgz"
readonly REPO="${REPO_OWNER}/${REPO_NAME}"
readonly SINGLE_USER_PATH="$HOME/Library/Keyboard Layouts"
readonly VERSION="0.0.1"

function err() {
  # Print a provided error message and exit the script.

  echo >&2 -e "\n$(date --rfc-3339=sec) Error: ${BGRED}${FGWHT}$*${NC}"

  show_usage

  exit 1
}

function check_environment() {
  # Abort with an error message if prerequisites are not met.

  [[ ${BASH_VERSINFO[0]} -lt 3 ]] && err "This script was written for BASH 3+."

  [[ $(uname) != "Darwin" ]] && err "No macOS detected, aborting."

  [[ -z "${TERM:-}" ]] && err "No valid terminal detected."

  [[ -z "${TERM_PROGRAM:-}" ]] && err "No valid terminal program detected."

  # We can't have above short circuits on the last line in strict mode.
  echo -n "."
}

function check_dependencies() {
  # Abort if required programs are not found.

  # shellcheck disable=SC2068
  for dep in ${DEPENDENCIES[@]}; do

    # https://stackoverflow.com/q/592620/2010467
    command -v "${dep}" >/dev/null 2>&1 ||
      { err "Error, couldn't find dependency '${dep}'."; }

  done

  echo -n "."
}

function download_missing_package() {
  # Download, unpack and change to new directory if package does not exist
  # locally.

  #  https://docs.github.com/en/rest/releases/releases#get-the-latest-release
  #  https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c

  if [[ ! -d "${SOURCE_PATH}/${PACKAGE_NAME}" ]]; then

    # Fetch the URL for the latest package.
    if [[ ! -r "${REPO_TGZ}" ]]; then
      echo "Package not found, initiating download of release (${RELEASE})"

      package_url="$(curl --silent "${RELEASES_URL}" \
        | grep '"tarball_url":' \
        | sed -E 's/.*"([^"]+)".*/\1/')"

      echo "Downloading from URL: ${package_url}"

      curl -o "${REPO_TGZ}" -L "${package_url}"
    fi

    mkdir -pv "${REPO_NAME}"
    tar -C "${REPO_NAME}" --strip-components 1 -xf "${REPO_TGZ}"

    cd "${REPO_NAME}" || exit
  fi
}

function install_package() {
  # Install package to respective location.

  if [[ "${INSTALL_MODE}" == "single-user" ]]; then

    echo "Installing package to user library"

    cp -av "${SOURCE_PATH}/${PACKAGE_NAME}" \
      "${SINGLE_USER_PATH}/${PACKAGE_NAME}"

  elif [[ "${INSTALL_MODE}" == "multi-user" ]]; then

    echo "Installing package to multi-user library"

    sudo cp -av "${SOURCE_PATH}/${PACKAGE_NAME}" \
      "${MULTI_USER_PATH}/${PACKAGE_NAME}"
  fi
}

function uninstall_package() {
  # Uninstall packackge from known locations.

  if [[ "${INSTALL_MODE}" == "uninstall" \
     && -d "${SINGLE_USER_PATH}/${PACKAGE_NAME}" ]]; then

    echo "Removing package from user library"
    rm -Rv "${SINGLE_USER_PATH:?}/${PACKAGE_NAME}"
  fi

  if [[ "${INSTALL_MODE}" == "uninstall" \
      && -d "${MULTI_USER_PATH}/${PACKAGE_NAME}" ]]; then

    echo \
      "Sudoers password is required to uninstall ${PACKAGE_NAME} for all users."

    echo "Removing package from multi-user library"
    sudo rm -Rv "${MULTI_USER_PATH:?}/${PACKAGE_NAME}"
  fi
}

function show_usage() {
  echo
  echo "Usage"
  echo "  ${LAUNCHER} [--mode single-user|multi-user|uninstall] [--release latest|x.x.x]"
  echo
  echo "You can also pass optional parameters"
  echo "  --mode    : Use single user or multi user installation mode, or uninstall. Defaults to single-user."
  echo "  --release : Select the release to install when downloading from GitHub. Defaults to latest."
  echo "  --version : Print version"
  exit 1
}

function parse_args() {
  # Take command line arguments.

# BUG: Pipe to shell with `| bash -s -mode single-user` does not work.
# if [[ $# -lt 1 ]]; then
#   show_usage
#   exit 0
# else
    while [[ "$#" -gt 0 ]]; do
      case "${1}" in
        -m|--mode)
          if [[ "${2}" =~ ^((single|multi)-user|uninstall)$ ]]; then
            install_mode="${2}"
          else
            err "Provided invalid parameter for installation mode."
          fi
          shift 2;;
        -r|--release)
          release="${2}"
          shift 2;;
        --version)
          echo "${VERSION}"
          exit;;
        -h|--help)
          show_usage;;
        *)
          err "\"${1}\" is not a supported parameter.";;
      esac
    done
# fi

  # DEFAULTS
  readonly INSTALL_MODE="${install_mode:-single-user}"
  readonly RELEASE="${release:-latest}"
  readonly RELEASES_URL="https://api.github.com/repos/${REPO}/releases/${RELEASE}"
}

function main() {
  parse_args "$@"

  echo -n "Running installer script v${VERSION} "

  check_environment

  check_dependencies

  echo .

  download_missing_package

  install_package

  uninstall_package
}

main "$@"

# vim:tabstop=2:shiftwidth=2:expandtab
