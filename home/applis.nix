# APPLIS du quotidien et outils en terminal.
{ pkgs, ... }:

{
  # Fichiers (Thunar est installé côté système).
  programs.yazi.enable = true;

  # Annotation des captures : copie directe dans le presse-papiers.
  programs.satty = {
    enable = true;
    settings.general = {
      copy-command = "wl-copy";
      early-exit = true; # se ferme après la copie
      output-filename = "~/Images/Captures/annotee-%Y-%m-%d_%H-%M-%S.png";
    };
  };

  programs.zathura.enable = true; # PDF
  programs.mpv.enable = true; # vidéo
  programs.neovim.enable = true; # éditeur (AstroNvim viendra plus tard)

  home.packages = with pkgs; [
    imv # images
    vlc
    wiremix # mixeur PipeWire en terminal
    bluetui # Bluetooth en terminal
    playerctl # touches lecture / pause / suivant
    brightnessctl # luminosité
    grim # capture d'une zone…
    slurp # …sélectionnée à la souris
    wl-clipboard # wl-copy / wl-paste
    btop
    fastfetch
  ];
}
