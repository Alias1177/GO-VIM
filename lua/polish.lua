-- ============================================================================
-- Utility Functions
-- ============================================================================

local function save_if_writable()
  if vim.bo.buftype ~= "" then return end
  if not vim.bo.modifiable or vim.bo.readonly then return end
  if vim.api.nvim_buf_get_name(0) == "" or not vim.bo.modified then return end
  vim.cmd("silent! update")
end

local function list_lsp_clients(opts)
  if not vim.lsp then return {} end

  if type(vim.lsp.get_clients) == "function" then
    return vim.lsp.get_clients(opts)
  elseif type(vim.lsp.buf_get_clients) == "function" then
    if type(opts) == "table" and opts.bufnr then
      return vim.lsp.buf_get_clients(opts.bufnr)
    end
    if type(opts) == "number" then return vim.lsp.buf_get_clients(opts) end
    return vim.lsp.buf_get_clients()
  elseif type(vim.lsp.get_active_clients) == "function" then
    return vim.lsp.get_active_clients()
  end

  return {}
end

local function is_buffer_valid_and_writable(buf)
  if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
    return false
  end
  if vim.bo[buf].buftype ~= "" or not vim.bo[buf].modifiable or vim.bo[buf].readonly then
    return false
  end
  return true
end

local function has_lsp_client(bufnr, client_name)
  for _, client in ipairs(list_lsp_clients({ bufnr = bufnr })) do
    if client.name == client_name then return true end
  end
  return false
end

-- ============================================================================
-- Key Mappings
-- ============================================================================

-- Make <C-c> behave like <Esc> so InsertLeave autocmds still run
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Exit insert", silent = true })

-- ============================================================================
-- Auto-save on Mode Change
-- ============================================================================

local mode_switch_group = vim.api.nvim_create_augroup("UserAutoSaveModeSwitch", { clear = true })

vim.api.nvim_create_autocmd("ModeChanged", {
  group = mode_switch_group,
  pattern = { "i:n", "n:i" },
  callback = save_if_writable,
})

-- ============================================================================
-- Go Language Configuration
-- ============================================================================

local go_group = vim.api.nvim_create_augroup("AstroGoExtras", { clear = true })

-- Go-specific keymaps
vim.api.nvim_create_autocmd("FileType", {
  group = go_group,
  pattern = { "go", "gomod", "gowork" },
  callback = function(event)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = event.buf, desc = desc })
    end

    local function with_tag_input(cmd, prompt)
      vim.ui.input({ prompt = prompt, default = "json" }, function(value)
        if value and #value > 0 then vim.cmd(cmd .. " " .. value) end
      end)
    end

    -- Test and Build
    map("n", "<leader>ct", "<cmd>GoTest<cr>", "Go test package")
    map("n", "<leader>cT", "<cmd>GoTestFunc<cr>", "Go test function")
    map("n", "<leader>cr", "<cmd>GoRun<cr>", "Go run current module")
    map("n", "<leader>cb", "<cmd>GoBuild<cr>", "Go build package")

    -- Code generation
    map("n", "<leader>ci", "<cmd>GoIfErr<cr>", "Insert if err snippet")
    map("n", "<leader>cA", function() with_tag_input("GoAddTag", "Add struct tag(s)") end, "Add struct tags")
    map("n", "<leader>cR", function() with_tag_input("GoRmTag", "Remove struct tag(s)") end, "Remove struct tags")
  end,
})

-- Auto-organize imports with debouncing
local organize_imports_timer = nil

local function organize_imports(bufnr)
  if not is_buffer_valid_and_writable(bufnr) then return end

  local params = vim.lsp.util.make_range_params(nil, nil, bufnr)
  params.context = { only = { "source.organizeImports" } }

  vim.lsp.buf_request(bufnr, "textDocument/codeAction", params, function(err, result)
    if err or not result then return end

    for _, action in pairs(result) do
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
      elseif action.command then
        vim.lsp.buf.execute_command(action.command)
      end
    end
  end)
end

local function debounced_organize_imports(bufnr)
  if organize_imports_timer then
    organize_imports_timer:stop()
  end

  organize_imports_timer = vim.defer_fn(function()
    organize_imports(bufnr)
  end, 500) -- 500ms debounce
end

-- Auto-organize imports and save on InsertLeave
vim.api.nvim_create_autocmd("InsertLeave", {
  group = go_group,
  pattern = { "*.go", "*.gomod", "*.gowork" },
  callback = function(event)
    local buf = event.buf

    if not is_buffer_valid_and_writable(buf) then return end
    if vim.api.nvim_buf_get_name(buf) == "" then return end
    if not has_lsp_client(buf, "gopls") then return end

    vim.schedule(function()
      if not is_buffer_valid_and_writable(buf) then return end

      -- Organize imports first
      debounced_organize_imports(buf)

      -- Then save after a delay
      vim.defer_fn(function()
        if not vim.api.nvim_buf_is_valid(buf) or not vim.bo[buf].modified then return end
        vim.api.nvim_buf_call(buf, function()
          vim.cmd("silent! write")
        end)
      end, 600)
    end)
  end,
})

-- ============================================================================
-- Terminal Configuration
-- ============================================================================

local ok, term_mod = pcall(require, "toggleterm.terminal")
if ok then
  local Terminal = term_mod.Terminal
  local TERMINAL_HEIGHT = 15

  -- Create bottom terminal instance
  local bottom_terminal = Terminal:new({
    direction = "horizontal",
    hidden = true,
    close_on_exit = true,
    start_in_insert = true,
  })

  local function toggle_bottom_terminal()
    if bottom_terminal:is_open() then
      bottom_terminal:close()
    else
      bottom_terminal:open(TERMINAL_HEIGHT)
      if vim.bo.modifiable then vim.cmd("startinsert") end
    end
  end

  -- Terminal toggle keymaps
  vim.keymap.set("n", "<C-,>", toggle_bottom_terminal, { desc = "Toggle bottom terminal", silent = true })
  vim.keymap.set("t", "<C-,>", toggle_bottom_terminal, { desc = "Toggle bottom terminal", silent = true })

  -- Terminal buffer configuration
  local neo_term_group = vim.api.nvim_create_augroup("UserNeoTreeToggleTerm", { clear = true })

  local function configure_terminal_buffer(buf)
    if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
    vim.api.nvim_set_option_value("buflisted", false, { buf = buf })
    vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
    pcall(vim.api.nvim_buf_set_var, buf, "neo_tree_skip_follow", true)
  end

  -- Auto-configure terminal buffers
  vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
    group = neo_term_group,
    pattern = "term://*",
    callback = function(event) configure_terminal_buffer(event.buf) end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = neo_term_group,
    pattern = "toggleterm",
    callback = function(event) configure_terminal_buffer(event.buf) end,
  })
end
