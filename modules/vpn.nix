# VPN Mullvad (WireGuard) : ta commande `vpn` d'avant, inchangée.
#   vpn <pays> | off | status | list
# Les fichiers .conf restent dans /etc/wireguard/<pays>/ (hors dépôt : ce sont des secrets).
# Le bouton de waybar (home/desktop/waybar.nix) l'utilise sans mot de passe.
#
#   rice.vpn.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:

let
  vpn = pkgs.callPackage ../pkgs/vpn.nix { };
in
{
  options.rice.vpn.enable = lib.mkEnableOption "la commande vpn (Mullvad / WireGuard) et son bouton dans waybar";

  config = lib.mkIf config.rice.vpn.enable {
    environment.systemPackages = [
      vpn
      pkgs.wireguard-tools
    ];

    # `sudo vpn …` sans mot de passe, pour le bouton de la barre.
    security.sudo.extraRules = [
      {
        users = [ config.rice.user ];
        commands = [
          {
            command = "/run/current-system/sw/bin/vpn";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
