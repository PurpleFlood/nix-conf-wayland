# RÉGLAGES PAR MACHINE, utilisés par la base (système ET home-manager).
# Valeurs par défaut sûres ; chaque machine les change dans son configuration.nix :
#
#   rice.keyboard = "us";
#   rice.terminal = "ghostty";
#
# Côté home-manager, on les lit avec `osConfig.rice.…`.
{ config, lib, ... }:

{
  options.rice = {
    keyboard = lib.mkOption {
      type = lib.types.str;
      default = "fr";
      example = "us";
      description = "Disposition du clavier (console, écran de connexion et niri).";
    };

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

  config = {
    rice.terminalExec = "${config.rice.terminal} -e";

    console.keyMap = lib.mkDefault config.rice.keyboard;
  };
}
