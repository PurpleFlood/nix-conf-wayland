# JEUX : Steam (Proton, gamescope), Heroic, Lutris, Prism Launcher, MangoHud,
# + GeForce NOW (jeux en streaming, pour ceux dont l'anti-cheat bloque Linux).
# Les configs modifiables (MangoHud, Heroic, Prism) sont dans dotfiles/games/.
#
#   rice.gaming.enable = true;
#   rice.gaming.geforceNow = false;   # pour ne pas installer GeForce NOW
{ config, lib, pkgs, ... }:

let
  # Lien direct vers un fichier du dépôt : modifiable sans rebuild.
  link =
    path:
    pkgs.runCommandLocal (baseNameOf path) { } ''
      ln -s ${lib.escapeShellArg "/home/${config.rice.user}/git/nix-conf-wayland/dotfiles/games/${path}"} $out
    '';

  # Prism Launcher + chargeur OpenXR si la VR est active (Vivecraft → WiVRn).
  prism =
    if config.rice.vr.enable then
      pkgs.prismlauncher.override { additionalLibs = [ pkgs.openxr-loader ]; }
    else
      pkgs.prismlauncher;
in
{
  options.rice.gaming = {
    enable = lib.mkEnableOption "les jeux";

    geforceNow = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        GeForce NOW : jeux exécutés sur les serveurs de NVIDIA et diffusés en vidéo
        (Destiny 2 et autres jeux dont l'anti-cheat refuse Linux). Abonnement NVIDIA.
      '';
    };
  };

  config = lib.mkIf config.rice.gaming.enable {
    # NTSYNC : synchronisation façon Windows pour Proton (moins de saccades)
    boot.kernelModules = [ "ntsync" ];

    hardware.graphics.enable32Bit = true; # jeux 32 bits / Steam / Wine

    programs.steam = {
      enable = true;
      protontricks.enable = true;
      extraPackages = [ pkgs.gamescope ]; # gamescope utilisable dans les options de lancement
    };
    programs.gamemode.enable = true;
    programs.gamescope.enable = true;

    # ─── GeForce NOW ──────────────────────────────────────────────────────
    # NVIDIA ne le distribue qu'en Flatpak, depuis son propre dépôt. Ce service
    # l'installe 2 minutes après le démarrage (sans ralentir le boot), puis le
    # met à jour chaque semaine. Il apparaît dans le lanceur : « NVIDIA GeForce NOW ».
    # Si la fenêtre ne s'ouvre pas sous Wayland :
    #   flatpak override --user --nosocket=wayland com.nvidia.geforcenow
    services.flatpak.enable = lib.mkIf config.rice.gaming.geforceNow true;

    systemd.services.geforce-now = lib.mkIf config.rice.gaming.geforceNow {
      description = "Installation et mise à jour de GeForce NOW (Flatpak NVIDIA)";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = [ pkgs.flatpak ];
      serviceConfig.Type = "oneshot";
      script = ''
        # Flathub fournit le socle (runtime) dont l'appli a besoin
        flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        flatpak remote-add --system --if-not-exists GeForceNOW https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrepo
        flatpak install --system --noninteractive --or-update GeForceNOW com.nvidia.geforcenow
      '';
    };

    systemd.timers.geforce-now = lib.mkIf config.rice.gaming.geforceNow {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = "1w";
        Persistent = true;
      };
    };

    # ─── Côté utilisateur ─────────────────────────────────────────────────
    home-manager.users.${config.rice.user} = {
      xdg.configFile = {
        "heroic/config.json".source = link "heroic-config.json";
        "MangoHud".source = link "MangoHud";
      };
      home.file.".local/share/PrismLauncher/prismlauncher.cfg".source = link "prismlauncher.cfg";

      # Overlay MangoHud dans tous les jeux (Maj droite + F12 pour l'afficher)
      home.sessionVariables.MANGOHUD = "1";

      # Capture des jeux Vulkan dans OBS
      programs.obs-studio.plugins = [ pkgs.obs-studio-plugins.obs-vkcapture ];

      home.packages = with pkgs; [
        mangohud
        prism
        heroic
        lutris
        protonplus
        protonup-rs
      ];
    };
  };
}
