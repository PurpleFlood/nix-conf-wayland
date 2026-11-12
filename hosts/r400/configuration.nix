# THINKPAD R400 : machine légère (Core 2 Duo, 3 Go, GMA 4500).
# Base seule + quelques modules légers.
{ ... }:

{
  imports = [ ./hardware-configuration.nix ]; # généré à l'installation

  # ─── Modules et réglages du rice ───────────────────────────────────────
  # foot (terminal par défaut) : la GMA 4500 n'a qu'OpenGL 2.1, Ghostty ne
  # démarre pas.
  rice = {
    dev = {
      enable = true;
      aiAgents = false; # Claude Code / opencode : pas d'AVX sur le Core 2 Duo
    };
    vpn.enable = true;
    homeNetwork.enable = true;
  };

  # BIOS classique (pas d'UEFI) : GRUB sur le disque entier.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    configurationLimit = 5;
  };

  hardware.cpu.intel.updateMicrocode = true;

  # Peu de RAM : plus de mémoire compressée (zram et earlyoom sont dans la base).
  zramSwap.memoryPercent = 50;

  # Petit disque : ménage plus fréquent.
  nix.gc.options = "--delete-older-than 7d";

  system.stateVersion = "26.05";
}
