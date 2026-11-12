# PC FIXE (côté utilisateur) : écrans, bureaux, carte NVIDIA.
# Importé par hosts/pc/configuration.nix. Les jeux, la VR et l'IA sont
# dans leurs modules (modules/gaming.nix, vr.nix, ia.nix).
{ lib, pkgs, ... }:

{
  # ─── Écrans ────────────────────────────────────────────────────────────
  # Noms à vérifier avec `niri msg outputs` (sous Wayland, NVIDIA ne les
  # nomme pas comme sous X11 : DP-0 → DP-1, HDMI-0 → HDMI-A-1…).
  # Même disposition qu'avant : le petit écran à gauche, le 240 Hz à droite.
  programs.niri.settings.outputs = {
    "DP-1" = {
      mode = {
        width = 1680;
        height = 1050;
        refresh = 59.95;
      };
      position = {
        x = 0;
        y = 0;
      };
    };
    "HDMI-A-1" = {
      mode = {
        width = 1920;
        height = 1080;
        refresh = 239.76;
      };
      position = {
        x = 1680;
        y = 0;
      };
      focus-at-startup = true; # écran principal
    };
    # Le 3ᵉ écran viendra ici.
  };

  # Bureaux 1 à 5 sur l'écran principal (HDMI), 6 à 8 sur l'écran secondaire (DP).
  # Le 3ᵉ écran aura les siens (9…) quand il arrivera.
  programs.niri.settings.workspaces =
    lib.genAttrs [ "1" "2" "3" "4" "5" ] (_: {
      open-on-output = "HDMI-A-1";
    })
    // lib.genAttrs [ "6" "7" "8" ] (_: {
      open-on-output = "DP-1";
    });

  # Passer d'un écran à l'autre (même logique que h j k l).
  programs.niri.settings.binds = {
    # Bureaux 6 à 8 (touches 6, 7, 8 de l'AZERTY : - è _).
    # La touche « - » servait à réduire la colonne : sur le PC, on la reprend
    # pour le bureau 6, et la taille passe sur Super + Alt + flèches.
    "Mod+Minus" = lib.mkForce { action.focus-workspace = 6; };
    "Mod+Shift+Minus" = lib.mkForce { action.move-column-to-workspace = 6; };
    "Mod+egrave".action.focus-workspace = 7;
    "Mod+Shift+egrave".action.move-column-to-workspace = 7;
    "Mod+underscore".action.focus-workspace = 8;
    "Mod+Shift+underscore".action.move-column-to-workspace = 8;

    # Taille des fenêtres sur le PC : Super + Alt + flèches.
    "Mod+Alt+Left".action.set-column-width = "-10%";
    "Mod+Alt+Right".action.set-column-width = "+10%";
    "Mod+Alt+Up".action.set-window-height = "-10%";
    "Mod+Alt+Down".action.set-window-height = "+10%";

    "Mod+Shift+H".action.focus-monitor-left = [ ];
    "Mod+Shift+L".action.focus-monitor-right = [ ];
    "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
    "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];
  };

  # ─── Carte NVIDIA ──────────────────────────────────────────────────────
  # Cache des shaders persistant (10 Go)
  home.sessionVariables = {
    __GL_SHADER_DISK_CACHE_SIZE = "10737418240";
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
  };

  # Montage vidéo (a besoin de la carte NVIDIA)
  home.packages = [ pkgs.davinci-resolve ];
}
