# SearXNG : moteur de recherche local, sur http://localhost:8888 (toutes les machines)
#
{ pkgs, pkgs-unstable, ... }:

{
  services.searx = {
    enable = true;
    package = pkgs-unstable.searxng;
    # Petit cache local (Valkey/Redis) : SearXNG est plus rapide avec.
    redisCreateLocally = true;

    settings = {
      server = {
        bind_address = "127.0.0.1"; # accessible seulement depuis ce PC
        port = 8888;
        secret_key = "jesucetoutleszboubsdepaname"; 
        limiter = false; # inutile en usage perso
        image_proxy = true; # les images passent par SearXNG (vie privée)
        outgoing.source_ips = [ "0.0.0.0" ];
      };
      search = {
        safe_search = 0;
        autocomplete = "duckduckgo";
        default_lang = "fr";
      };
      ui = {
        default_locale = "fr";
        theme_args.simple_style = "dark";
      };
    };
  };
}
