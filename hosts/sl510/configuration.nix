# THINKPAD SL510 : portable prêté à un proche qui débute sous Linux.
# Profil simple (Cinnamon), mises à jour automatiques depuis GitHub,
# dépannage à distance par Tailscale + SSH (compte admin).
#
# Installation : comme hosts/minimal, avec `.#sl510` :
#   RICE_HARDWARE=/mnt/etc/nixos/hardware-configuration.nix \
#     nixos-install --flake .#sl510 --impure
# Puis copier /etc/nixos/hardware-configuration.nix dans ce dossier et le
# commiter : les rebuilds suivants n'ont plus besoin de --impure.
{ private, ... }:

{
  # Config matérielle : ./hardware-configuration.nix une fois copiée
  # (avant : celle de la machine, voir hosts/hardware.nix).
  imports = [ (import ../hardware.nix ./.) ];

  # ─── Profil et modules ─────────────────────────────────────────────────
  rice = {
    profile = "simple";
    user = private.hostUsers.sl510 or "invite"; # son compte (sans sudo), nommé dans le dépôt privé
    simple.desktop = "cinnamon"; # "xfce" si la machine reste lente
    simple.autoUpgrade = false;
    tailscale.enable = true; # pour le dépanner où qu'il soit
    keyboard = "es";
  };

  # BIOS classique (pas d'UEFI) : GRUB sur le disque entier.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    configurationLimit = 5;
  };

  hardware.cpu.intel.updateMicrocode = true;

  # Version de la PREMIÈRE installation : ne pas changer ensuite.
  system.stateVersion = "26.05";
}
