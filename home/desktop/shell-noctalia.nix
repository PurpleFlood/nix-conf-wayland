# RICE NOCTALIA (rice.shell = "noctalia") : Noctalia Shell remplace d'un bloc
# la barre, le lanceur, les notifications, l'affichage volume/luminosité, la
# lumière bleue, l'écran de verrouillage, les fonds d'écran et leurs couleurs.
#
# Réglages : dans son interface (icône en haut à droite, ou Mod+Maj+N).
# Ils sont enregistrés dans ~/.config/noctalia/ : pas de rebuild pour les changer.
# Fonds d'écran : le dossier se choisit dans les réglages (~/Images/Wallpapers).
#
# Raccourcis : home/desktop/niri.nix (commandes « noctalia-shell ipc call … »).
{ pkgs, ... }:

{
  # Le paquet embarque ce qu'il utilise (brightnessctl, cliphist, wlsunset, ddcutil).
  home.packages = [ pkgs.noctalia-shell ];
}
