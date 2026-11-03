# TON UTILISATEUR (home-manager) : applis, dotfiles et rice.
# Chaque brique du rice a son fichier dans home/bureau/.
{ pkgs, ... }:

{
  imports = [
    ./bureau/niri.nix # compositeur : fenêtres, raccourcis, écrans
    ./bureau/waybar.nix # barre
    ./bureau/lanceur.nix # anyrun : lanceur + menus (presse-papiers, extinction)
    ./bureau/notifications.nix # mako
    ./bureau/veille.nix # swayidle (+ gtklock côté système)
    ./bureau/services.nix # fond d'écran, presse-papiers, OSD, lumière bleue, polkit, USB
    ./terminal.nix # Ghostty + Nushell + starship, zoxide, carapace
    ./applis.nix # yazi, images, PDF, vidéo, son, Bluetooth…
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
