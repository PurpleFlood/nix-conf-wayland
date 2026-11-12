# nix-conf-wayland

Configuration NixOS de toutes mes machines, avec un rice **Wayland** autour de **niri**.
Tout est déclaré ici : système, applis, rice, thème. Une machine se reconstruit
avec un `git clone` et une commande.

## Machines

| Machine | Commande | Modules allumés |
|---|---|---|
| `minimal` | `sudo nixos-rebuild switch --flake .#minimal --impure` | aucun : la base seule, pour installer n'importe quel PC |
| `pc` | `sudo nixos-rebuild switch --flake .#pc` | tout (NVIDIA RTX 3050, 2 écrans, Ghostty) |
| `t470` | `sudo nixos-rebuild switch --flake .#t470` | applis, dev, musique, virtualisation, Zen, SearXNG, I2P, VPN, maison (QWERTY, Ghostty) |
| `r400` | `sudo nixos-rebuild switch --flake .#r400` | dev (sans agents IA), VPN, maison (Core 2 Duo, GMA 4500, BIOS) |
| `vm` | `nix run .#vm` | aucun : machine virtuelle de test de la base |

Rebuild d'une autre machine depuis le PC (elle doit être allumée, SSH actif) :
`nixos-rebuild switch --flake .#r400 --target-host asap@<ip> --sudo --ask-sudo-password`

Après un premier changement de config sur une machine, préférer
`sudo nixos-rebuild boot --flake .#<machine>` puis redémarrer : en cas de souci,
la génération précédente reste disponible dans le menu de démarrage.

## Le rice

| Rôle | Outil |
|---|---|
| Compositeur (fenêtres, effets, écrans, raccourcis) | niri (config en Nix via niri-flake) |
| Connexion | greetd + ReGreet (dans un mini-niri : un seul écran, bon clavier) |
| Barre | waybar |
| Terminal / shell | foot (partout) ou Ghostty (en service, ouverture instantanée) + fish, starship, zoxide, carapace |
| Lanceur et menus | anyrun (en démon) |
| Notifications | mako |
| Verrouillage / veille | gtklock + swayidle |
| Fond d'écran | awww |
| Captures | capture intégrée de niri + grim / slurp / satty |
| Presse-papiers | cliphist |
| Thème | Stylix : palette tirée du fond d'écran, JetBrains Mono, Bibata, Papirus |
| Réseau / VPN | NetworkManager (moteur iwd) + commande `vpn` (Mullvad) |
| Fichiers | yazi + Thunar |
| Son | PipeWire (+ JACK pour Reaper) + wiremix + qpwgraph |
| Volume / luminosité / lumière bleue | swayosd, wlsunset |
| Éditeur | Neovim + AstroNvim (thème propre, hors Stylix) |
| Navigateurs | Firefox (base) et Zen (module) : extensions, SearXNG par défaut s'il est actif |

## Organisation

| Chemin | Rôle |
|---|---|
| `flake.nix` | sources (nixpkgs, unstable, home-manager, Stylix, niri-flake, Zen) et liste des machines |
| `modules/base/` | **la base, toujours active** : système, réseau, son, bureau (niri, ReGreet, gtklock), thème |
| `modules/base/options.nix` | réglages par machine : `rice.clavier`, `rice.terminal`, `rice.ecransConnexionEteints` |
| `modules/<nom>.nix` | **un module optionnel** : tout ce qui le concerne (système ET utilisateur), éteint par défaut |
| `home/` | le rice de base côté utilisateur : niri, waybar, anyrun, foot/Ghostty, fish, Neovim, Firefox |
| `hosts/<machine>/` | **propre à une machine** : disques, démarrage, matériel, modules allumés (+ `home.nix` si besoin) |
| `pkgs/` | paquets maison : pilote Wi-Fi Realtek du PC, commande `vpn` |
| `dotfiles/` | fichiers modifiables reliés directement (Neovim, favoris, configs de jeux) |
| `wallpapers/` | fond d'écran (source de la palette) |

### Les modules

Chaque module s'allume dans `hosts/<machine>/configuration.nix` :

```nix
rice = {
  terminal = "ghostty"; # foot par défaut (marche partout)
  gaming.enable = true;
  musique.enable = true;
};
```

| Module | Contenu |
|---|---|
| `applis` | Discord, Mumble, LibreOffice, Obsidian, Blender, Krita, Spotify, OBS, Twitch, Flatpak, AppImage… |
| `dev` | cmake, Rust, JDK, .NET, Ghidra, Ansible ; `dev.agentsIA` : Claude Code, opencode (processeur avec AVX) |
| `musique` | Reaper, Bitwig, Vital, VCV Rack, Cardinal, yabridge, JACK basse latence |
| `gaming` | Steam (Proton, gamescope, NTSync), Heroic, Lutris, Prism Launcher, MangoHud |
| `vr` | WiVRn (Quest), xrizer, ALCOM, vrc-get, Unity Hub, BSManager |
| `ia` | Ollama (Vulkan), LM Studio, AnythingLLM, Heretic |
| `virtualisation` | podman, virt-manager |
| `zen` | navigateur Zen (favoris partagés avec le dépôt) |
| `searxng` | moteur de recherche local (devient la recherche par défaut des navigateurs) |
| `i2p` | réseau anonyme I2P |
| `vpn` | commande `vpn` (Mullvad) + bouton dans la barre |
| `maison` | DNS local + certificat Caddy (machines qui restent à la maison) |

Ajouter un paquet : dans le module qui lui correspond. Ajouter un module :
copier un module existant, changer son nom, l'ajouter à `modules/default.nix`.

### Installer une nouvelle machine

1. Depuis la clé live : partitionner, monter sur `/mnt`, `nixos-generate-config --root /mnt`,
   cloner le dépôt dans `/mnt/home/asap/git/nix-conf-wayland`, puis :
   `RICE_MATERIEL=/mnt/etc/nixos/hardware-configuration.nix nixos-install --flake .#minimal --impure`
   (BIOS : GRUB sur `/dev/sda`, ou `RICE_DISQUE=/dev/…` ; UEFI : systemd-boot, détecté tout seul).
2. Sur la machine installée : créer `hosts/<nom>/` (copier `hosts/r400/` comme modèle),
   y copier `/etc/nixos/hardware-configuration.nix`, allumer les modules voulus,
   ajouter `nixosConfigurations.<nom> = mkHost "<nom>";` dans `flake.nix`, `git add`, puis
   `sudo nixos-rebuild switch --flake .#<nom>` : la machine change de nom et de config.

## Raccourcis (Super = touche Windows)

### Applis et menus
| Raccourci | Action |
|---|---|
| `Super + Entrée` | terminal |
| `Super + D` | lanceur (applis, calculatrice, symboles, `> commande`) |
| `Super + E` / `Super + Shift + E` | yazi / Thunar |
| `Super + V` | historique du presse-papiers |
| `Super + B` | masquer / afficher la barre |
| `Super + Alt + L` | verrouiller |
| `Super + Shift + Échap` | menu d'extinction (aussi : bouton ⏻ de la barre) |
| `Super + Shift + /` | aide : tous les raccourcis |

### Fenêtres
| Raccourci | Action |
|---|---|
| `Super + Q` | fermer |
| `Super + h j k l` ou flèches | se déplacer |
| `Super + Ctrl + h j k l` ou flèches | déplacer la fenêtre |
| `Super + ,` / `Super + ;` | empiler dans la colonne voisine / dépiler |
| `Super + R` | largeur de colonne : ⅓ → ½ → ⅔ |
| `Super + F` / `Super + Shift + F` | pleine largeur / plein écran |
| `Super + Espace` | flottante / en colonne |
| `Super + Tab` | vue d'ensemble |
| T470 : `Super + - / =` (`+ Shift` : hauteur) | largeur −/+ 10 % |
| PC : `Super + Alt + ← →` / `↑ ↓` | largeur / hauteur −/+ 10 % |
| `Super + clic droit` (glisser) | redimensionner à la souris |

### Bureaux et écrans
| Raccourci | Action |
|---|---|
| T470 : `Super + 1…5` | bureaux 1 à 5 |
| PC : `Super + & é " ' (` | bureaux 1 à 5 (écran HDMI) |
| PC : `Super + - è _` | bureaux 6 à 8 (écran DP) |
| `+ Shift` sur les touches ci-dessus | y envoyer la fenêtre (y compris sur l'autre écran) |
| `Super + Page↑ / Page↓` | bureau précédent / suivant |
| PC : `Super + Shift + H / L` | écran de gauche / droite |
| PC : `Super + Shift + Ctrl + H / L` | envoyer la fenêtre sur l'écran de gauche / droite |

### Captures, son, luminosité
| Raccourci | Action |
|---|---|
| `Impr` / `Super + Impr` | capture zone / fenêtre → presse-papiers + `~/Images/Captures` |
| `Super + Shift + S` | capture annotée (satty) → presse-papiers |
| Touches volume / micro / luminosité | avec jauge à l'écran |
| Touches lecture / suivant / précédent | musique (playerctl) |
| `Super + Shift + P` | éteindre les écrans |

## Au quotidien

- **Fond d'écran / couleurs** : remplacer l'image dans `wallpapers/` (et le chemin dans
  `modules/base/theme.nix` si le nom change), `git add -A`, rebuild, se reconnecter.
- **Favoris** (Zen) : exportés à la fermeture du navigateur dans
  `dotfiles/favoris.html`, réimportés au démarrage. Les commiter pour les garder.
- **Neovim** : config dans `dotfiles/nvim`, modifiable sans rebuild.
- **VPN** : clic sur 󰖂 dans la barre, ou `sudo vpn <pays> | off | status | list`.
  Les fichiers Mullvad restent dans `/etc/wireguard/<pays>/` (hors dépôt).
- **SearXNG** (module `searxng`) : http://localhost:8889
- **GitHub** : une seule fois par machine, `gh auth login`.
- **Paquets très récents** : `pkgs-unstable.<nom>` ; pour les mettre à jour,
  `nix flake update nixpkgs-unstable` puis rebuild.

## Ménage

```
sudo nix-collect-garbage --delete-older-than 7d
sudo nixos-rebuild boot --flake .#<machine>
```
Le ménage automatique (`nix.gc`) supprime aussi chaque semaine les générations de plus de 14 jours.
