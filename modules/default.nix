# TOUS LES MODULES, chargés sur toutes les machines. Trois étages :
#
# 1. core/      : le socle, toujours actif (Nix, comptes, réseau, son, matériel).
# 2. profiles/  : le bureau, un seul par machine :
#                   rice.profile = "niri";     # ton rice (par défaut)
#                   rice.profile = "simple";   # bureau classique pour débutant
# 3. les modules ci-dessous : éteints par défaut, à allumer machine par machine
#    dans hosts/<machine>/configuration.nix :
#                   rice.gaming.enable = true;
#
# Pour ajouter un paquet : le mettre dans le module qui lui correspond.
# Pour ajouter un module : créer le fichier (copier un module existant comme
# modèle) et l'ajouter à la liste ci-dessous.
{ ... }:

{
  imports = [
    ./core
    ./profiles

    # ─── Modules optionnels (rice.<nom>.enable) ───────────────────────────
    ./apps.nix # applis généralistes : Discord, LibreOffice, Blender…
    ./dev.nix # compilateurs, SDK, agents IA en terminal
    ./music.nix # DAW, plugins, audio basse latence
    ./gaming.nix # Steam, Heroic, Lutris, MangoHud…
    ./vr.nix # WiVRn (Quest), outils VRChat
    ./ai.nix # Ollama, LM Studio, AnythingLLM
    ./virtualisation.nix # podman, virt-manager
    ./zen.nix # navigateur Zen
    ./searxng.nix # moteur de recherche local
    ./i2p.nix # réseau anonyme I2P
    ./vpn.nix # commande `vpn` (Mullvad / WireGuard)
    ./home-network.nix # DNS local + certificat (réseau de la maison)
    ./tailscale.nix # accès à distance à la machine, où qu'elle soit
  ];
}
