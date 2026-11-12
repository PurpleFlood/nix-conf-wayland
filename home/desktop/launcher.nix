# ANYRUN : lanceur d'applis, et menus grâce au plugin « stdin »
# (il affiche n'importe quelle liste fournie par un script).
{
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  plugin = name: "${pkgs.anyrun}/lib/lib${name}.so";

  # Menu « liste » : affiche l'entrée standard dans anyrun, renvoie le choice.
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
    (pkgs.writeShellScriptBin "clipboard-menu" ''
      cliphist list | ${menu} | cliphist decode | wl-copy
    '')

    # Mod+Shift+Échap ou bouton ⏻ de la barre : menu d'extinction.
    (pkgs.writeShellScriptBin "power-menu" ''
      choice=$(printf '%s\n' \
        "󰌾  Verrouiller" \
        "󰤄  Mettre en veille" \
        "󰍃  Se déconnecter" \
        "󰜉  Redémarrer" \
        "󰐥  Éteindre" | ${menu})
      case "$choice" in
        *Verrouiller*) gtklock -d ;;
        *veille*) systemctl suspend ;;
        *déconnecter*) niri msg action quit --skip-confirmation ;;
        *Redémarrer*) systemctl reboot ;;
        *Éteindre*) systemctl poweroff ;;
      esac
    '')
  ]
  # Clic sur le bouton VPN de la barre : choisir un pays ou se déconnecter
  # (seulement si le module vpn est actif).
  ++ lib.optional osConfig.rice.vpn.enable (
    pkgs.writeShellScriptBin "vpn-menu" ''
      export PATH=/run/wrappers/bin:/run/current-system/sw/bin:$PATH
      choice=$( { sudo -n vpn list; echo "Déconnecter"; } | ${menu})
      [ -z "$choice" ] && exit 0
      [ "$choice" = "Déconnecter" ] && target=off || target="$choice"
      notify-send "VPN" "$( [ "$target" = off ] && echo "Déconnexion…" || echo "Connexion : $target…" )"
      notify-send "VPN" "$(sudo -n vpn "$target" 2>&1 | tail -n 1)"
      # Met à jour le bouton de la barre tout de suite.
      systemctl --user kill --signal=SIGRTMIN+8 waybar.service
    ''
  );

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
