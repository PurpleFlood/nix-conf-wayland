# TAILSCALE : un réseau privé entre tes machines, où qu'elles soient (chez toi,
# chez un proche, en déplacement). Chaque machine est joignable par son nom :
#   ssh asap@sl510
#   nixos-rebuild switch --flake .#sl510 --target-host asap@sl510 --sudo --ask-sudo-password
#
# Une seule fois par machine, après le rebuild : `sudo tailscale up`
# (ouvre un lien pour la relier à ton compte Tailscale).
#
#   rice.tailscale.enable = true;
{ config, lib, ... }:

{
  options.rice.tailscale.enable = lib.mkEnableOption "Tailscale (accès à distance)";

  config = lib.mkIf config.rice.tailscale.enable {
    services.tailscale.enable = true;

    # Ce qui arrive par Tailscale vient de tes propres machines : pas filtré.
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };
}
