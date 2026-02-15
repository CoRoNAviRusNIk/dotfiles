#!/usr/bin/env bash


THEMES_DIR="$HOME/Themes"
WALLPAPER_ROOT="$HOME/Pictures/Wallpapers"


apply_config() {
    local src="$1"
    local dst="$2"
    
    if [ ! -f "$src" ]; then
        echo "⚠️ Пропуск: Исходный файл $src не найден."
        return 1
    fi

    
    [ -e "$dst" ] || [ -L "$dst" ] && rm -rf "$dst"
    
    
    mkdir -p "$(dirname "$dst")"
    
    
    cp -f "$src" "$dst"
    echo "✅ Скопировано: $(basename "$src") -> $dst"
}


chosen_theme=$(ls "$THEMES_DIR" | rofi -dmenu -p "Выбор темы" -i)
[[ -z "$chosen_theme" ]] && exit 0


if [[ "$chosen_theme" == "Назад" ]]; then
    ~/.local/bin/rofi-tabs.sh
    exit 0
fi

SELECTED_THEME="$THEMES_DIR/$chosen_theme"

SELECTED_THEME=$(readlink -f "$SELECTED_THEME")

echo "--- Установка темы: $chosen_theme ---"



apply_config "$SELECTED_THEME/hyprland-colors.conf" "$HOME/.config/hypr/modules/colors.conf"
apply_config "$SELECTED_THEME/kitty-colors.conf"    "$HOME/.config/kitty/colors.conf"
apply_config "$SELECTED_THEME/colors.css"           "$HOME/.config/waybar/colors.css"
apply_config "$SELECTED_THEME/rofi-colors.rasi"     "$HOME/.config/rofi/colors.rasi"
apply_config "$SELECTED_THEME/gtk-colors.css"       "$HOME/.config/gtk-3.0/gtk.css"
apply_config "$SELECTED_THEME/gtk-colors.css"       "$HOME/.config/gtk-4.0/gtk.css"
apply_config "$SELECTED_THEME/btop.theme"           "$HOME/.config/btop/themes/btop.theme"
apply_config "$SELECTED_THEME/discord.css"          "$HOME/.config/vesktop/themes/discord.css"
apply_config "$SELECTED_THEME/colors.json"          "$HOME/.cache/wal/colors.json"



TARGET_WALL_DIR="$WALLPAPER_ROOT/$chosen_theme"
if [ -d "$TARGET_WALL_DIR" ]; then
    gen_list() {
        for file in "$TARGET_WALL_DIR"/*.{jpg,jpeg,png,webp}; do
            [ -f "$file" ] && echo -en "$(basename "$file")\0icon\x1f$file\n"
        done
    }

CHOSEN_WALL=$(gen_list | rofi -dmenu -i -p "Обои: $chosen_theme" -show-icons \
        -theme-str 'window { width: 1000px; }' \
        -theme-str 'listview { columns: 2; lines: 2; spacing: 20px; }' \
        -theme-str 'element { orientation: vertical; }' \
        -theme-str 'element-icon { size: 250px; }')

    if [ -n "$CHOSEN_WALL" ]; then
        swww img "$TARGET_WALL_DIR/$CHOSEN_WALL" --transition-type center
    fi
fi



echo "--- Обновление компонентов ---"


pywalfox update || echo "❌ Ошибка Pywalfox (нужна пересборка под Python 3.14)"

hyprctl reload
pkill -SIGUSR1 kitty
pkill -SIGUSR2 waybar


thunar -q; pkill -9 -i thunar; sleep 0.2


Thunar --daemon &

notify-send -t 1500 "Тема $chosen_theme применена" -i "color-management"