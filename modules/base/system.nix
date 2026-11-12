# SOCLE commun à toutes les machines : Nix, langue, utilisateur, réseau, son, matériel.
# Partie de la base : actif partout.
{ lib, pkgs, ... }:

{
  # ─── Nix ───────────────────────────────────────────────────────────────
  nix.settings = {
    trusted-users = [
      "root"
      "@wheel"
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };
  nixpkgs.config.allowUnfree = true;

  # ─── Langue, heure, clavier ────────────────────────────────────────────
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";
  # (clavier : option rice.keyboard, dans base/options.nix)

  # ─── Utilisateur ───────────────────────────────────────────────────────
  # bash reste le shell de connexion (il prépare la session) ;
  # c'est le terminal (foot ou Ghostty) qui lance fish.
  users.users.asap = {
    isNormalUser = true;
    description = "asap";
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager"
      "input"
    ];
    initialPassword = "nixos"; # à changer avec `passwd` sur une vraie machine
  };

  # ─── Réseau : NetworkManager, avec iwd comme moteur Wi-Fi ──────────────
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

  # Chaque machine s'annonce sur le réseau local : ssh asap@r400.local
  services.avahi = {
    enable = true;
    nssmdns4 = true; # le système sait résoudre les noms en .local
    publish = {
      enable = true;
      addresses = true;
    };
  };

  # Accès SSH entre tes machines (dépannage, rebuilds à distance).
  services.openssh.enable = true;

  # ─── Son : PipeWire (JACK basse latence : module musique) ──────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # ─── Matériel ──────────────────────────────────────────────────────────
  hardware.enableRedistributableFirmware = true; # Wi-Fi, microcode…
  hardware.bluetooth.enable = true;
  services.udisks2.enable = true; # montage des clés USB (utilisé par udiskie)
  services.power-profiles-daemon.enable = true; # modes économie / équilibré / performance
  services.upower.enable = true; # niveau de batterie (pour waybar)

  # Portables : capot fermé = mise en veille (gtklock verrouille juste avant).
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
  };

  # ─── Paquets système de base (le reste est dans home/) ─────────────────
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    unzip
    ghostty.terminfo # les machines comprennent Ghostty quand on s'y connecte en SSH
  ];

  # Permet aux programmes précompilés pour d'autres Linux de tourner
  # (outils téléchargés par Mason dans Neovim, binaires de jeux, etc.).
  programs.nix-ld.enable = true;

  # Autocomplétion des paquets installés dans le système pour fish
  programs.fish.enable = true;

  # Swap compressée en RAM : beaucoup plus de marge avant de saturer
  zramSwap.enable = true;
  # Tue le programme le plus gourmand AVANT que tout le système gèle
  services.earlyoom.enable = true;
  # Autorise toutes les combinaisons Alt+SysRq (R E I S U B) en cas de gel
  boot.kernel.sysctl."kernel.sysrq" = 1;

  # ─── Nix : ménage automatique des vieilles générations ─────────────────
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = lib.mkDefault "--delete-older-than 14d";
  };
}
