# TON UTILISATEUR (home-manager) : le rice de BASE, actif sur toutes les machines.
# Chaque brique du rice a son fichier dans home/desktop/.
#
# Les modules optionnels (modules/*.nix) ajoutent leur partie utilisateur
# eux-mêmes ; les réglages propres à une machine (écrans…) sont dans
# hosts/<machine>/home.nix.
{ pkgs, ... }:

{
  imports = [
    ./desktop/niri.nix # compositeur : fenêtres, raccourcis, écrans
    ./desktop/waybar.nix # barre
    ./desktop/launcher.nix # anyrun : lanceur + menus (presse-papiers, extinction)
    ./desktop/notifications.nix # mako
    ./desktop/idle.nix # swayidle (+ gtklock côté système)
    ./desktop/services.nix # fond d'écran, presse-papiers, OSD, lumière bleue, polkit, USB
    ./terminal.nix # foot ou Ghostty + fish, starship, zoxide, carapace
    ./neovim.nix # Neovim + AstroNvim (config dans dotfiles/nvim)
    ./tools.nix # outils de base : CLI, images, vidéo, PDF, captures
    ./browsers/firefox.nix # réglages communs : browsers/browser-common.nix
  ];

  home.username = "asap";
  home.homeDirectory = "/home/asap";

  # Icônes (Stylix gère couleurs, polices et curseur, pas les icônes).
  stylix.icons = {
    enable = true;
    package = pkgs.papirus-icon-theme;
    dark = "Papirus-Dark";
    light = "Papirus-Light";
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "PurpleFlood";
      email = "flygus.games@gmail.com";
    };
  };

  home.stateVersion = "26.05";
}
