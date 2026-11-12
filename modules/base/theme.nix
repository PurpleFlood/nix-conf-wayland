# THÈME GLOBAL : Stylix tire une palette du fond d'écran et l'applique partout
# (niri, waybar, foot/Ghostty, mako, GTK, Qt, ReGreet, yazi, zathura…).
#
# Pour changer de fond : remplace wallpapers/fond.jpg (ou change le chemin
# ci-dessous), puis rebuild — toutes les couleurs suivent.
{ pkgs, ... }:

{
  stylix = {
    enable = true;
    image = ../../wallpapers/wallhaven-r7gzzm.jpg;
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
}
