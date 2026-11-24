# DNS CHIFFRÉ (toutes les machines) : les recherches de noms (youtube.com…)
# partent en HTTPS vers Quad9 et Cloudflare (DNS over HTTPS), via dnscrypt-proxy
# qui écoute en local (127.0.0.1). Personne en chemin (box, opérateur, réseau
# public) ne peut les lire ni les falsifier.
#
# Pourquoi : le DNS classique (port 53) peut être intercepté. C'est arrivé : le
# PC recevait « nom inconnu » pour tous les sites, même en demandant à Quad9.
#
# Les serveurs sont donnés avec leur adresse IP (« stamps ») : aucun besoin du
# DNS classique pour démarrer.
#
# Réseau de la maison (rice.homeNetwork) : les noms de tes domaines locaux
# (private.homeNetwork.domains) sont demandés à ton serveur DNS local.
#
# Pour revenir au DNS classique sur une machine : rice.encryptedDns.enable = false;
{
  config,
  lib,
  pkgs,
  private,
  ...
}:

let
  cfg = config.rice.encryptedDns;
  home = config.rice.homeNetwork.enable or false;
  homeDomains = private.homeNetwork.domains or [ ];
  homeDns = private.homeNetwork.dns or [ ];

  # Chaque domaine local → ton serveur DNS local (plusieurs adresses : séparées par des virgules).
  forwardingRules = pkgs.writeText "dnscrypt-forwarding-rules.txt" (
    lib.concatMapStringsSep "\n" (d: "${d} ${lib.concatStringsSep "," homeDns}") homeDomains + "\n"
  );
in
{
  options.rice.encryptedDns.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Recherches DNS chiffrées (DNS over HTTPS, Quad9 + Cloudflare) via dnscrypt-proxy.";
  };

  config = lib.mkIf cfg.enable {
    services.dnscrypt-proxy = {
      enable = true;
      upstreamDefaults = false; # config complète ci-dessous, sans listes à télécharger
      settings = {
        listen_addresses = [
          "127.0.0.1:53"
          "[::1]:53"
        ];
        server_names = [
          "quad9"
          "quad9-2"
          "cloudflare"
          "cloudflare-2"
        ];
        # DNS over HTTPS, adresse IP comprise (pas de DNS classique au démarrage).
        static = {
          quad9.stamp = "sdns://AgMAAAAAAAAABzkuOS45LjkADWRucy5xdWFkOS5uZXQKL2Rucy1xdWVyeQ";
          quad9-2.stamp = "sdns://AgMAAAAAAAAADzE0OS4xMTIuMTEyLjExMgANZG5zLnF1YWQ5Lm5ldAovZG5zLXF1ZXJ5";
          cloudflare.stamp = "sdns://AgMAAAAAAAAABzEuMS4xLjEAEmNsb3VkZmxhcmUtZG5zLmNvbQovZG5zLXF1ZXJ5";
          cloudflare-2.stamp = "sdns://AgMAAAAAAAAABzEuMC4wLjEAEmNsb3VkZmxhcmUtZG5zLmNvbQovZG5zLXF1ZXJ5";
        };
        doh_servers = true;
        dnscrypt_servers = false;
        ipv4_servers = true;
        ipv6_servers = false;
        lb_strategy = "p2"; # le plus rapide des deux meilleurs
        cache = true;
        timeout = 5000;
        ignore_system_dns = true;
        # Seulement utilisés si un serveur était donné par son nom (pas le cas ici).
        bootstrap_resolvers = [
          "9.9.9.9:53"
          "1.1.1.1:53"
        ];
      }
      // lib.optionalAttrs (home && homeDomains != [ ] && homeDns != [ ]) {
        forwarding_rules = "${forwardingRules}";
      };
    };

    # Toutes les recherches passent par dnscrypt-proxy (NetworkManager ne touche plus au DNS).
    networking.nameservers = lib.mkForce [
      "127.0.0.1"
      "::1"
    ];
    networking.networkmanager.dns = lib.mkForce "none";
  };
}
