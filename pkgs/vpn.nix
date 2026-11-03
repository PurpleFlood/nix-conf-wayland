# Ton script vpn (pkgs/vpn.sh, inchangé), transformé en commande `vpn`.
# Sur NixOS il n'y a pas de /usr/local/bin : on emballe le script et on lui
# donne explicitement les outils dont il a besoin dans son PATH.
{ lib, writeShellScriptBin, wireguard-tools, iputils, iproute2, gawk, gnused, findutils, coreutils, openresolv }:

writeShellScriptBin "vpn" ''
  export PATH=${lib.makeBinPath [ wireguard-tools iputils iproute2 gawk gnused findutils coreutils openresolv ]}:$PATH
  ${builtins.readFile ./vpn.sh}
''
