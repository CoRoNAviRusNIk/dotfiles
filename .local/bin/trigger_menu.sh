#!/bin/bash


DOTSYNC_PATH="$HOME/.local/bin/sync.sh"

CHOICE=$(printf "1. 💾 Синхронизировать Dotfiles (dotsync)" | rofi -dmenu -p "Выбор триггера")

case "$CHOICE" in
    "1. 💾 Синхронизировать Dotfiles (dotsync)")
        "$DOTSYNC_PATH"
        ;;
    *)
        ;;
esac