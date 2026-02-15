return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000, -- Тема должна грузиться первой
    config = function()
      require("gruvbox").setup({
        terminal_colors = true, -- использовать цвета темы в терминале nvim
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = true,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        inverse = true, -- инвертировать цвета для поиска и т.д.
        contrast = "hard", -- может быть "soft", "medium" или "hard"
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false, -- включи true, если хочешь прозрачный фон
      })
      -- Активация темы
      vim.cmd("colorscheme gruvbox")
    end,
  },
}