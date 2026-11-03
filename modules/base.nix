# SOCLE commun à toutes les machines : Nix, langue, utilisateur, réseau, son, matériel.
{ lib, pkgs, ... }:

{
  # ─── Nix ───────────────────────────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nixpkgs.config.allowUnfree = true;

  # ─── Langue, heure, clavier ────────────────────────────────────────────
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";
  console.keyMap = lib.mkDefault "fr"; # le T470 passe en "us" (hosts/t470)

  # ─── Utilisateur ───────────────────────────────────────────────────────
  # bash reste le shell de connexion (il prépare la session) ;
  # c'est le terminal (Ghostty) qui lance Nushell.
  users.users.asap = {
    isNormalUser = true;
    description = "asap";
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "input" ];
    initialPassword = "nixos"; # à changer avec `passwd` sur une vraie machine
  };

  # ─── Réseau : NetworkManager, avec iwd comme moteur Wi-Fi ──────────────
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

  # ─── Son : PipeWire (+ JACK pour Reaper) ───────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ─── Matériel ──────────────────────────────────────────────────────────
  hardware.bluetooth.enable = true;
  services.udisks2.enable = true; # montage des clés USB (utilisé par udiskie)
  services.power-profiles-daemon.enable = true; # modes économie / équilibré / performance
  services.upower.enable = true; # niveau de batterie (pour waybar)

  # ─── Paquets système de base (le reste est dans home/) ─────────────────
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    unzip
  ];
}
