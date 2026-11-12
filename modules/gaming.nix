# JEUX : Steam (Proton, gamescope), Heroic, Lutris, Prism Launcher, MangoHud.
# Les configs modifiables (MangoHud, Heroic, Prism) sont dans dotfiles/games/.
#
#   rice.gaming.enable = true;
{ config, lib, pkgs, ... }:

let
  # Lien direct vers un fichier du dépôt : modifiable sans rebuild.
  link =
    path:
    pkgs.runCommandLocal (baseNameOf path) { } ''
      ln -s ${lib.escapeShellArg "/home/asap/git/nix-conf-wayland/dotfiles/games/${path}"} $out
    '';

  # Prism Launcher + chargeur OpenXR si la VR est active (Vivecraft → WiVRn).
  prism =
    if config.rice.vr.enable then
      pkgs.prismlauncher.override { additionalLibs = [ pkgs.openxr-loader ]; }
    else
      pkgs.prismlauncher;
in
{
  options.rice.gaming.enable = lib.mkEnableOption "les jeux";

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

    # ─── Côté utilisateur ─────────────────────────────────────────────────
    home-manager.users.asap = {
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
