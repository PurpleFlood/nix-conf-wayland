# PROFIL NIRI : ton rice. niri, waybar, anyrun, foot/Ghostty, fish, Neovim,
# Firefox réglé, Stylix. Rien ici ne demande un matériel particulier : il tourne
# partout (le R400 compris). C'est le profil par défaut.
#
#   rice.profile = "niri";          # (par défaut)
#   rice.terminal = "ghostty";
#
# Deux rices au choix pour la barre, le lanceur, les notifications, le
# verrouillage et les fonds d'écran (niri et tout le reste ne changent pas) :
#   rice.shell = "classic";         # waybar, anyrun, mako, gtklock, wallpaper (par défaut)
#   rice.shell = "noctalia";        # Noctalia (tout-en-un, réglages dans son interface)
#   rice.noctalia.enable = true;    # garde « classic », et ajoute une entrée
#                                   # « noctalia » au menu de démarrage
{
  config,
  lib,
  hmInputs,
  ...
}:

let
  enabled = config.rice.profile == "niri";
  classic = config.rice.shell == "classic";
in
{
  imports = [
    ./desktop.nix # niri, écran de connexion, verrouillage, fichiers
    ./theme.nix # Stylix
  ];

  options.rice = {
    shell = lib.mkOption {
      type = lib.types.enum [
        "classic"
        "noctalia"
      ];
      default = "classic";
      description = ''
        Rice du profil niri : « classic » (waybar, anyrun, mako, gtklock,
        commande wallpaper) ou « noctalia » (Noctalia Shell, tout-en-un).
      '';
    };

    noctalia.enable = lib.mkEnableOption ''
      une entrée « noctalia » dans le menu de démarrage (specialisation) : le même
      système avec rice.shell = "noctalia". Le démarrage normal reste « classic »
    '';

    terminal = lib.mkOption {
      type = lib.types.enum [
        "foot"
        "ghostty"
      ];
      default = "foot";
      description = ''
        Terminal du rice. foot marche partout (rendu par le processeur) ;
        Ghostty demande une carte graphique avec OpenGL 3.3.
      '';
    };

    greeterDisabledOutputs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "DP-1" ];
      description = "Écrans éteints sur l'écran de connexion (ReGreet n'apparaît que sur les autres).";
    };

    # Calculé à partir de `terminal` : à ne pas régler soi-même.
    terminalExec = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "Préfixe pour ouvrir une commande dans le terminal : \"<préfixe> yazi\".";
    };
  };

  config = lib.mkMerge [
    { rice.terminalExec = "${config.rice.terminal} -e"; }

    (lib.mkIf enabled {
      # Ton rice côté utilisateur (home/), pour la personne qui utilise le bureau.
      home-manager.users.${config.rice.user}.imports = [
        hmInputs.niri.config # option programs.niri.settings (niri-flake)
        hmInputs.niri.stylix # couleurs Stylix appliquées à niri
        ../../../home
        # Barre, lanceur, notifications : selon le rice choisi.
        (if classic then ../../../home/desktop/shell-classic.nix else ../../../home/desktop/shell-noctalia.nix)
      ];
    })

    # Entrée « noctalia » au démarrage : tout le système est construit une 2e fois,
    # avec Noctalia. Choisie dans le menu de Limine (sous chaque génération).
    (lib.mkIf (enabled && config.rice.noctalia.enable && classic) {
      specialisation.noctalia.configuration = {
        rice.shell = "noctalia";
      };
    })
  ];
}
