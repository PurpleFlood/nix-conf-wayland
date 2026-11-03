# PC FIXE (côté utilisateur) : écrans, jeux, VR, montage vidéo.
# Importé automatiquement par home/asap.nix sur la machine « pc ».
{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  # Fichiers de config modifiables, rangés dans le dépôt (dotfiles/pc/).
  dots = "${config.home.homeDirectory}/git/nix-conf-wayland/dotfiles/pc";
  lien = chemin: config.lib.file.mkOutOfStoreSymlink "${dots}/${chemin}";
in
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

  # Bureaux 1 à 5 toujours sur l'écran principal (HDMI) ; l'écran DP garde
  # ses propres bureaux. La barre, elle, s'affiche sur tous les écrans.
  programs.niri.settings.workspaces = lib.genAttrs [ "1" "2" "3" "4" "5" ] (_: {
    open-on-output = "HDMI-A-1";
  });

  # Passer d'un écran à l'autre (même logique que h j k l).
  programs.niri.settings.binds = {
    "Mod+Shift+H".action.focus-monitor-left = [ ];
    "Mod+Shift+L".action.focus-monitor-right = [ ];
    "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
    "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];
  };

  # ─── Jeux ──────────────────────────────────────────────────────────────
  xdg.configFile = {
    "heroic/config.json".source = lien "heroic-config.json";
    "MangoHud".source = lien "MangoHud";
  };
  home.file.".local/share/PrismLauncher/prismlauncher.cfg".source = lien "prismlauncher.cfg";

  home.sessionVariables = {
    # Cache des shaders persistant (10 Go) + overlay MangoHud partout
    __GL_SHADER_DISK_CACHE_SIZE = "10737418240";
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    MANGOHUD = "1";
  };

  # ─── VR : VRChat & co → xrizer → OpenXR → WiVRn ────────────────────────
  xdg.configFile."openvr/openvrpaths.vrpath".text = builtins.toJSON {
    config = [ "${config.xdg.dataHome}/Steam/config" ];
    external_drivers = null;
    jsonid = "vrpathreg";
    log = [ "${config.xdg.dataHome}/Steam/logs" ];
    runtime = [ "${pkgs.xrizer}/lib/xrizer" ];
    version = 1;
  };
  xdg.configFile."openxr/1/active_runtime.json".source =
    "${osConfig.services.wivrn.package}/share/openxr/1/openxr_wivrn.json";

  # ─── Applis propres au PC ──────────────────────────────────────────────
  home.packages = with pkgs; [
    mangohud
    prismlauncher
    heroic
    protonplus
    protonup-rs
    davinci-resolve # montage vidéo (a besoin de la carte NVIDIA)
  ];

  programs.obs-studio.plugins = [ pkgs.obs-studio-plugins.obs-vkcapture ];
}
