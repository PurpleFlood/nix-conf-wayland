# PROFILS DE BUREAU : un seul est actif par machine (option rice.profile).
{ ... }:

{
  imports = [
    ./niri # ton rice : niri, waybar, Stylix, ton home-manager
    ./simple.nix # bureau classique pour débutant : Cinnamon, Plasma ou XFCE
  ];
}
