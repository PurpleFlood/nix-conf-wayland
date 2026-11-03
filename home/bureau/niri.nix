# NIRI : fenêtres en colonnes sur un ruban horizontal qu'on fait défiler.
# Écrit en Nix grâce à niri-flake ; vérifié pendant le rebuild.
# Couleurs (bordure de la fenêtre active…) : appliquées par Stylix.
#
# Logique des raccourcis : Mod = touche Super (Windows).
#   Mod + flèches / h j k l       se déplacer
#   Mod + Ctrl + flèches          déplacer la fenêtre
#   Mod + & é " ' ( …             aller au bureau 1, 2, 3…
{ config, pkgs, ... }:

let
  wallpaper = config.stylix.image;
in
{
  # niri vient de nixpkgs (le même que le module système).
  programs.niri.package = pkgs.niri;

  programs.niri.settings = {
    input = {
      keyboard.xkb.layout = "fr";
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
      # Bordure colorée autour des fenêtres (couleurs actives/inactives : Stylix).
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

    # Fond d'écran posé au démarrage (le démon awww est lancé par systemd).
    spawn-at-startup = [
      { sh = "sleep 1 && awww img ${wallpaper}"; }
    ];

    hotkey-overlay.skip-at-startup = true;

    binds = {
      # ── Applis ─────────────────────────────────────────────────────
      "Mod+Return".action.spawn = "ghostty";
      "Mod+D".action.spawn = "anyrun";
      "Mod+E".action.spawn = [ "ghostty" "-e" "yazi" ];
      "Mod+Shift+E".action.spawn = "thunar";
      "Mod+V".action.spawn = "presse-papiers"; # historique (home/bureau/lanceur.nix)
      "Mod+Shift+Escape".action.spawn = "menu-extinction";
      "Mod+Alt+L".action.spawn = "gtklock";
      "Mod+Shift+Slash".action.show-hotkey-overlay = [ ]; # aide des raccourcis

      # ── Fenêtres ───────────────────────────────────────────────────
      "Mod+Q".action.close-window = [ ];
      "Mod+F".action.maximize-column = [ ];
      "Mod+Shift+F".action.fullscreen-window = [ ];
      "Mod+R".action.switch-preset-column-width = [ ];
      "Mod+Space".action.toggle-window-floating = [ ];
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

      # Empiler / dépiler une fenêtre dans la colonne voisine.
      "Mod+Comma".action.consume-window-into-column = [ ];
      "Mod+Period".action.expel-window-from-column = [ ];

      # ── Bureaux (rangée AZERTY) ────────────────────────────────────
      "Mod+ampersand".action.focus-workspace = 1;
      "Mod+eacute".action.focus-workspace = 2;
      "Mod+quotedbl".action.focus-workspace = 3;
      "Mod+apostrophe".action.focus-workspace = 4;
      "Mod+parenleft".action.focus-workspace = 5;
      "Mod+Shift+ampersand".action.move-column-to-workspace = 1;
      "Mod+Shift+eacute".action.move-column-to-workspace = 2;
      "Mod+Shift+quotedbl".action.move-column-to-workspace = 3;
      "Mod+Shift+apostrophe".action.move-column-to-workspace = 4;
      "Mod+Shift+parenleft".action.move-column-to-workspace = 5;
      "Mod+Page_Down".action.focus-workspace-down = [ ];
      "Mod+Page_Up".action.focus-workspace-up = [ ];

      # ── Captures d'écran ───────────────────────────────────────────
      # Intégrées à niri : sélection → presse-papiers + fichier.
      "Print".action.screenshot = [ ];
      "Mod+Print".action.screenshot-window = [ ];
      # Avec annotation : zone → satty → presse-papiers.
      "Mod+Shift+S".action.spawn-sh = ''grim -g "$(slurp)" - | satty --filename -'';

      # ── Son, luminosité, musique (avec affichage swayosd) ──────────
      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action.spawn = [ "swayosd-client" "--output-volume" "raise" ];
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action.spawn = [ "swayosd-client" "--output-volume" "lower" ];
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action.spawn = [ "swayosd-client" "--output-volume" "mute-toggle" ];
      };
      "XF86AudioMicMute" = {
        allow-when-locked = true;
        action.spawn = [ "swayosd-client" "--input-volume" "mute-toggle" ];
      };
      "XF86MonBrightnessUp".action.spawn = [ "swayosd-client" "--brightness" "raise" ];
      "XF86MonBrightnessDown".action.spawn = [ "swayosd-client" "--brightness" "lower" ];
      "XF86AudioPlay".action.spawn = [ "playerctl" "play-pause" ];
      "XF86AudioNext".action.spawn = [ "playerctl" "next" ];
      "XF86AudioPrev".action.spawn = [ "playerctl" "previous" ];

      # ── Session ────────────────────────────────────────────────────
      "Mod+Shift+P".action.power-off-monitors = [ ];
    };
  };
}
