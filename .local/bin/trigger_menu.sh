#!/bin/bash

DOTSYNC_PATH="$HOME/.local/bin/sync.sh"
DOTPUSH_PATH="$HOME/.local/bin/dotfiles_push.sh"

CHOICE=$(printf "1. 💾 Синхронизировать Dotfiles (dotsync)\n2. 🚀 Push Dotfiles в Git" | rofi -dmenu -p "Выбор триггера")

case "$CHOICE" in
    "1. 💾 Синхронизировать Dotfiles (dotsync)")
        "$DOTSYNC_PATH"
        ;;
    "2. 🚀 Push Dotfiles в Git")
        "$DOTPUSH_PATH"
        ;;
    *)
        ;;
esac