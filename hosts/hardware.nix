# Trouve la config matérielle d'une machine qui n'est pas encore (ou pas du tout)
# dans le dépôt. Utilisé par hosts/minimal et par une nouvelle machine tant que
# son hardware-configuration.nix n'a pas été copié dans son dossier.
#
# Ordre de recherche :
#   1. hosts/<machine>/hardware-configuration.nix (dans le dépôt) ;
#   2. la variable RICE_HARDWARE (pendant l'installation :
#      RICE_HARDWARE=/mnt/etc/nixos/hardware-configuration.nix) ;
#   3. /etc/nixos/hardware-configuration.nix (sur la machine installée).
# Les cas 2 et 3 lisent la machine : il faut ajouter `--impure` à la commande.
dir:

let
  inRepo = dir + "/hardware-configuration.nix";
  fromEnv = builtins.getEnv "RICE_HARDWARE";
in
if builtins.pathExists inRepo then
  inRepo
else if fromEnv != "" then
  /. + fromEnv
else
  /etc/nixos/hardware-configuration.nix
