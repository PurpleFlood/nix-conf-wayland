# RÉSEAU DE LA MAISON : DNS local en priorité (Quad9 en secours) et certificat
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
    # NetworkManager ne réécrit pas les DNS : ce sont ceux ci-dessous qui comptent.
    networking.networkmanager.dns = "none";

    networking.nameservers = private.homeNetwork.dns ++ [
      "9.9.9.9" # secours si le serveur local ne répond pas
    ];

    # Si le serveur local ne répond pas, passe au suivant après 1 s.
    networking.resolvconf.extraOptions = [
      "timeout:1"
      "attempts:2"
    ];

    # Certificat de ton autorité interne : tes services locaux sont reconnus en HTTPS.
    security.pki.certificateFiles = private.homeNetwork.certificates;
  };
}
