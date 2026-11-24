# SOCLE : toujours actif, sur toutes les machines, quel que soit le profil.
# Ce que toute machine de bureau doit avoir : Nix, langue, comptes, réseau,
# son, matériel, accès à distance. Aucun bureau ici : c'est le rôle des profils
# (modules/profiles/), choisis avec `rice.profile`.
{ ... }:

{
  imports = [
    ./options.nix # profil, comptes, clavier
    ./system.nix # Nix, langue, comptes, réseau, son, matériel
    ./dns.nix # DNS chiffré (DNS over HTTPS) via dnscrypt-proxy
  ];
}
