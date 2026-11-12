# MINIMAL : la base seule (rice + Firefox + Neovim + fish), pour installer
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
#   sudo nixos-rebuild switch --flake .#minimal --impure
#
# En BIOS (vieux PC), GRUB s'installe sur /dev/sda ; pour un autre disk :
#   RICE_DISK=/dev/nvme0n1 … (même commande)
{ ... }:

let
  # Chemin de la config matérielle : /etc/nixos sur la machine installée,
  # /mnt/etc/nixos pendant l'installation (variable RICE_HARDWARE).
  hardwareConfig =
    let
      path = builtins.getEnv "RICE_HARDWARE";
    in
    if path != "" then /. + path else /etc/nixos/hardware-configuration.nix;

  # Démarrage UEFI si le firmware l'expose, sinon BIOS classique.
  uefi = builtins.pathExists /sys/firmware/efi;

  disk =
    let
      d = builtins.getEnv "RICE_DISK";
    in
    if d != "" then d else "/dev/sda";
in
{
  imports = [ hardwareConfig ];

  # UEFI : systemd-boot (le plus simple, marche partout)
  boot.loader.systemd-boot = {
    enable = uefi;
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = uefi;

  # BIOS : GRUB sur le disk entier
  boot.loader.grub = {
    enable = !uefi;
    device = disk;
    configurationLimit = 10;
  };

  # Aucun module optionnel : c'est tout l'intérêt.

  # Version de la PREMIÈRE installation : ne pas changer ensuite.
  system.stateVersion = "26.05";
}
