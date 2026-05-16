#!/usr/bin/env bash
THEMES_DIR="$HOME/Themes"
WALLPAPER_ROOT="$HOME/Pictures/Wallpapers"
MENU_PATH="$HOME/.local/bin/rofi-tabs.sh"
CURRENT_THEME_CACHE="$HOME/.cache/current-theme"

# ──────────────────────────────────────────────
# Копирует файл конфига, если источник существует.
# Возвращает 1 при ошибке.
# ──────────────────────────────────────────────
apply_config() {
    local src="$1"
    local dst="$2"
    if [ ! -f "$src" ]; then
        echo "⚠️  Пропуск: $src не найден."
        return 1
    fi
    [ -e "$dst" ] || [ -L "$dst" ] && rm -rf "$dst"
    mkdir -p "$(dirname "$dst")"
    cp -f "$src" "$dst"
    echo "✅ Скопировано: $(basename "$src") -> $dst"
}

# ──────────────────────────────────────────────
# Применяет все конфиги темы.
# Выводит предупреждение если хоть один не применился.
# ──────────────────────────────────────────────
apply_theme_configs() {
    local theme_dir="$1"
    local theme_name="$2"
    local any_failed=0

    apply_config "$theme_dir/hyprland-colors.conf" "$HOME/.config/hypr/modules/colors.conf"  || any_failed=1
    apply_config "$theme_dir/kitty-colors.conf"    "$HOME/.config/kitty/colors.conf"          || any_failed=1
    apply_config "$theme_dir/colors.css"           "$HOME/.config/waybar/colors.css"           || any_failed=1
    apply_config "$theme_dir/rofi-colors.rasi"     "$HOME/.config/rofi/colors.rasi"            || any_failed=1
    apply_config "$theme_dir/gtk-colors.css"       "$HOME/.config/gtk-3.0/gtk.css"             || any_failed=1
    apply_config "$theme_dir/gtk-colors.css"       "$HOME/.config/gtk-4.0/gtk.css"             || any_failed=1
    apply_config "$theme_dir/btop.theme"           "$HOME/.config/btop/themes/btop.theme"      || any_failed=1
    apply_config "$theme_dir/discord.css"          "$HOME/.config/vesktop/themes/discord.css"   || any_failed=1
    apply_config "$theme_dir/colors.json"          "$HOME/.cache/wal/colors.json"               || any_failed=1

    if [ "$any_failed" -eq 1 ]; then
        notify-send -t 3000 -u normal "⚠️ Тема $theme_name" \
            "Некоторые файлы конфига не найдены — тема применена частично." \
            -i "dialog-warning"
    fi
}

# ──────────────────────────────────────────────
# Перезапускает Thunar-демон только если он
# уже был запущен (нужно для подхвата GTK-цветов).
# ──────────────────────────────────────────────
restart_thunar_if_running() {
    if pgrep -x "thunar" > /dev/null || pgrep -x "Thunar" > /dev/null; then
        thunar -q 2>/dev/null
        pkill -SIGTERM -i thunar 2>/dev/null
        # Ждём завершения процесса вместо sleep
        local timeout=10
        while pgrep -i thunar > /dev/null && [ "$timeout" -gt 0 ]; do
            sleep 0.1
            timeout=$((timeout - 1))
        done
        Thunar --daemon &
        echo "✅ Thunar перезапущен"
    else
        echo "ℹ️  Thunar не запущен, пропуск."
    fi
}

# ──────────────────────────────────────────────
# Выбор обоев через rofi с превью иконок.
# Использует find вместо glob во избежание
# проблем с нераскрытыми паттернами.
# ──────────────────────────────────────────────
pick_wallpaper() {
    local wall_dir="$1"
    local theme_name="$2"

    [ -d "$wall_dir" ] || return

    local chosen
    chosen=$(
        find "$wall_dir" -maxdepth 1 -type f \
            \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
            -print0 \
        | while IFS= read -r -d '' filepath; do
            filename=$(basename "$filepath")
            printf "%s\0icon\x1f%s\n" "$filename" "$filepath"
        done \
        | rofi -dmenu -i -p "Обои: $theme_name" -show-icons \
            -theme-str 'window { width: 1000px; }' \
            -theme-str 'listview { columns: 2; lines: 2; spacing: 20px; }' \
            -theme-str 'element { orientation: vertical; }' \
            -theme-str 'element-icon { size: 250px; }'
    )

    [ -n "$chosen" ] && swww img "$wall_dir/$chosen" --transition-type center
}

if [[ "$1" == "--restore" ]]; then
    [ -f "$CURRENT_THEME_CACHE" ] || exit 0
    chosen_theme=$(cat "$CURRENT_THEME_CACHE")
    SELECTED_THEME=$(readlink -f "$THEMES_DIR/$chosen_theme")
    apply_theme_configs "$SELECTED_THEME" "$chosen_theme"
    # Обои не предлагаем — swww restore сам восстановит последние
    exit 0
fi

# ══════════════════════════════════════════════
#  MAIN
# ══════════════════════════════════════════════

chosen_theme=$(
    {
        find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n"
        echo "◀ Назад"
    } | rofi -dmenu -p "Выбор темы" -i
)

[[ -z "$chosen_theme" ]] && exit 0

[ -d "$THEMES_DIR" ] || { notify-send "themes_menu" "Папка тем не найдена: $THEMES_DIR"; exit 1; }

if [[ "$chosen_theme" == "◀ Назад" ]]; then
    exec "$MENU_PATH"
fi

SELECTED_THEME=$(readlink -f "$THEMES_DIR/$chosen_theme")

echo "--- Установка темы: $chosen_theme ---"

apply_theme_configs "$SELECTED_THEME" "$chosen_theme"
pick_wallpaper "$WALLPAPER_ROOT/$chosen_theme" "$chosen_theme"

echo "--- Обновление компонентов ---"

# Все инстансы kitty получат сигнал — это ожидаемо
pkill -SIGUSR1 kitty
pkill -SIGUSR2 waybar
hyprctl reload
restart_thunar_if_running
pywalfox update || notify-send -t 3000 -u normal "⚠️ Pywalfox" \
    "Ошибка обновления. Возможно, нужна пересборка под текущий Python." \
    -i "dialog-error"

# Сохраняем текущую тему для восстановления при логине
echo "$chosen_theme" > "$CURRENT_THEME_CACHE"

notify-send -t 1500 "Тема $chosen_theme применена" -i "color-management"