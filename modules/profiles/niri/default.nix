# PROFIL NIRI : ton rice. niri, waybar, anyrun, foot/Ghostty, fish, Neovim,
# Firefox réglé, Stylix. Rien ici ne demande un matériel particulier : il tourne
# partout (le R400 compris). C'est le profil par défaut.
#
#   rice.profile = "niri";          # (par défaut)
#   rice.terminal = "ghostty";
{
  config,
  lib,
  hmInputs,
  ...
}:

let
  enabled = config.rice.profile == "niri";
in
{
  imports = [
    ./desktop.nix # niri, écran de connexion, verrouillage, fichiers
    ./theme.nix # Stylix
  ];

  options.rice = {
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
      ];
    })
  ];
}
