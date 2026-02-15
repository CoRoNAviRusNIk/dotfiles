#!/bin/bash

DOTSYNC_PATH="$HOME/.local/bin/sync.sh"
DOTPUSH_PATH="$HOME/.local/bin/dotfiles_push.sh"
MENU_PATH="$HOME/.local/bin/rofi-tabs.sh"

CHOICE=$(printf "🌳 Sync Dotfiles\n🍄 Push Dotfiles\n◀ Выход" | rofi -dmenu -p "Выбор триггера")

case "$CHOICE" in
    "🌳 Sync Dotfiles")
        "$DOTSYNC_PATH"
        ;;
    "🍄 Push Dotfiles")
        "$DOTPUSH_PATH"
        ;;
    "◀ Выход")
        "$MENU_PATH"
        ;;
    *)
        ;;
esac