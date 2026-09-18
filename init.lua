-- ~/.config/nvim/init.lua

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- 1. Catppuccin Theme Setup (Macchiato flavor)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "macchiato",
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- 2. Treesitter (Syntax Highlighting & Parsing)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "c", "python", "bash" },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- 3. Mason & LSP (For C, Python/Basedpyright, and Bash)
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim" },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      vim.lsp.enable("clangd")
      vim.lsp.enable("basedpyright")
      vim.lsp.enable("bashls")
    end,
  },

  -- 4. Auto-Completion Engine (nvim-cmp)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
        })
      })
    end,
  },

  -- 5. Local AI Integration (CodeCompanion via Ollama)
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = { adapter = "ollama" },
          inline = { adapter = "ollama" },
        },
        adapters = {
          ollama = function()
            return require("codecompanion.adapters").extend("ollama", {})
          end,
        },
      })
    end,
  },
})
--------------------------------------------------
-- Custom Compile Command for C, C++, Python, and Bash
--------------------------------------------------
vim.api.nvim_create_user_command("Compile", function()
    vim.cmd("w")
    
    local file = vim.fn.expand("%:p")
    local ext = vim.fn.expand("%:e")
    local filename = vim.fn.expand("%:r")
    local cmd = ""

    if ext == "c" then
        cmd = string.format("gcc %s -o %s && ./%s", file, filename, filename)
    elseif ext == "cpp" then
        cmd = string.format("g++ %s -o %s && ./%s", file, filename, filename)
    elseif ext == "py" then
        cmd = string.format("python3 %s", file)
    elseif ext == "sh" then
        cmd = string.format("bash %s", file)
    else
        print("No compilation rule for ." .. ext .. " files!")
        return
    end

    vim.cmd("split | term " .. cmd)
end, {})
