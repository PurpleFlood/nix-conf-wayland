# VPN Mullvad (WireGuard) : ta commande `vpn` d'avant, inchangée.
#   vpn <pays> | off | status | list
# Les fichiers .conf restent dans /etc/wireguard/<pays>/ (hors dépôt : ce sont des secrets).
# Le bouton de waybar (home/bureau/waybar.nix) l'utilise sans mot de passe.
{ pkgs, ... }:

let
  vpn = pkgs.callPackage ../pkgs/vpn.nix { };
in
{
  environment.systemPackages = [
    vpn
    pkgs.wireguard-tools
  ];

  # `sudo vpn …` sans mot de passe, pour le bouton de la barre.
  security.sudo.extraRules = [
    {
      users = [ "asap" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/vpn";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
