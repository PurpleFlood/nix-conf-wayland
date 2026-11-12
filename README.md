# nix-conf-wayland

Configuration NixOS de toutes mes machines, avec un rice **Wayland** autour de **niri**,
et un profil **simple** (Cinnamon, Plasma ou XFCE) pour les machines que je prépare à des proches.
Tout est déclaré ici : système, applis, rice, thème. Une machine se reconstruit
avec un `git clone` et une commande.

Les données personnelles (adresses du homelab, certificat, e-mail, favoris, clés SSH) sont dans
un dépôt privé séparé, branché comme une entrée de la flake. Sans y avoir accès, on construit
avec les fausses valeurs de `private-example/` :

```
nixos-rebuild build --flake .#minimal --impure --override-input private path:./private-example
```

## Machines

| Machine | Commande | Profil et modules |
|---|---|---|
| `minimal` | `sudo nixos-rebuild switch --flake .#minimal --impure` | niri seul, pour installer n'importe quel PC |
| `pc` | `sudo nixos-rebuild switch --flake .#pc` | niri + tout (NVIDIA RTX 3050, 2 écrans, Ghostty) |
| `t470` | `sudo nixos-rebuild switch --flake .#t470` | niri + apps, dev, music, virtualisation, zen, searxng, i2p, vpn, homeNetwork (QWERTY, Ghostty) |
| `r400` | `sudo nixos-rebuild switch --flake .#r400` | niri + dev (sans aiAgents), vpn, homeNetwork (Core 2 Duo, GMA 4500, BIOS) |
| `sl510` | mises à jour automatiques chaque nuit | simple (Cinnamon) + tailscale, portable prêté |
| `vm` | `nix run .#vm` | niri seul, machine virtuelle de test |

Rebuild d'une autre machine depuis le PC (elle doit être allumée, SSH actif) :
`nixos-rebuild switch --flake .#r400 --target-host asap@<ip> --sudo --ask-sudo-password`

Après un premier changement de config sur une machine, préférer
`sudo nixos-rebuild boot --flake .#<machine>` puis redémarrer : en cas de souci,
la génération précédente reste disponible dans le menu de démarrage.

Après une modification du dépôt privé (poussée sur GitHub) : `nix flake update private`,
commit du `flake.lock`, puis rebuild.

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

Trois étages, chargés sur toutes les machines :

| Chemin | Rôle |
|---|---|
| `modules/core/` | **le socle, toujours actif** : Nix, langue, comptes (admin + utilisateur), réseau, SSH, son, matériel |
| `modules/core/options.nix` | `rice.profile`, `rice.admin`, `rice.user`, `rice.keyboard` |
| `modules/profiles/niri/` | **profil niri** (par défaut) : niri, ReGreet, gtklock, Stylix + `home/` ; options `rice.terminal`, `rice.greeterDisabledOutputs` |
| `modules/profiles/simple.nix` | **profil simple** : Cinnamon / Plasma / XFCE, Firefox normal, LibreOffice, impression, Flatpak, mises à jour automatiques |
| `modules/<nom>.nix` | **un module optionnel** : tout ce qui le concerne (système ET utilisateur), éteint par défaut |

Et autour :

| Chemin | Rôle |
|---|---|
| `flake.nix` | sources (nixpkgs, unstable, home-manager, Stylix, niri-flake, Zen, dépôt privé) et liste des machines |
| `home/` | le rice côté utilisateur (profil niri) : niri, waybar, anyrun, foot/Ghostty, fish, Neovim, Firefox |
| `hosts/<machine>/` | **propre à une machine** : disques, démarrage, matériel, profil et modules (+ `home.nix` si besoin) |
| `hosts/hardware.nix` | trouve la config matérielle d'une machine pas encore dans le dépôt (installation) |
| `private-example/` | forme du dépôt privé, avec de fausses valeurs |
| `pkgs/` | paquets maison : pilote Wi-Fi Realtek du PC, commande `vpn` |
| `dotfiles/` | fichiers modifiables reliés directement (Neovim, configs de jeux) |
| `wallpapers/` | fond d'écran (source de la palette) |

### Les modules

Le profil et les modules se choisissent dans `hosts/<machine>/configuration.nix` :

```nix
rice = {
  profile = "niri"; # ou "simple"
  terminal = "ghostty"; # foot par défaut (marche partout)
  gaming.enable = true;
  music.enable = true;
};
```

| Module | Contenu |
|---|---|
| `apps` | Discord, Mumble, LibreOffice, Obsidian, Blender, Krita, Spotify, OBS, Twitch, Flatpak, AppImage… |
| `dev` | cmake, Rust, JDK, .NET, Ghidra, Ansible ; `dev.aiAgents` : Claude Code, opencode (processeur avec AVX) |
| `music` | Reaper, Bitwig, Vital, VCV Rack, Cardinal, yabridge, JACK basse latence |
| `gaming` | Steam (Proton, gamescope, NTSync), Heroic, Lutris, Prism Launcher, MangoHud |
| `vr` | WiVRn (Quest), xrizer, ALCOM, vrc-get, Unity Hub, BSManager |
| `ai` | Ollama (Vulkan), LM Studio, AnythingLLM, Heretic |
| `virtualisation` | podman, virt-manager |
| `zen` | navigateur Zen (favoris dans le dépôt privé) |
| `searxng` | moteur de recherche local (devient la recherche par défaut des navigateurs) |
| `i2p` | réseau anonyme I2P |
| `vpn` | commande `vpn` (Mullvad) + bouton dans la barre |
| `homeNetwork` | DNS local + certificat du homelab (machines qui restent à la maison) |
| `tailscale` | accès à distance, où que soit la machine |

Ajouter un paquet : dans le module qui lui correspond. Ajouter un module :
copier un module existant, changer son nom, l'ajouter à `modules/default.nix`.

### Installer une nouvelle machine

1. Depuis la clé live : partitionner, monter sur `/mnt`, `nixos-generate-config --root /mnt`,
   cloner le dépôt dans `/mnt/home/asap/git/nix-conf-wayland`, puis :
   `RICE_HARDWARE=/mnt/etc/nixos/hardware-configuration.nix nixos-install --flake .#minimal --impure`
   (BIOS : GRUB sur `/dev/sda`, ou `RICE_DISK=/dev/…` ; UEFI : systemd-boot, détecté tout seul).
   La clé live doit pouvoir lire le dépôt privé (clé SSH GitHub), sinon ajouter
   `--override-input private path:./private-example`.
2. Sur la machine installée : créer `hosts/<nom>/` (copier `hosts/r400/` ou `hosts/sl510/` comme modèle),
   y copier `/etc/nixos/hardware-configuration.nix`, choisir le profil et les modules,
   ajouter `nixosConfigurations.<nom> = mkHost "<nom>";` dans `flake.nix`, `git add`, puis
   `sudo nixos-rebuild switch --flake .#<nom>` : la machine change de nom et de config.

### Une machine pour un proche (profil simple)

- Son compte (`rice.user`) n'a pas sudo ; le compte admin (`asap`, tes clés SSH) est caché de l'écran de connexion.
- Chaque nuit, elle récupère la config sur GitHub et l'applique au redémarrage suivant.
  Pour lire le dépôt privé, `root` a besoin d'une clé de déploiement GitHub en lecture seule
  (`/root/.ssh/id_ed25519`, ajoutée dans les réglages du dépôt privé → Deploy keys).
- Dépannage : `sudo tailscale up` une fois, puis `ssh asap@<machine>` d'où que tu sois.

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
  `modules/profiles/niri/theme.nix` si le nom change), `git add -A`, rebuild, se reconnecter.
- **Favoris** (Zen) : exportés à la fermeture du navigateur dans
  le dépôt privé (`~/git/nix-private/bookmarks.html`), réimportés au démarrage. Les commiter pour les garder.
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
