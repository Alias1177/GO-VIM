---@type LazySpec
return {
  "AstroNvim/astrolsp",
  opts = function(_, opts)
    opts.features = opts.features or {}
    opts.features.codelens = true
    opts.features.semantic_tokens = true
    opts.features.inlay_hints = true

    opts.formatting = opts.formatting or {}
    opts.formatting.format_on_save = opts.formatting.format_on_save or {}
    opts.formatting.format_on_save.enabled = true
    opts.formatting.format_on_save.allow_filetypes = require("astrocore").list_insert_unique(
      opts.formatting.format_on_save.allow_filetypes or {},
      { "go", "gomod", "gowork", "gotmpl" }
    )

    opts.servers = require("astrocore").list_insert_unique(opts.servers or {}, { "gopls" })
    if opts.servers then
      opts.servers = vim.tbl_filter(function(server)
        return not (type(server) == "string" and server == "yamlls")
      end, opts.servers)
    end

    local yaml_config
    local ok, yaml_companion = pcall(require, "yaml-companion")
    if ok then
      yaml_config = yaml_companion.setup {
        lspconfig = {
          filetypes = { "yaml", "yml", "yaml.docker-compose" },
          settings = {
            yaml = {
              validate = false,
              schemaStore = { enable = false, url = "" },
              schemas = {},
            },
          },
        },
      }
      pcall(function()
        require("telescope").load_extension "yaml_schema"
      end)
    end

    opts.config = opts.config or {}
    opts.setup_handlers = opts.setup_handlers or {}
    opts.setup_handlers.yamlls = function() end -- avoid duplicate setup; handled below
    opts.config.yamlls = nil

    local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
    if lspconfig_ok then
      local config = yaml_config
        or {
          filetypes = { "yaml", "yml", "yaml.docker-compose" },
          settings = {
            yaml = {
              validate = false,
              schemaStore = { enable = false, url = "" },
              schemas = {},
            },
          },
        }
      lspconfig.yamlls.setup(config)
    end
    opts.config.gopls = vim.tbl_deep_extend("force", opts.config.gopls or {}, {
      settings = {
        gopls = {
          gofumpt = true,
          usePlaceholders = true,
          staticcheck = false,
          -- Enable auto-import and organize imports
          ["local"] = "",
          completeUnimported = true,
          analyses = {
            nilness = true,
            unusedparams = true,
            unusedvariable = true,
            shadow = true,
            unusedwrite = true,
            useany = true,
          },
          codelenses = {
            generate = true,
            gc_details = true,
            test = true,
            tidy = true,
            upgrade_dependency = true,
            vendor = true,
          },
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            compositeLiteralTypes = true,
            constantValues = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },
        },
      },
      on_attach = function(client, bufnr)
        -- Auto-organize imports on save
        if client.name == "gopls" then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              local params = vim.lsp.util.make_range_params()
              params.context = { only = { "source.organizeImports" } }
              local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
              for _, res in pairs(result or {}) do
                for _, r in pairs(res.result or {}) do
                  if r.edit then
                    vim.lsp.util.apply_workspace_edit(r.edit, "utf-8")
                  elseif r.command then
                    local command = r.command
                    if type(command) == "table" and command.command then
                      client.request("workspace/executeCommand", command, function(err)
                        if err then
                          vim.notify("Error executing command: " .. vim.inspect(err), vim.log.levels.ERROR)
                        end
                      end, bufnr)
                    end
                  end
                end
              end
            end,
          })
        end
      end,
    })

    return opts
  end,
}
