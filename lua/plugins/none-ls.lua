---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    local null_ls = require "null-ls"

    opts.sources = require("astrocore").list_insert_unique(opts.sources or {}, {
      null_ls.builtins.diagnostics.golangci_lint,
      null_ls.builtins.code_actions.gomodifytags,
      null_ls.builtins.code_actions.impl,
    })

    return opts
  end,
}
