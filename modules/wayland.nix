# WAYLAND : tout ce dont un bureau Wayland a besoin, quel que soit le compositeur.
#
# ┌─────────────────────────────────────────────────────────────────────┐
# │ À CHOISIR ENSEMBLE : le compositeur (Hyprland, niri, sway, river…). │
# │ Il s'ajoutera dans la section « Compositeur » en bas de ce fichier. │
# └─────────────────────────────────────────────────────────────────────┘
{ pkgs, ... }:

{
  # Accélération graphique (OpenGL / Vulkan).
  hardware.graphics.enable = true;

  # Portails : partage d'écran, sélecteur de fichiers, thèmes…
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ];
  };

  # Fenêtres d'authentification (sudo graphique, montage de disques…).
  security.polkit.enable = true;

  # Réglages GTK (thèmes, mode sombre) et trousseau de mots de passe.
  programs.dconf.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Applis Electron / Chromium (Discord, VS Code…) en Wayland natif.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Pour que les vieilles applis X11 tournent aussi (via XWayland).
  programs.xwayland.enable = true;

  # Outils de base sous Wayland.
  environment.systemPackages = with pkgs; [
    foot # terminal Wayland léger, utile en secours
    wl-clipboard # copier-coller en ligne de commande (wl-copy / wl-paste)
    wayland-utils # `wayland-info` pour diagnostiquer
  ];

  # ─── Compositeur ───────────────────────────────────────────────────────
  # (vide pour l'instant : on le choisira à la prochaine étape)
}
