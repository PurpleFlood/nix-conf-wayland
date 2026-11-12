# MINIMAL : profil niri seul (rice + Firefox + Neovim + fish), pour installer
# N'IMPORTE QUEL PC sans rien ajouter au dépôt. Une fois installé, on crée
# son vrai dossier hosts/<nom>/ et on bascule dessus.
#
# Ce host lit des choses SUR LA MACHINE (d'où `--impure`) :
#   - la config matérielle générée à l'installation ;
#   - le type de démarrage (UEFI ou BIOS), détecté tout seul.
#
# Installation depuis la clé live (dans le dépôt cloné) :
#   RICE_HARDWARE=/mnt/etc/nixos/hardware-configuration.nix \
#     nixos-install --flake .#minimal --impure
#
# Rebuild sur la machine installée :
#   nixos-rebuild switch --flake .#minimal --impure --sudo
#
# En BIOS (vieux PC), GRUB s'installe sur /dev/sda ; pour un autre disque :
#   RICE_DISK=/dev/nvme0n1 … (même commande)
{ ... }:

let
  # Démarrage UEFI si le firmware l'expose, sinon BIOS classique.
  uefi = builtins.pathExists /sys/firmware/efi;

  disk =
    let
      d = builtins.getEnv "RICE_DISK";
    in
    if d != "" then d else "/dev/sda";
in
{
  imports = [ (import ../hardware.nix ./.) ]; # voir hosts/hardware.nix

  # UEFI : systemd-boot (le plus simple, marche partout)
  boot.loader.systemd-boot = {
    enable = uefi;
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = uefi;

  # BIOS : GRUB sur le disque entier
  boot.loader.grub = {
    enable = !uefi;
    device = disk;
    configurationLimit = 10;
  };

  # Profil niri (par défaut), aucun module optionnel : c'est tout l'intérêt.

  # Version de la PREMIÈRE installation : ne pas changer ensuite.
  system.stateVersion = "26.05";
}
