# TON UTILISATEUR (home-manager) : le rice de BASE, actif sur toutes les machines.
# Chaque brique du rice a son fichier dans home/bureau/.
#
# Les modules optionnels (modules/*.nix) ajoutent leur partie utilisateur
# eux-mêmes ; les réglages propres à une machine (écrans…) sont dans
# hosts/<machine>/home.nix.
{ pkgs, ... }:

{
  imports = [
    ./bureau/niri.nix # compositeur : fenêtres, raccourcis, écrans
    ./bureau/waybar.nix # barre
    ./bureau/lanceur.nix # anyrun : lanceur + menus (presse-papiers, extinction)
    ./bureau/notifications.nix # mako
    ./bureau/veille.nix # swayidle (+ gtklock côté système)
    ./bureau/services.nix # fond d'écran, presse-papiers, OSD, lumière bleue, polkit, USB
    ./terminal.nix # foot ou Ghostty + fish, starship, zoxide, carapace
    ./neovim.nix # Neovim + AstroNvim (config dans dotfiles/nvim)
    ./outils.nix # outils de base : CLI, images, vidéo, PDF, captures
    ./navigateurs/firefox.nix # réglages communs : navigateurs/navigateur-commun.nix
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
