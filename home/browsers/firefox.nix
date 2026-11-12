# FIREFOX : les réglages viennent de browser-common.nix (partagés avec Zen).
# Tes DONNÉES (marque-pages, historique) passent par Firefox Sync.
{ osConfig, ... }:

let
  common = import ./browser-common.nix { searxng = osConfig.rice.searxng.enable; };
in
{
  programs.firefox = {
    enable = true;
    policies = common.policies;

    profiles.asap = {
      id = 0;
      isDefault = true;
      search = common.search;
      settings = common.settings;
    };
  };

  # Stylix ne thème pas ce navigateur : il garde son mode sombre à lui (réglages ci-dessus).
  stylix.targets.firefox.enable = false;
}
