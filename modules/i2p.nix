# I2P : réseau anonyme, version Java officielle (console complète, I2PSnark,
# carnet d'adresses, gestionnaire de services cachés…). Démarrée au boot.
#
# Une fois lancé (laisse-lui quelques minutes pour trouver des pairs) :
#   - console     : http://127.0.0.1:7657
#   - proxy HTTP  : 127.0.0.1:4444  (sites .i2p dans le navigateur)
#
# Les réglages faits dans la console (port, débit…) sont gardés dans
# /var/lib/i2p : ils survivent aux rebuilds, mais pas à une réinstallation.
{ ... }:

let
  # Port pour les autres routeurs I2P. À recopier dans la console :
  # Configuration → Réseau → « Port UDP » et « Port TCP ».
  portI2p = 18234;
in
{
  services.i2p.enable = true;

  networking.firewall = {
    allowedTCPPorts = [ portI2p ];
    allowedUDPPorts = [ portI2p ];
  };
}
