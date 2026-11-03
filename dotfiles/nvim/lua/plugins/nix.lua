return {
  {
    "AstroNvim/astrolsp",
    opts = {
      servers = { "nixd" },
      config = {
        nixd = {
          settings = { nixd = { formatting = { command = { "nixfmt" } } } },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "nix" } },
  },
}
