# FIREFOX : les réglages viennent de navigateur-commun.nix (partagés avec Zen).
# Tes DONNÉES (marque-pages, historique) passent par Firefox Sync.
{ osConfig, ... }:

let
  commun = import ./navigateur-commun.nix { searxng = osConfig.rice.searxng.enable; };
in
{
  programs.firefox = {
    enable = true;
    policies = commun.policies;

    profiles.asap = {
      id = 0;
      isDefault = true;
      search = commun.search;
      settings = commun.settings;
    };
  };

  # Stylix ne thème pas ce navigateur : il garde son mode sombre à lui (réglages ci-dessus).
  stylix.targets.firefox.enable = false;
}
