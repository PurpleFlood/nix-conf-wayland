# RÉGLAGES GÉNÉRAUX D'UNE MACHINE (utilisés par le socle, les profils et les modules).
# Chaque machine les règle dans son configuration.nix :
#
#   rice.profile = "simple";
#   rice.user = "marie";
#   rice.keyboard = "us";
#
# Côté home-manager, on les lit avec `osConfig.rice.…`.
{
  config,
  lib,
  private,
  ...
}:

{
  options.rice = {
    profile = lib.mkOption {
      type = lib.types.enum [
        "niri"
        "simple"
      ];
      default = "niri";
      description = ''
        Bureau de la machine :
        - "niri"   : ton rice (niri, waybar, Stylix, ton home-manager) ;
        - "simple" : un bureau classique pour débutant (Cinnamon, Plasma ou XFCE).
      '';
    };

    admin = lib.mkOption {
      type = lib.types.str;
      default = private.admin;
      defaultText = lib.literalExpression "private.admin";
      description = ''
        Compte administrateur, présent sur TOUTES les machines (sudo, SSH avec
        tes clés) : c'est par lui que tu dépannes et mets à jour à distance.
        Son nom vient du dépôt privé : chacun choisit le sien.
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = config.rice.admin;
      defaultText = lib.literalExpression "config.rice.admin";
      example = "marie";
      description = ''
        Personne qui utilise le bureau. Par défaut, toi (le compte admin).
        Sur une machine prêtée, son propre compte, sans droits d'administration.
      '';
    };

    keyboard = lib.mkOption {
      type = lib.types.str;
      default = "fr";
      example = "us";
      description = "Disposition du clavier (console, écran de connexion, bureau).";
    };
  };

  config.console.keyMap = lib.mkDefault config.rice.keyboard;
}
