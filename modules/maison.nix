# RÉSEAU DE LA MAISON : DNS local en priorité (Quad9 en secours) et certificat
# de ton autorité interne (Caddy), pour tes services maison en HTTPS.
# À n'activer que sur les machines qui vivent chez toi : ailleurs, chaque
# recherche DNS attendrait d'abord ton serveur local.
#
#   rice.maison.enable = true;
{ config, lib, ... }:

{
  options.rice.maison.enable = lib.mkEnableOption "le DNS local et le certificat Caddy de la maison";

  config = lib.mkIf config.rice.maison.enable {
    # NetworkManager ne réécrit pas les DNS : ce sont ceux ci-dessous qui comptent.
    networking.networkmanager.dns = "none";

    networking.nameservers = [
      "192.168.1.202" # ton serveur DNS local
      "9.9.9.9" # secours si le serveur local ne répond pas
    ];

    # Si le serveur local ne répond pas, passe au suivant après 1 s.
    networking.resolvconf.extraOptions = [
      "timeout:1"
      "attempts:2"
    ];

    # Certificat de ton autorité Caddy : tes services locaux sont reconnus en HTTPS.
    security.pki.certificateFiles = [ ./certificates/caddy-root.crt ];
  };
}
