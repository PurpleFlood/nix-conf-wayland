# FIREFOX : les réglages viennent de browser-common.nix (partagés avec Zen).
# Tes DONNÉES (marque-pages, historique) passent par Firefox Sync.
{ config, osConfig, ... }:

let
  common = import ./browser-common.nix { searxng = osConfig.rice.searxng.enable; };
in
{
  programs.firefox = {
    enable = true;
    policies = common.policies;

    # Profil au nom de l'utilisateur (son dossier dans ~/.mozilla/firefox)
    profiles.${config.home.username} = {
      id = 0;
      isDefault = true;
      search = common.search;
      settings = common.settings;
    };
  };

  # Stylix ne thème pas ce navigateur : il garde son mode sombre à lui (réglages ci-dessus).
  stylix.targets.firefox.enable = false;
}
