#!/usr/bin/env bash

chosen_main=$(echo -e "Обои\nТемы\nТриггеры\nВыход" | rofi -dmenu -p "Настройки системы" -i)

case "$chosen_main" in
    "Обои")
        # Вызываем скрипт выбора обоев
        ~/.local/bin/wallpaper_menu.sh
        ;;
    "Темы")
        # Вызываем скрипт выбора тем
        ~/.local/bin/themes_menu.sh
        ;;
    "Триггеры")
        ~/.local/bin/trigger_menu.sh
        # lxappearance
        ;;
    "Выход")
        exit 0
        ;;
    *)
        exit 1
        ;;
esac