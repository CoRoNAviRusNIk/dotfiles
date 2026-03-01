#!/usr/bin/env bash

BOOKS_DIR="$HOME/Books"

mapfile -t pdf_paths < <(find "$BOOKS_DIR" -type f -iname "*.pdf" | sort)

if [[ ${#pdf_paths[@]} -eq 0 ]]; then
    rofi -e "📭 PDF файлы не найдены в $BOOKS_DIR"
    exit 1
fi

display_names=()
for path in "${pdf_paths[@]}"; do
    display_names+=("${path#"$BOOKS_DIR/"}")
done

chosen=$(printf '%s\n' "${display_names[@]}" | rofi -dmenu -p "📖 Выбери книгу" -i)

[[ -z "$chosen" ]] && exit 0

for i in "${!display_names[@]}"; do
    if [[ "${display_names[$i]}" == "$chosen" ]]; then
        zathura "${pdf_paths[$i]}" &
        exit 0
    fi
done

exit 1