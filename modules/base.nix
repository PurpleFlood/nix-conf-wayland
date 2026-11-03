# SOCLE commun à toutes les machines : Nix, langue, utilisateur, son, réseau.
{ pkgs, ... }:

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
  console.keyMap = "fr";
  # Disposition reprise par la plupart des compositeurs Wayland (via XKB).
  services.xserver.xkb.layout = "fr";

  # ─── Utilisateur ───────────────────────────────────────────────────────
  users.users.asap = {
    isNormalUser = true;
    description = "asap";
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "input" ];
    initialPassword = "nixos"; # à changer avec `passwd` sur une vraie machine
  };
  security.sudo.wheelNeedsPassword = false; # confortable en VM ; à revoir sur une vraie machine

  # Connexion automatique sur le premier terminal (tty1).
  services.getty.autologinUser = "asap";

  # ─── Réseau ────────────────────────────────────────────────────────────
  networking.networkmanager.enable = true;

  # ─── Son (PipeWire) ────────────────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ─── Paquets de base (le reste ira dans home/asap.nix) ─────────────────
  environment.systemPackages = with pkgs; [
    git
    neovim
    wget
    curl
    htop
    unzip
  ];
  environment.variables.EDITOR = "nvim";

  # ─── Polices ───────────────────────────────────────────────────────────
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];
}
