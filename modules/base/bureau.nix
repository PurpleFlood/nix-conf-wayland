# BUREAU (côté système, partie de la base) : niri, écran de connexion, verrouillage, fichiers.
# Tout ce qui demande les droits root ou un service système.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  c = config.lib.stylix.colors.withHashtag; # palette Stylix (#rrggbb)

  # ── Écran de connexion : ReGreet lancé dans un mini-niri ──────────────
  # (au lieu de cage, qui étale la fenêtre sur tous les écrans et ignore
  # la disposition du clavier).
  clavier = config.rice.clavier;

  # Écrans éteints pendant la connexion : ReGreet n'apparaît que sur l'écran
  # principal. La session niri rallume ensuite tous les écrans.
  ecransEteints = config.rice.ecransConnexionEteints;

  niriConnexion = pkgs.writeText "niri-connexion.kdl" ''
    input {
        keyboard {
            xkb {
                layout "${clavier}"
            }
        }
    }
    ${lib.concatMapStrings (ecran: ''
      output "${ecran}" {
          off
      }
    '') ecransEteints}
    hotkey-overlay {
        skip-at-startup
    }
    spawn-sh-at-startup "${lib.getExe config.programs.regreet.package}; ${lib.getExe pkgs.niri} msg action quit --skip-confirmation"
  '';
in
{
  # ─── Compositeur ───────────────────────────────────────────────────────
  # Le module installe niri, les portails (partage d'écran, sélecteur de
  # fichiers…) et le trousseau. Sa configuration est dans home/bureau/niri.nix.
  programs.niri.enable = true;
  environment.systemPackages = [ pkgs.xwayland-satellite ]; # applis X11, lancé par niri

  # ─── Écran de connexion : greetd + ReGreet ─────────────────────────────
  # Au démarrage : choix de l'utilisateur et de la session, puis lance niri.
  # Couleurs, police, curseur et fond : appliqués par Stylix.
  services.greetd.settings.default_session.command =
    "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe pkgs.niri} -c ${niriConnexion}";

  programs.regreet = {
    enable = true;
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
  };

  # ─── Écran de verrouillage : gtklock ───────────────────────────────────
  # Déclenché par swayidle (home/bureau/veille.nix) ou par un raccourci niri.
  # Stylix ne gère pas gtklock : on lui passe la palette à la main.
  programs.gtklock = {
    enable = true;
    config.main = {
      time-format = "%H:%M";
    };
    modules = with pkgs; [
      gtklock-userinfo-module # photo et nom d'utilisateur
      gtklock-playerctl-module # musique en cours
    ];
    style = ''
      window {
        background-image: url("${config.stylix.image}");
        background-size: cover;
      }
      #window-box {
        background-color: alpha(${c.base00}, 0.75);
        border: 2px solid ${c.base0E};
        border-radius: 16px;
        padding: 32px;
      }
      #clock-label { color: ${c.base05}; font-size: 64px; }
      #date-label { color: ${c.base04}; }
      entry { color: ${c.base05}; background: ${c.base01}; border-radius: 8px; }
      #error-label { color: ${c.base08}; }
    '';
  };

  # ─── Fichiers : Thunar (graphique) — yazi (terminal) est dans home/ ────
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.gvfs.enable = true; # corbeille, disques, réseau dans Thunar
  services.tumbler.enable = true; # miniatures d'images

  # Règles udev de swayosd : régler la luminosité sans être root.
  services.udev.packages = [ pkgs.swayosd ];
}
