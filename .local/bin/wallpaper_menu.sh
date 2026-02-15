#!/usr/bin/env bash

# --- КОНФИГУРАЦИЯ ---
WALLPAPER_ROOT="$HOME/Pictures/Wallpapers"
COMMAND_BASE="matugen image"

# Проверка, существует ли корневая папка
if [ ! -d "$WALLPAPER_ROOT" ]; then
    notify-send -u critical "Ошибка" "Папка $WALLPAPER_ROOT не найдена!"
    exit 1
fi

# --- ШАГ 1: ВЫБОР КАТЕГОРИИ (ПАПКИ) ---
# Получаем список папок внутри WALLPAPER_ROOT
# basename -a удаляет путь, оставляя только имена (Forge, Frost...)
FOLDERS=$(find "$WALLPAPER_ROOT" -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -r basename -a)

if [ -z "$FOLDERS" ]; then
    notify-send "Ошибка" "В папке обоев нет подпапок!"
    exit 1
fi

# Показываем Rofi для выбора папки (обычный список)
CHOSEN_FOLDER=$(echo "$FOLDERS" | rofi -dmenu -p "Категория" -i \
    -theme-str 'window { width: 300px; }' \
    -theme-str 'listview { lines: 6; }')

# Если ничего не выбрали (Esc), выходим
if [ -z "$CHOSEN_FOLDER" ]; then
    exit 0
fi

# Полный путь к выбранной папке
TARGET_DIR="$WALLPAPER_ROOT/$CHOSEN_FOLDER"

# --- ШАГ 2: ВЫБОР ОБОЕВ С ПРЕДПРОСМОТРОМ ---

# Функция генерации списка для Rofi с иконками
gen_list() {
    # Ищем файлы jpg, jpeg, png, webp
    for file in "$TARGET_DIR"/*.{jpg,jpeg,png,webp}; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            # Синтаксис: ИмяФайла\0icon\x1fПутьККартинке
            echo -en "$filename\0icon\x1f$file\n"
        fi
    done
}

# Запускаем Rofi в режиме "Галереи"
CHOSEN_FILE=$(gen_list | rofi -dmenu -i -p "Обои ($CHOSEN_FOLDER)" -show-icons \
    -theme-str 'window { width: 800px; }' \
    -theme-str 'listview { lines: 3; columns: 4; fixed-height: false; }' \
    -theme-str 'element { orientation: vertical; padding: 10px; spacing: 5px; }' \
    -theme-str 'element-icon { size: 120px; vertical-align: 0.5; horizontal-align: 0.5; }' \
    -theme-str 'element-text { vertical-align: 0.5; horizontal-align: 0.5; }')

# --- ШАГ 3: ПРИМЕНЕНИЕ ---

if [ -n "$CHOSEN_FILE" ]; then
    FULL_PATH="$TARGET_DIR/$CHOSEN_FILE"
    
    # Запуск matugen (он и обои поставит, и цвета сгенерирует)
    $COMMAND_BASE "$FULL_PATH"
    
    notify-send -t 1500 "Стиль обновлен" "Категория: $CHOSEN_FOLDER\nФайл: $CHOSEN_FILE"
fi