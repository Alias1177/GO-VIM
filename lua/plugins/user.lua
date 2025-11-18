---@type LazySpec
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = function(_, opts)
      opts = opts or {}
      opts.flavour = "macchiato"
      opts.background = { light = "latte", dark = "macchiato" }
      opts.term_colors = true
      opts.transparent_background = false
      opts.integrations = vim.tbl_deep_extend("force", opts.integrations or {}, {
        cmp = true,
        gitsigns = true,
        noice = true,
        neotree = true,
        telescope = { enabled = true, style = "nvchad" },
        indent_blankline = { enabled = true, scope_color = "lavender", colored_indent_levels = false },
        native_lsp = { enabled = true, inlay_hints = { background = true } },
        treesitter = true,
        trouble = true,
      })
      return opts
    end,
  },
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.presets = vim.tbl_deep_extend("force", opts.presets or {}, {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      })
      opts.views = vim.tbl_deep_extend("force", opts.views or {}, {
        cmdline_popup = { border = { style = "rounded" } },
        confirm = { border = { style = "rounded" } },
      })
      return opts
    end,
  },
  {
    "folke/trouble.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.use_diagnostic_signs = true
      return opts
    end,
  },
  {
    "folke/todo-comments.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.highlight = vim.tbl_deep_extend("force", opts.highlight or {}, { multiline = false })
      return opts
    end,
  },
  {
    "ahmedkhalf/project.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.manual_mode = false
      opts.detection_methods = { "lsp", "pattern" }
      opts.patterns = { ".git", "go.mod", "go.work", "package.json", "pyproject.toml" }
      return opts
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = function(_, opts)
      opts = opts or {}
      opts.indent = vim.tbl_deep_extend("force", opts.indent or {}, {
        char = "│",
        tab_char = "│",
      })
      opts.scope = vim.tbl_deep_extend("force", opts.scope or {}, {
        enabled = true,
        show_start = false,
        highlight = "Function",
      })
      return opts
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    opts = function(_, opts)
      opts = opts or {}
      opts.panel = vim.tbl_deep_extend("force", opts.panel or {}, {
        enabled = true,
        auto_refresh = true,
      })
      opts.suggestion = vim.tbl_deep_extend("force", opts.suggestion or {}, {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<M-l>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      })
      opts.filetypes = vim.tbl_deep_extend("force", opts.filetypes or {}, {
        markdown = false,
        help = false,
      })
      return opts
    end,
  },
  {
    "ray-x/go.nvim",
    ft = { "go", "gomod", "gowork", "gotmpl" },
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    build = ':lua require("go.install").update_all_sync()',
    opts = {
      lsp_cfg = false,
      lsp_keymaps = false,
      lsp_gofumpt = true,
      gofmt = "gofumpt",
      goimports = "gopls", -- Use gopls for auto-import
      fillstruct = "gopls",
      icons = false,
      lsp_inlay_hints = {
        enable = true,
        only_current_line = false,
      },
      lsp_codelens = true,
      diagnostic = {
        hdlr = false, -- Use AstroNvim's diagnostic handler
        underline = true,
        virtual_text = { space = 0, prefix = "" },
        signs = true,
        update_in_insert = false,
      },
      lsp_document_formatting = true,
      lsp_on_attach = function(client, bufnr)
        -- Enable auto-completion with unimported packages
        if client.server_capabilities.completionProvider then
          vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
        end
      end,
      gopls_cmd = nil, -- Use gopls from PATH
      gopls_remote_auto = true,
      trouble = false, -- AstroNvim handles this
      luasnip = true,
    },
    config = function(_, opts)
      require("go").setup(opts)
    end,
  },
  {
    "leoluz/nvim-dap-go",
    ft = { "go", "gomod" },
    dependencies = { "mfussenegger/nvim-dap" },
    config = function(_, opts)
      require("dap-go").setup(opts)
    end,
  },
  {
    "someone-stole-my-name/yaml-companion.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },

}
