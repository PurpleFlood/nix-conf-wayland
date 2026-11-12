# OUTILS DE BASE (toutes les machines) : ce qu'il faut pour que le rice
# soit complet et pour travailler en terminal. Rien de lourd ici :
# les applis généralistes sont dans modules/apps.nix, le dev dans modules/dev.nix.
{ pkgs, ... }:

{
  # ─── Outils du rice ────────────────────────────────────────────────────
  programs.yazi.enable = true; # fichiers en terminal (Thunar côté système)

  # Annotation des captures : copie directe dans le presse-papiers.
  programs.satty = {
    enable = true;
    settings.general = {
      copy-command = "wl-copy";
      early-exit = true; # se ferme après la copie
      output-filename = "~/Images/Captures/annotated-%Y-%m-%d_%H-%M-%S.png";
    };
  };

  programs.zathura.enable = true; # PDF
  programs.mpv.enable = true; # vidéo

  # GitHub en ligne de commande + identifiants pour git push.
  # Une seule fois par machine : `gh auth login`.
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  home.packages = with pkgs; [
    # ─── Bureau Wayland ──────────────────────────────────────────────────
    imv # images
    wiremix # mixeur PipeWire en terminal
    bluetui # Bluetooth en terminal
    playerctl # touches lecture / pause / suivant
    brightnessctl # luminosité
    grim # capture d'une zone…
    slurp # …sélectionnée à la souris
    wl-clipboard # wl-copy / wl-paste
    libnotify # notify-send

    # ─── Terminal / CLI ──────────────────────────────────────────────────
    bat
    eza
    fzf
    btop
    htop
    fastfetch
    glow
    jq
    _7zz
    xz
    zstd
    unzip
    sshfs
    openssl
  ];
}
