#!/usr/bin/env bash

set -Eeuo pipefail

readonly SOURCE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME:?HOME is not set}/.config}"
readonly TARGET="${CONFIG_HOME}/nvim"

readonly CONFIG_ITEMS=(
  .neoconf.json
  colors
  init.lua
  lazy-lock.json
  lazyvim.json
  lua
  scripts
  stylua.toml
)

if [[ "${SOURCE_DIR}" == "${TARGET}" ]]; then
  printf 'This repository is already the active Neovim config: %s\n' "${TARGET}"
  exit 0
fi

mkdir -p -- "${TARGET}"

for item in "${CONFIG_ITEMS[@]}"; do
  source_item="${SOURCE_DIR}/${item}"
  target_item="${TARGET}/${item}"

  if [[ -d "${source_item}" ]]; then
    mkdir -p -- "${target_item}"
    cp -a -- "${source_item}/." "${target_item}/"
  elif [[ -f "${source_item}" ]]; then
    cp -a -- "${source_item}" "${target_item}"
  else
    printf 'Warning: skipping missing item %s\n' "${item}" >&2
    continue
  fi

  printf 'Installed %s\n' "${item}"
done

printf 'Neovim config updated at %s\n' "${TARGET}"
