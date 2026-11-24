# RÉSEAU DE LA MAISON : DNS local pour tes domaines (private.homeNetwork.domains) et certificat
# de ton autorité interne, pour tes services maison en HTTPS.
# Les adresses et le certificat sont dans le dépôt privé (private.homeNetwork).
# À n'activer que sur les machines qui vivent chez toi : ailleurs, chaque
# recherche DNS attendrait d'abord ton serveur local.
#
#   rice.homeNetwork.enable = true;
{
  config,
  lib,
  private,
  ...
}:

{
  options.rice.homeNetwork.enable = lib.mkEnableOption "le DNS local et le certificat de la maison";

  config = lib.mkIf config.rice.homeNetwork.enable {
    # DNS : avec le DNS chiffré (modules/core/dns.nix, actif par défaut), seuls les
    # domaines de la maison (private.homeNetwork.domains) sont demandés à ton serveur
    # local ; tout le reste part chiffré vers Quad9 / Cloudflare.
    # Sans DNS chiffré : ton serveur local en priorité, Quad9 en secours.
    networking.networkmanager.dns = lib.mkIf (!config.rice.encryptedDns.enable) "none";
    networking.nameservers = lib.mkIf (!config.rice.encryptedDns.enable) (
      private.homeNetwork.dns
      ++ [
        "9.9.9.9" # secours si le serveur local ne répond pas
      ]
    );

    # Si le serveur local ne répond pas, passe au suivant après 1 s.
    networking.resolvconf.extraOptions = lib.mkIf (!config.rice.encryptedDns.enable) [
      "timeout:1"
      "attempts:2"
    ];

    # Certificat de ton autorité interne : tes services locaux sont reconnus en HTTPS.
    security.pki.certificateFiles = private.homeNetwork.certificates;
  };
}
