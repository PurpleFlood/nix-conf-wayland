# ZEN : mêmes extensions, moteurs et réglages que Firefox (navigateur-commun.nix),
# plus quelques réglages propres à Zen. Se lance avec `zen-beta`.
# Nécessite le module zen-browser.homeModules.beta (branché dans flake.nix).
{ config, ... }:

let
  commun = import ./navigateur-commun.nix;

  favoris = {
    "browser.bookmarks.file" =
      "${config.home.homeDirectory}/git/nix-conf-wayland/dotfiles/favoris.html";
    "browser.bookmarks.autoExportHTML" = true; # fermeture → écrit le fichier
    "browser.places.importBookmarksHTML" = true; # démarrage → relit le fichier
  };

in
{
  programs.zen-browser = {
    enable = true;
    # Mets `true` si tu veux que Zen ouvre les liens à la place de Firefox.
    setAsDefaultBrowser = false;

    policies = commun.policies;

    profiles.asap = {
      id = 0;
      isDefault = true;
      search = commun.search // favoris;
      settings = commun.settings // {
        "zen.welcome-screen.seen" = true; # saute l'écran d'accueil
        "ui.systemUsesDarkTheme" = 1; # interface en sombre
        "browser.theme.toolbar-theme" = 0; # barres en sombre
        "browser.theme.content-theme" = 0; # pages internes en sombre
        "layout.css.prefers-color-scheme.content-override" = 0; # les sites passent en sombre s'ils le gèrent
      };
    };
  };

  # Stylix ne thème pas ce navigateur : il garde son mode sombre à lui (réglages ci-dessus).
  stylix.targets.zen-browser.enable = false;
}
