# ANYRUN : lanceur d'applis, et menus grâce au plugin « stdin »
# (il affiche n'importe quelle liste fournie par un script).
# Couleurs : suivent le fond d'écran (matugen, voir theming.nix) ; le style est
# le modèle `rice.colorTemplates.anyrun` en bas du fichier.
{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  plugin = name: "${pkgs.anyrun}/lib/lib${name}.so";

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
      # Les applis lancées depuis anyrun sont ses « enfants » : sans ce réglage,
      # redémarrer anyrun (changement de fond d'écran) les fermerait toutes.
      KillMode = "process";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Style du lanceur, rempli par matugen → ~/.config/anyrun/style.css
  # (lu au démarrage d'anyrun : le démon est relancé après chaque changement).
  rice.colorTemplates.anyrun = {
    target = "anyrun/style.css";
    reload = "${pkgs.systemd}/bin/systemctl --user restart anyrun.service";
    text = ''
      /* Généré par matugen (modèle dans home/desktop/launcher.nix) : ne pas modifier ici. */
      @define-color accent {{colors.primary.default.hex}};
      @define-color bg-color {{colors.surface_container.default.hex}};
      @define-color fg-color {{colors.on_surface.default.hex}};
      @define-color desc-color {{colors.on_surface_variant.default.hex}};

      * {
        font-family: "${config.stylix.fonts.sansSerif.name}";
      }

      window {
        background: transparent;
      }

      box.main {
        padding: 5px;
        margin: 10px;
        border-radius: 12px;
        border: 2px solid @accent;
        background-color: alpha(@bg-color, 0.95);
        box-shadow: 0 0 8px rgba(0, 0, 0, 0.5);
      }

      text {
        min-height: 30px;
        padding: 5px;
        border-radius: 6px;
        color: @fg-color;
        caret-color: @accent;
      }

      .matches {
        background-color: rgba(0, 0, 0, 0);
        border-radius: 10px;
      }

      box.plugin:first-child {
        margin-top: 5px;
      }

      box.plugin.info {
        min-width: 200px;
      }

      list.plugin {
        background-color: rgba(0, 0, 0, 0);
      }

      label.match {
        color: @fg-color;
      }

      label.match.description {
        font-size: 10px;
        color: @desc-color;
      }

      label.plugin.info {
        font-size: 14px;
        color: @fg-color;
      }

      .match {
        background: transparent;
        border-radius: 6px;
      }

      .match:selected {
        border-left: 4px solid @accent;
        background: alpha(@accent, 0.12);
      }
    '';
  };
}
