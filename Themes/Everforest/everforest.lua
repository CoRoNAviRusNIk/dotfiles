return {
  -- Конфигурация самого плагина темы
  {
    "sainnhe/everforest",
    priority = 1000, -- Максимальный приоритет для загрузки до остальных плагинов
    lazy = false, -- Отключаем ленивую загрузку, чтобы избежать мерцания при старте
    config = function()
      -- Опции Everforest должны быть объявлены до команды colorscheme
      vim.g.everforest_background = "hard"
      vim.g.everforest_transparent_background = 1 -- Полезно для визуальной интеграции с Hyprland
      vim.g.everforest_better_performance = 1

      vim.cmd([[colorscheme everforest]])
    end,
  },

  -- Переопределение настроек LazyVim
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "everforest",
    },
  },
}

