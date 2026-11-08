# Réglages PARTAGÉS par Firefox et Zen (Zen est basé sur Firefox).
# Ce n'est pas un module : juste des valeurs, utilisées par firefox.nix et zen.nix.
# Change quelque chose ici → les deux navigateurs suivent.
let
  # Installe une extension depuis addons.mozilla.org, toujours à jour.
  # `id` : identifiant de l'extension, `slug` : son nom dans l'URL du site.
  extension = id: slug: {
    name = id;
    value = {
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
    };
  };

  rechercheNix = type: alias: nom: {
    name = nom;
    urls = [
      {
        template = "https://search.nixos.org/${type}";
        params = [
          {
            name = "channel";
            value = "26.05";
          }
          {
            name = "query";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    definedAliases = [ alias ];
  };
in
{
  # ─── Règles (« policies ») ─────────────────────────────────────────────
  policies = {
    ExtensionSettings = builtins.listToAttrs [
      (extension "uBlock0@raymondhill.net" "ublock-origin")
      (extension "keepassxc-browser@keepassxc.org" "keepassxc-browser")
      (extension "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" "return-youtube-dislikes")
      (extension "{446900e4-71c2-419f-a6a7-df9c091e268b}" "bitwarden-password-manager")
    ];

    DisableTelemetry = true;
    DisableFirefoxStudies = true;
    DisablePocket = true;
    DisableAppUpdate = true; # c'est Nix qui fait les mises à jour
    DontCheckDefaultBrowser = true;
    OfferToSaveLogins = false; # c'est KeePassXC qui gère les mots de passe
    PasswordManagerEnabled = false;
    FirefoxHome = {
      SponsoredTopSites = false;
      SponsoredPocket = false;
      Pocket = false;
    };
  };

  # ─── Moteurs de recherche ──────────────────────────────────────────────
  search = {
    force = true; # Nix est la référence pour les moteurs de recherche
    default = "searxng";
    privateDefault = "searxng";
    engines = {
      searxng = {
        name = "SearXNG";
        urls = [
          {
            template = "http://localhost:8889/search";
            params = [
              {
                name = "q";
                value = "{searchTerms}";
              }
            ];
          }
        ];
        definedAliases = [ "@s" ];
      };
      # « @np firefox » cherche un paquet, « @no steam » une option NixOS.
      nix-packages = rechercheNix "packages" "@np" "Paquets Nix";
      nix-options = rechercheNix "options" "@no" "Options NixOS";
      # Moteurs inutiles masqués.
      bing.metaData.hidden = true;
      ebay.metaData.hidden = true;
    };
  };

  # ─── Réglages about:config ─────────────────────────────────────────────
  settings = {
    "browser.startup.page" = 3; # rouvre les onglets de la dernière session
    "browser.aboutConfig.showWarning" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.urlbar.suggest.quicksuggest.sponsored" = false;
    "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
    "extensions.autoDisableScopes" = 0; # extensions actives sans clic
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # userChrome.css
    "media.ffmpeg.vaapi.enabled" = true; # décodage vidéo matériel
  };
}
