# VR : WiVRn (streaming vers le Quest 3), couche OpenVR xrizer,
# outils VRChat (ALCOM, vrc-get, Unity Hub) et BSManager (Beat Saber).
#
#   rice.vr.enable = true;
{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  options.rice.vr.enable = lib.mkEnableOption "la réalité virtuelle (WiVRn)";

  config = lib.mkIf config.rice.vr.enable {
    # Version récente (recette d'unstable) compilée avec les bibliothèques du système,
    # pour que les jeux puissent la charger (problème de glibc sinon).
    services.wivrn = {
      enable = true;
      package = pkgs.callPackage "${pkgs-unstable.path}/pkgs/by-name/wi/wivrn/package.nix" { };
      openFirewall = true;
      autoStart = true;
      highPriority = true;
      steam.importOXRRuntimes = true;
      # Couche OpenVR → OpenXR que WiVRn active à la connexion du casque
      config = {
        enable = true;
        json.openvr-compat-path = "${pkgs.xrizer}/lib/xrizer";
      };
    };

    environment.systemPackages = with pkgs; [
      pkgs-unstable.android-tools # adb, même version que celui de WiVRn
      vrc-get
      unityhub
      # ALCOM (gestion des projets VRChat), avec un correctif d'affichage
      (symlinkJoin {
        name = "alcom";
        paths = [ alcom ];
        nativeBuildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/ALCOM --set WEBKIT_DISABLE_DMABUF_RENDERER 1
        '';
      })
    ];

    home-manager.users.asap.home.packages = [ pkgs.bs-manager ];
  };
}
