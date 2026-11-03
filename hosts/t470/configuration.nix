# THINKPAD T470 : ce qui est propre à cette machine.
# Le rice commun (niri, waybar…) vient de modules/ et home/.
{ ... }:

{
  imports = [
    # Disques et modules de démarrage, générés à l'installation du T470.
    ./hardware-configuration.nix
  ];

  networking.hostName = "t470";

  # ─── Démarrage : Limine (thème et fond appliqués par Stylix) ────────────
  boot.loader.limine = {
    enable = true;
    maxGenerations = 10; # entrées dans le menu
    enableEditor = false; # empêche de modifier les entrées au démarrage
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.useTmpfs = true;

  # ─── Matériel ──────────────────────────────────────────────────────────
  hardware.enableRedistributableFirmware = true; # Wi-Fi Intel, microcode

  # Clavier physique en QWERTY (le rice est en AZERTY par défaut).
  console.keyMap = "us";

  # Capot fermé : mise en veille (gtklock verrouille juste avant, via swayidle).
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
  };

  # Accès SSH depuis le PC (pratique pour dépanner) : ssh asap@t470
  services.openssh.enable = true;

  # ─── Nix : ménage automatique des vieilles générations ─────────────────
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Version de la PREMIÈRE installation du T470 : ne pas changer.
  system.stateVersion = "26.05";
}
