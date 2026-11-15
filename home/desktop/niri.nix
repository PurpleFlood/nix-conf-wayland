# NIRI : fenêtres en colonnes sur un ruban horizontal qu'on fait défiler.
# Écrit en Nix grâce à niri-flake ; vérifié pendant le rebuild.
# Couleurs de la bordure des fenêtres : suivent le fond d'écran (matugen, voir
# theming.nix), via un fichier inclus à la fin de la config (colors.kdl).
#
# Logique des raccourcis : Mod = touche Super (Windows).
#   Mod + flèches / h j k l       se déplacer
#   Mod + Ctrl + flèches          déplacer la fenêtre
#   Mod + 1 à 5                   aller au bureau 1 à 5 (& é " ' ( en AZERTY)
{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:

let
  # Disposition du clavier : option rice.keyboard (le T470 est en QWERTY).
  keyboard = osConfig.rice.keyboard;
  ghostty = osConfig.rice.terminal == "ghostty";

  # Touches de la rangée des chiffres pour les bureaux 1 à 5.
  workspaceKeys =
    if keyboard == "fr" then
      [
        "ampersand"
        "eacute"
        "quotedbl"
        "apostrophe"
        "parenleft"
      ]
    else
      [
        "1"
        "2"
        "3"
        "4"
        "5"
      ];

  # Génère « Mod+touche → bureau n » et « Mod+Shift+touche → envoyer sur n ».
  workspaceBinds = lib.listToAttrs (
    lib.concatLists (
      lib.imap1 (n: key: [
        {
          name = "Mod+${key}";
          value.action.focus-workspace = n;
        }
        {
          name = "Mod+Shift+${key}";
          value.action.move-column-to-workspace = n;
        }
      ]) workspaceKeys
    )
  );
in
{
  # niri vient de nixpkgs (le même que le module système).
  programs.niri.package = pkgs.niri;

  programs.niri.settings = {
    input = {
      # Deux dispositions : la principale + QWERTY (jeux mal adaptés à l'AZERTY).
      # Mod+Shift+Space pour passer de l'une à l'autre.
      keyboard.xkb.layout = if keyboard == "us" then "us" else "${keyboard},us";
      touchpad = {
        tap = true; # toucher = clic
        natural-scroll = true;
      };
      focus-follows-mouse.enable = false;
    };

    # Les applis dessinent sans leur propre barre de titre : plus sobre.
    prefer-no-csd = true;

    layout = {
      gaps = 12;
      center-focused-column = "never";
      preset-column-widths = [
        { proportion = 1. / 3.; }
        { proportion = 1. / 2.; }
        { proportion = 2. / 3.; }
      ];
      default-column-width.proportion = 0.5;
      # Bordure colorée autour des fenêtres (couleurs : colors.kdl, généré par matugen).
      border.width = 2;
    };

    # Coins arrondis pour toutes les fenêtres.
    window-rules = [
      {
        geometry-corner-radius = {
          top-left = 10.0;
          top-right = 10.0;
          bottom-left = 10.0;
          bottom-right = 10.0;
        };
        clip-to-geometry = true;
      }
    ];

    # Capture intégrée : copie dans le presse-papiers ET enregistre ici.
    screenshot-path = "~/Images/Captures/%Y-%m-%d_%H-%M-%S.png";

    # Fond d'écran et couleurs remis au démarrage (le démon awww est lancé par systemd).
    spawn-at-startup = [
      { sh = "sleep 1 && wallpaper restore"; }
    ]
    # Ghostty reste chargé en arrière-plan : les fenêtres s'ouvrent instantanément.
    ++ lib.optional ghostty {
      command = [
        "systemctl"
        "--user"
        "start"
        "app-com.mitchellh.ghostty.service"
      ];
    };

    hotkey-overlay.skip-at-startup = true;

    binds = workspaceBinds // {
      # ── Applis ─────────────────────────────────────────────────────
      "Mod+Return".action.spawn =
        if ghostty then
          [
            "ghostty"
            "+new-window"
          ]
        else
          [ "foot" ];
      "Mod+D".action.spawn = "anyrun";
      "Mod+E".action.spawn-sh = "${osConfig.rice.terminalExec} yazi";
      "Mod+Shift+E".action.spawn = "thunar";
      "Mod+V".action.spawn = "clipboard-menu"; # historique (home/desktop/launcher.nix)
      "Mod+Shift+Escape".action.spawn = "power-menu";
      "Mod+Alt+L".action.spawn = "gtklock";
      "Mod+Shift+Slash".action.show-hotkey-overlay = [ ]; # aide des raccourcis
      "Mod+B".action.spawn = [
        "systemctl"
        "--user"
        "kill"
        "--signal=SIGUSR1"
        "waybar.service"
      ]; # masquer / afficher la barre

      # ── Fenêtres ───────────────────────────────────────────────────
      "Mod+Q".action.close-window = [ ];
      "Mod+F".action.maximize-column = [ ];
      "Mod+Shift+F".action.fullscreen-window = [ ];
      "Mod+R".action.switch-preset-column-width = [ ];
      "Mod+Space".action.toggle-window-floating = [ ];
      "Mod+Shift+Space".action.switch-layout = "next"; # AZERTY ↔ QWERTY
      "Mod+Tab".action.toggle-overview = [ ]; # vue d'ensemble

      "Mod+Left".action.focus-column-left = [ ];
      "Mod+Right".action.focus-column-right = [ ];
      "Mod+Up".action.focus-window-up = [ ];
      "Mod+Down".action.focus-window-down = [ ];
      "Mod+H".action.focus-column-left = [ ];
      "Mod+L".action.focus-column-right = [ ];
      "Mod+K".action.focus-window-up = [ ];
      "Mod+J".action.focus-window-down = [ ];

      "Mod+Ctrl+Left".action.move-column-left = [ ];
      "Mod+Ctrl+Right".action.move-column-right = [ ];
      "Mod+Ctrl+Up".action.move-window-up = [ ];
      "Mod+Ctrl+Down".action.move-window-down = [ ];

      # Même chose en version vim (h j k l)
      "Mod+Ctrl+H".action.move-column-left = [ ];
      "Mod+Ctrl+L".action.move-column-right = [ ];
      "Mod+Ctrl+K".action.move-window-up = [ ];
      "Mod+Ctrl+J".action.move-window-down = [ ];

      # Empiler / dépiler une fenêtre dans la colonne voisine.
      "Mod+Comma".action.consume-window-into-column = [ ];
      "Mod+Period".action.expel-window-from-column = [ ];

      # ── Bureaux (Mod + 1 à 5 : générés plus haut selon le clavier) ──
      "Mod+Page_Down".action.focus-workspace-down = [ ];
      "Mod+Page_Up".action.focus-workspace-up = [ ];

      # ── Captures d'écran ───────────────────────────────────────────
      # Intégrées à niri : sélection → presse-papiers + fichier.
      "Print".action.screenshot = [ ];
      "Mod+Print".action.screenshot-window = [ ];
      # Avec annotation : zone → satty → presse-papiers.
      "Mod+Shift+W".action.spawn = [ "wallpaper" ]; # choisir un fond d'écran (+ palette)
      "Mod+Shift+S".action.spawn-sh = ''grim -g "$(slurp)" - | satty --filename -'';

      # ── Son, luminosité, musique (avec affichage swayosd) ──────────
      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action.spawn = [
          "swayosd-client"
          "--output-volume"
          "raise"
        ];
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action.spawn = [
          "swayosd-client"
          "--output-volume"
          "lower"
        ];
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action.spawn = [
          "swayosd-client"
          "--output-volume"
          "mute-toggle"
        ];
      };
      "XF86AudioMicMute" = {
        allow-when-locked = true;
        action.spawn = [
          "swayosd-client"
          "--input-volume"
          "mute-toggle"
        ];
      };
      "XF86MonBrightnessUp".action.spawn = [
        "swayosd-client"
        "--brightness"
        "raise"
      ];
      "XF86MonBrightnessDown".action.spawn = [
        "swayosd-client"
        "--brightness"
        "lower"
      ];
      "XF86AudioPlay".action.spawn = [
        "playerctl"
        "play-pause"
      ];
      "XF86AudioNext".action.spawn = [
        "playerctl"
        "next"
      ];
      "XF86AudioPrev".action.spawn = [
        "playerctl"
        "previous"
      ];

      # ── Session ────────────────────────────────────────────────────
      "Mod+Shift+P".action.power-off-monitors = [ ];
    };
  };

  # Couleurs de niri générées par matugen : fichier inclus À LA FIN de la config,
  # pour passer après les couleurs par défaut. niri le relit tout seul quand il change.
  # (niri-flake n'a pas d'option pour `include` : on ajoute la ligne au fichier final.)
  xdg.configFile.niri-config.source = lib.mkForce (
    pkgs.runCommand "config.kdl"
      {
        config = config.programs.niri.finalConfig + ''

          // Couleurs générées par matugen (wallpaper)
          include optional=true "${config.xdg.configHome}/niri/colors.kdl"
        '';
        passAsFile = [ "config" ];
        nativeBuildInputs = [ config.programs.niri.package ];
      }
      ''
        niri validate -c $configPath
        cp $configPath $out
      ''
  );

  rice.colorTemplates.niri = {
    target = "niri/colors.kdl";
    text = ''
      // Généré par matugen (modèle dans home/desktop/niri.nix) : ne pas modifier ici.
      layout {
          border {
              active-color "{{colors.primary.default.hex}}"
              inactive-color "{{colors.outline_variant.default.hex}}"
              urgent-color "{{colors.error.default.hex}}"
          }
      }
    '';
  };
}
