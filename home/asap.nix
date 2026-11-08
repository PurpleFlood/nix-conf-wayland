# TON UTILISATEUR (home-manager) : applis, dotfiles et rice.
# Chaque brique du rice a son fichier dans home/bureau/.
{
  lib,
  pkgs,
  host,
  ...
}:

{
  imports = [
    ./bureau/niri.nix # compositeur : fenêtres, raccourcis, écrans
    ./bureau/waybar.nix # barre
    ./bureau/lanceur.nix # anyrun : lanceur + menus (presse-papiers, extinction)
    ./bureau/notifications.nix # mako
    ./bureau/veille.nix # swayidle (+ gtklock côté système)
    ./bureau/services.nix # fond d'écran, presse-papiers, OSD, lumière bleue, polkit, USB
    ./terminal.nix # Ghostty + Nushell + starship, zoxide, carapace
    ./neovim.nix # Neovim + AstroNvim (config dans dotfiles/nvim)
    ./applis.nix # applis communes
    ./navigateurs/firefox.nix # réglages communs : navigateurs/navigateur-commun.nix
    ./navigateurs/zen.nix
  ]
  # Réglages propres à la machine, s'ils existent : home/pc.nix, home/t470.nix…
  ++ lib.optional (builtins.pathExists (./. + "/${host}.nix")) (./. + "/${host}.nix");

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

  # Raccourci pour Cardinal autonome (le paquet n'en fournit pas)
  xdg.desktopEntries.cardinal = {
    name = "Cardinal";
    comment = "Rack modulaire (VCV Rack libre)";
    exec = "Cardinal";
    icon = "audio-x-generic";
    categories = [
      "Audio"
      "AudioVideo"
    ];
  };

  home.stateVersion = "26.05";
}
