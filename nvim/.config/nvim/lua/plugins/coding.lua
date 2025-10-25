return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "java",
        "hcl",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "terraform",
        "typescript",
        "vim",
        "yaml",
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "java-debug-adapter", "java-test" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- make sure mason installs the server
      servers = {
        jdtls = {},
        copilot = { enabled = false },
        terraformls = {
          cmd = { "terraform-ls", "serve" },
          filetypes = { "terraform", "terraform-vars", "tf" },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(".terraform", ".git")(fname)
          end,
          settings = {
            terraform = {
              experimentalFeatures = {
                prefillRequiredFields = true, -- auto-populate Azure resource fields like name/location
              },
            },
          },
        },
      },
      setup = {
        jdtls = function()
          return true -- avoid duplicate servers
        end,
      },
    },
  },
}
