#!/usr/bin/env bash
WALLPAPER_ROOT="$HOME/Pictures/Wallpapers"
COMMAND_BASE="matugen image"
MENU_PATH="$HOME/.local/bin/rofi-tabs.sh"

if [ ! -d "$WALLPAPER_ROOT" ]; then
    notify-send -u critical "Ошибка" "Папка $WALLPAPER_ROOT не найдена!"
    exit 1
fi

FOLDERS=$(find "$WALLPAPER_ROOT" -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -r basename -a)

if [ -z "$FOLDERS" ]; then
    notify-send "Ошибка" "В папке обоев нет подпапок!"
    exit 1
fi


CHOSEN_FOLDER=$(
    {
        echo "$FOLDERS"
        echo "◀ Назад"
    } | rofi -dmenu -p "Категория" -i \
        -theme-str 'window { width: 300px; }' \
        -theme-str 'listview { lines: 6; }'
)

if [ -z "$CHOSEN_FOLDER" ]; then
    exit 0
fi


if [[ "$CHOSEN_FOLDER" == "◀ Назад" ]]; then
    exec "$MENU_PATH"
    exit 0
fi

TARGET_DIR="$WALLPAPER_ROOT/$CHOSEN_FOLDER"

gen_list() {
    for file in "$TARGET_DIR"/*.{jpg,jpeg,png,webp}; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            echo -en "$filename\0icon\x1f$file\n"
        fi
    done
}

CHOSEN_FILE=$(gen_list | rofi -dmenu -i -p "Обои ($CHOSEN_FOLDER)" -show-icons \
    -theme-str 'window { width: 800px; }' \
    -theme-str 'listview { lines: 3; columns: 4; fixed-height: false; }' \
    -theme-str 'element { orientation: vertical; padding: 10px; spacing: 5px; }' \
    -theme-str 'element-icon { size: 120px; vertical-align: 0.5; horizontal-align: 0.5; }' \
    -theme-str 'element-text { vertical-align: 0.5; horizontal-align: 0.5; }')

if [ -n "$CHOSEN_FILE" ]; then
    FULL_PATH="$TARGET_DIR/$CHOSEN_FILE"
    $COMMAND_BASE "$FULL_PATH"
    notify-send -t 1500 "Стиль обновлен" "Категория: $CHOSEN_FOLDER\nФайл: $CHOSEN_FILE"
fi