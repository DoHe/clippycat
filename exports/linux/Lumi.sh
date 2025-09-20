#!/bin/sh
printf '\033c\033]0;%s\a' Lumi
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Lumi.x86_64" "$@"
