# THINKPAD R400 : machine légère (Core 2 Duo, 3 Go, GMA 4500).
{ ... }:

{
  imports = [ ./hardware-configuration.nix ]; # généré à l'installation

  networking.hostName = "r400";

  # BIOS classique (pas d'UEFI) : GRUB sur le disque entier.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    configurationLimit = 5;
  };

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  # Peu de RAM : mémoire compressée + tueur de processus avant le gel.
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };
  services.earlyoom.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
  };

  services.openssh.enable = true; # ssh asap@r400 depuis le PC

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "26.05";
}
