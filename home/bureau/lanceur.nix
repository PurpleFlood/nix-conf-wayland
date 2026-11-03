# ANYRUN : lanceur d'applis, et menus grâce au plugin « stdin »
# (il affiche n'importe quelle liste fournie par un script).
{ pkgs, ... }:

let
  plugin = nom: "${pkgs.anyrun}/lib/lib${nom}.so";

  # Menu « liste » : affiche l'entrée standard dans anyrun, renvoie le choix.
  menu = ''${pkgs.anyrun}/bin/anyrun --plugins ${plugin "stdin"} --show-results-immediately true'';
in
{
  programs.anyrun = {
    enable = true;
    config = {
      plugins = [
        (plugin "applications") # applis installées
        (plugin "rink") # calculatrice et conversions : « 3*12 », « 5 km to mi »
        (plugin "symbols") # caractères spéciaux et emojis
        (plugin "shell") # « > commande » pour lancer une commande
      ];
      y.fraction = 0.25;
      width.fraction = 0.3;
      hidePluginInfo = true;
      closeOnClick = true;
    };
  };

  home.packages = [
    # Mod+V : choisir dans l'historique du presse-papiers.
    (pkgs.writeShellScriptBin "presse-papiers" ''
      cliphist list | ${menu} | cliphist decode | wl-copy
    '')

    # Mod+Shift+Échap ou bouton ⏻ de la barre : menu d'extinction.
    (pkgs.writeShellScriptBin "menu-extinction" ''
      choix=$(printf '%s\n' \
        "󰌾  Verrouiller" \
        "󰤄  Mettre en veille" \
        "󰍃  Se déconnecter" \
        "󰜉  Redémarrer" \
        "󰐥  Éteindre" | ${menu})
      case "$choix" in
        *Verrouiller*) gtklock -d ;;
        *veille*) systemctl suspend ;;
        *déconnecter*) niri msg action quit --skip-confirmation ;;
        *Redémarrer*) systemctl reboot ;;
        *Éteindre*) systemctl poweroff ;;
      esac
    '')
  ];
    # anyrun reste chargé en arrière-plan : il s'ouvre instantanément.
  systemd.user.services.anyrun = {
    Unit = {
      Description = "anyrun en mode démon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.anyrun}/bin/anyrun daemon";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
