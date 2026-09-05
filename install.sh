#!/usr/bin/env bash

set -Eeuo pipefail

readonly REPO_URL="${NVIM_REPO_URL:-https://github.com/tsuna-n/nvim-tsuna.git}"
readonly BRANCH="${NVIM_REPO_BRANCH:-main}"
readonly CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME:?HOME is not set}/.config}"
readonly TARGET="${CONFIG_HOME}/nvim"

stage=""
backup=""

cleanup() {
  local status=$?

  if [[ -n "${stage}" && -d "${stage}" ]]; then
    rm -rf -- "${stage}"
  fi

  if ((status != 0)) && [[ -n "${backup}" ]] && [[ ! -e "${TARGET}" && ! -L "${TARGET}" ]]; then
    mv -- "${backup}" "${TARGET}"
    printf 'Installation failed; restored %s\n' "${TARGET}" >&2
  fi

  exit "${status}"
}

trap cleanup EXIT

if ! command -v git >/dev/null 2>&1; then
  printf 'Error: git is required.\n' >&2
  exit 1
fi

mkdir -p -- "${CONFIG_HOME}"
stage="$(mktemp -d "${CONFIG_HOME}/.nvim-install.XXXXXX")"

printf 'Downloading %s (%s)...\n' "${REPO_URL}" "${BRANCH}"
git clone --quiet --branch "${BRANCH}" --single-branch "${REPO_URL}" "${stage}"

if [[ -e "${TARGET}" || -L "${TARGET}" ]]; then
  backup="${TARGET}.backup-$(date +%Y%m%d-%H%M%S)-$$"
  printf 'Moving existing config to %s\n' "${backup}"
  mv -- "${TARGET}" "${backup}"
fi

mv -- "${stage}" "${TARGET}"
stage=""
trap - EXIT

printf 'Neovim config installed at %s\n' "${TARGET}"
if [[ -n "${backup}" ]]; then
  printf 'Previous config kept at %s\n' "${backup}"
fi
