# RÉSEAU commun : DNS local en priorité (Quad9 en secours) et certificat
# de ton autorité interne (Caddy), pour tes services maison en HTTPS.
{ ... }:

{

  # Chaque machine s'annonce sur le réseau local : ssh asap@r400.local
  services.avahi = {
    enable = true;
    nssmdns4 = true; # le système sait résoudre les noms en .local
    publish = {
      enable = true;
      addresses = true;
    };
  };

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
}
