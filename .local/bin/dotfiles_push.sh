#!/bin/bash

DOTFILES_PATH="$HOME/dotfiles"

COMMIT_MSG=$(rofi -dmenu -p "Commit message" -lines 0)

if [ -z "$COMMIT_MSG" ]; then
    COMMIT_MSG="Auto sync $(date '+%Y-%m-%d %H:%M')"
fi

cd "$DOTFILES_PATH" || { notify-send "Dotfiles" "❌ Директория не найдена: $DOTFILES_PATH"; exit 1; }

git add .

if git diff --cached --quiet; then
    notify-send "Dotfiles" "Нечего коммитить"
    exit 0
fi

git commit -m "$COMMIT_MSG" && git push \
    && notify-send "Dotfiles" "✅ Запушено: $COMMIT_MSG" \
    || notify-send "Dotfiles" "❌ Ошибка пуша"