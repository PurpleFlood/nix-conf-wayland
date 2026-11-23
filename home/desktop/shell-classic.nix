# RICE CLASSIQUE (rice.shell = "classic") : waybar, anyrun, mako.
# Le verrouillage (gtklock), les fonds d'écran (commande wallpaper, Mod+Maj+W)
# et les couleurs à chaud (matugen) suivent aussi ce choix : voir idle.nix,
# services.nix, theming.nix et les raccourcis dans niri.nix.
{ ... }:

{
  imports = [
    ./waybar.nix # barre
    ./launcher.nix # anyrun : lanceur + menus (presse-papiers, extinction)
    ./notifications.nix # mako
  ];
}
