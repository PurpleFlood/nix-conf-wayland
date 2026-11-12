# ZEN : navigateur basé sur Firefox, avec les mêmes extensions, moteurs et
# réglages (home/browsers/browser-common.nix) + favoris synchronisés
# avec le dépôt. Se lance avec `zen-beta`.
#
#   rice.zen.enable = true;
{ config, lib, ... }:

let
  common = import ../home/browsers/browser-common.nix {
    searxng = config.rice.searxng.enable;
  };

  # Favoris partagés : exportés à la fermeture, réimportés au démarrage.
  bookmarks = {
    "browser.bookmarks.file" = "/home/asap/git/nix-conf-wayland/dotfiles/bookmarks.html";
    "browser.bookmarks.autoExportHTML" = true; # fermeture → écrit le fichier
    "browser.places.importBookmarksHTML" = true; # démarrage → relit le fichier
  };
in
{
  options.rice.zen.enable = lib.mkEnableOption "le navigateur Zen";

  config = lib.mkIf config.rice.zen.enable {
    home-manager.users.asap = {
      programs.zen-browser = {
        enable = true;
        # Mets `true` si tu veux que Zen ouvre les liens à la place de Firefox.
        setAsDefaultBrowser = false;

        policies = common.policies;

        profiles.asap = {
          id = 0;
          isDefault = true;
          search = common.search;
          settings =
            common.settings
            // bookmarks
            // {
              "zen.welcome-screen.seen" = true; # saute l'écran d'accueil
              "ui.systemUsesDarkTheme" = 1; # interface en sombre
              "browser.theme.toolbar-theme" = 0; # barres en sombre
              "browser.theme.content-theme" = 0; # pages internes en sombre
              "layout.css.prefers-color-scheme.content-override" = 0; # sites en sombre s'ils le gèrent
            };
        };
      };

      # Stylix ne thème pas ce navigateur : il garde son mode sombre à lui.
      stylix.targets.zen-browser.enable = false;
    };
  };
}
