# NEOVIM avec AstroNvim : ta config d'avant, dans dotfiles/nvim.
#
# ~/.config/nvim est un lien direct vers le dépôt : tu modifies ta config
# comme d'habitude, sans rebuild, et lazy.nvim peut écrire lazy-lock.json.
# Stylix ne touche PAS à Neovim : AstroNvim garde son propre thème.
{ config, pkgs, ... }:

{
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/git/nix-conf-wayland/dotfiles/nvim";

  stylix.targets.neovim.enable = false;

  home.sessionVariables.EDITOR = "nvim";

  home.packages = with pkgs; [
    neovim
    # Outils dont AstroNvim a besoin
    gcc # compiler les grammaires treesitter
    ripgrep # recherche dans les fichiers
    fd # recherche de fichiers
    lazygit # git dans Neovim
    nodejs # certains serveurs de langage
    # Nix dans Neovim (voir dotfiles/nvim/lua/plugins/nix.lua)
    nixd
    nixfmt
    tree-sitter
  ];
}
