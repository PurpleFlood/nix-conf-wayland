# ACTIVITYWATCH : suivi automatique du temps passé (applis, fenêtres, sites web).
# Tout reste sur la machine : ~/.local/share/activitywatch.
#
#   Tableau de bord : « ActivityWatch » dans le lanceur (http://localhost:5600)
#
# - Serveur : aw-server-rust (avec son interface web), service en arrière-plan.
# - Fenêtres + inactivité : awatcher, fait pour Wayland (niri). Le suivi des
#   fenêtres fourni avec ActivityWatch ne voit que les applis X11.
# - Sites web : extension aw-watcher-web dans Firefox et Zen
#   (home/browsers/browser-common.nix), jamais en navigation privée.
#
#   rice.activitywatch.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.rice.activitywatch.enable = lib.mkEnableOption "ActivityWatch (suivi du temps passé, en local)";

  config = lib.mkIf config.rice.activitywatch.enable {
    home-manager.users.${config.rice.user} = {
      services.activitywatch = {
        enable = true;
        package = pkgs.aw-server-rust;
      };

      # Fenêtres et inactivité : lancé avec la session graphique (il lui faut
      # Wayland), relancé s'il plante ou si le serveur n'est pas encore prêt.
      systemd.user.services.awatcher = {
        Unit = {
          Description = "ActivityWatch : fenêtres et inactivité (Wayland)";
          PartOf = [ "graphical-session.target" ];
          After = [
            "graphical-session.target"
            "activitywatch.service"
          ];
        };
        Service = {
          ExecStart = lib.getExe pkgs.awatcher;
          Restart = "always";
          RestartSec = 5;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      xdg.desktopEntries.activitywatch = {
        name = "ActivityWatch";
        comment = "Tableau de bord du temps passé";
        exec = "xdg-open http://localhost:5600";
        icon = "utilities-system-monitor";
        categories = [ "Utility" ];
      };
    };
  };
}
