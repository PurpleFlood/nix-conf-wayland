# THINKPAD T470 : ce qui est propre à cette machine + les modules allumés.
# Le socle vient de modules/core, le rice du profil niri (modules/profiles/niri + home/).
{ ... }:

{
  imports = [
    # Disques et modules de démarrage, générés à l'installation du T470.
    ./hardware-configuration.nix
  ];

  # ─── Modules et réglages du rice ───────────────────────────────────────
  rice = {
    keyboard = "us"; # clavier physique en QWERTY
    terminal = "ghostty";

    apps.enable = true;
    dev.enable = true;
    music.enable = true;
    virtualisation.enable = true;
    zen.enable = true;
    searxng.enable = true;
    i2p.enable = true;
    tor.enable = true;
    vpn.enable = true;
    homeNetwork.enable = true;
  };

  # ─── Démarrage : Limine (thème et fond appliqués par Stylix) ────────────
  boot.loader.limine = {
    enable = true;
    maxGenerations = 10; # entrées dans le menu
    enableEditor = false; # empêche de modifier les entrées au démarrage
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.useTmpfs = true;

  # Version de la PREMIÈRE installation du T470 : ne pas changer.
  system.stateVersion = "26.05";
}
