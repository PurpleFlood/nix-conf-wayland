# THÈME GLOBAL : Stylix applique une palette FIXE et sobre au reste du système
# (applis GTK/Qt, écran de connexion, verrouillage, menu de démarrage, yazi,
# zathura…), ainsi que les polices, le curseur et l'opacité.
#
# Le rice lui-même (niri, waybar, notifications, lanceur, terminal) suit le fond
# d'écran à chaud, sans rebuild : voir home/desktop/theming.nix (commande `wallpaper`).
#
# Changer la palette fixe : remplace le nom dans base16Scheme, puis rebuild.
# Quelques choix : catppuccin-mocha, rose-pine, gruvbox-dark-medium, everforest,
# tokyo-night-dark, kanagawa, nord (liste : ls $(nix build --print-out-paths
# nixpkgs#base16-schemes)/share/themes).
{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (config.rice.profile == "niri") {
    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      # Image de fond de l'écran de connexion, du verrouillage et du menu de démarrage.
      image = ../../../wallpapers/wallhaven-r7gzzm.jpg;
      polarity = "dark"; # palette sombre

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        sansSerif = {
          package = pkgs.noto-fonts;
          name = "Noto Sans";
        };
        serif = {
          package = pkgs.noto-fonts;
          name = "Noto Serif";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };
      opacity = {
        terminal = 0.85;
        desktop = 0.85;
      };
    };
  };
}
