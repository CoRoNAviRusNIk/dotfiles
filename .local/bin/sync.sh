#!/bin/bash

# Синхронизирует конфигурационные файлы в репозиторий dotfiles
# с обработкой ошибок, логированием и git-интеграцией


set -euo pipefail 


TARGET_DIR="$HOME/dotfiles"
LOG_FILE="$TARGET_DIR/sync.log"
DRY_RUN=false
ERRORS=0


FLAGS="-avh --delete"


# "source_path:description"
declare -a CONFIGS=(
    ".config/fastfetch/cat.txt:fastfetch cat"
    ".config/fastfetch/config.jsonc:fastfetch config"
    ".config/hypr/:hypr (full directory)"
    ".config/kitty/colors.conf:kitty colors"
    ".config/kitty/kitty.conf:kitty config"
    ".config/rofi/:rofi (full directory)"
    ".config/swaync/:swaync (full directory)"
    ".config/waybar/:waybar (full directory)"
    ".config/matugen/:matugen (full directory)"
    ".config/zathura/:zathura (full directory)"
    "Themes/:Themes (full directory)"
    ".local/bin/rofi-tabs.sh:rofi-tabs script"
    ".local/bin/themes_menu.sh:themes menu script"
    ".local/bin/trigger_menu.sh:trigger menu script"
    ".local/bin/wallpaper_menu.sh:wallpaper menu script"
    ".local/bin/rofi-read.sh:rofi-read script"
    ".local/bin/sync.sh:dotfiles sync script"
    ".local/bin/dotfiles_push.sh:dotfiles push script"
)



log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

error() {
    log "❌ ERROR: $1"
    ((ERRORS++))
}

success() {
    log "✅ $1"
}

notify() {
    if command -v notify-send &> /dev/null; then
        notify-send -t 1500 "Dotfiles Sync" "$1" -i "${2:-dialog-information}"
    fi
}


ensure_target_structure() {
    if [ ! -d "$TARGET_DIR" ]; then
        log "Целевая директория не существует. Создаю: $TARGET_DIR"
        mkdir -p "$TARGET_DIR" || {
            error "Не удалось создать $TARGET_DIR"
            exit 1
        }
    fi
    
    
    touch "$LOG_FILE" || {
        error "Не удалось создать файл логов"
        exit 1
    }
}


sync_config() {
    local source="$1"
    local description="$2"
    local full_source="$HOME/$source"
    
    
    if [ ! -e "$full_source" ]; then
        error "Источник не найден: $full_source"
        return 1
    fi
    
    
    local target_path="$TARGET_DIR/$source"
    local target_dir=$(dirname "$target_path")
    
    
    mkdir -p "$target_dir" || {
        error "Не удалось создать директорию: $target_dir"
        return 1
    }
    
    log "Синхронизация: $description"
    
    
    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY-RUN] rsync $FLAGS $full_source $target_path"
        return 0
    fi
    

    if rsync $FLAGS "$full_source" "$target_path" 2>&1 | tee -a "$LOG_FILE"; then
        success "Синхронизировано: $description"
        return 0
    else
        error "Ошибка синхронизации: $description"
        return 1
    fi
}


parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                log "Режим DRY-RUN включен"
                shift
                ;;
            --help|-h)
                cat << EOF
Использование: $0 [OPTIONS]

Опции:
  --dry-run       Показать, что будет синхронизировано, без выполнения
  -h, --help      Показать эту справку

Примеры:
  $0                    # Обычный запуск
  $0 --dry-run          # Предпросмотр без изменений
EOF
                exit 0
                ;;
            *)
                error "Неизвестная опция: $1"
                echo "Используйте --help для справки"
                exit 1
                ;;
        esac
    done
}

main() {
    parse_args "$@"
    
    log "=========================================="
    log "Начало синхронизации dotfiles"
    log "=========================================="
    
    notify "🚀 Начинаю синхронизацию конфигов..." "system-run"
    
    cd "$HOME" || {
        error "Не удалось перейти в $HOME"
        exit 1
    }
    
    ensure_target_structure
    
    # Синхронизируем все конфиги
    for config in "${CONFIGS[@]}"; do
        IFS=':' read -r source description <<< "$config"
        sync_config "$source" "$description" || true
    done
    
    log "=========================================="
    if [ "$ERRORS" -eq 0 ]; then
        log "✅ Синхронизация завершена успешно!"
        notify "✅ Синхронизация завершена! Файлы в $TARGET_DIR" "emblem-default"
    else
        log "⚠️  Синхронизация завершена с ошибками: $ERRORS"
        notify "⚠️  Синхронизация завершена с $ERRORS ошибками" "dialog-warning"
    fi
    log "=========================================="
    
    exit $ERRORS
}

# Запуск
main "$@"