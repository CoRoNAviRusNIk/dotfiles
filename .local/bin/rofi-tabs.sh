#!/usr/bin/env bash

chosen_main=$(echo -e "📖 Читать\n🌲 Обои\n🪵 Темы\n🍃 Триггеры\n◀ Выход" | rofi -dmenu -p "Настройки системы" -i)

case "$chosen_main" in
    "📖 Читать")
        ~/.local/bin/rofi-read.sh
        ;;
    "🌲 Обои")
        ~/.local/bin/wallpaper_menu.sh
        ;;
    "🪵 Темы")
        ~/.local/bin/themes_menu.sh
        ;;
    "🍃 Триггеры")
        ~/.local/bin/trigger_menu.sh
        ;;
    "◀ Выход")
        exit 0
        ;;
    *)
        exit 1
        ;;
esac