#!/usr/bin/env bash

# If the file is an image, use kitty to display it.
if [[ "$(file -Lb --mime-type "$1")" =~ ^image ]]; then
    kitty +kitten icat --silent --transfer-mode file --stdin no --place "${2}x${3}@${4}x${5}" "$1" </dev/null >/dev/tty
	exit 1
fi

# Else fallback to bat.
bat --color=always --theme="base16" --style="header,numbers,snip" "$1"
