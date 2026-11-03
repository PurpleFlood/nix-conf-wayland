# nix-conf-wayland

Configuration NixOS de toutes mes machines, avec un rice **Wayland** autour de **niri**.
Tout est déclaré ici : système, applis, rice, thème. Une machine se reconstruit
avec un `git clone` et une commande.

## Machines

| Machine | Commande | Particularités |
|---|---|---|
| `t470` | `sudo nixos-rebuild switch --flake .#t470` | ThinkPad, clavier QWERTY, Intel, deux batteries |
| `pc` | `sudo nixos-rebuild switch --flake .#pc` | PC fixe, AZERTY, NVIDIA RTX 3050, 2 écrans (bientôt 3), jeux, VR |
| `vm` | `nix run .#vm` | machine virtuelle de test (sans 3D sur un hôte NVIDIA) |

Après un premier changement de config sur une machine, préférer
`sudo nixos-rebuild boot --flake .#<machine>` puis redémarrer : en cas de souci,
la génération précédente reste disponible dans le menu Limine.

## Le rice

| Rôle | Outil |
|---|---|
| Compositeur (fenêtres, effets, écrans, raccourcis) | niri (config en Nix via niri-flake) |
| Connexion | greetd + ReGreet (dans un mini-niri : un seul écran, bon clavier) |
| Barre | waybar |
| Terminal / shell | Ghostty (en service, ouverture instantanée) + Nushell, starship, zoxide, carapace |
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
| Navigateurs | Zen et Firefox (extensions, SearXNG par défaut, favoris partagés) |

## Organisation

| Chemin | Rôle |
|---|---|
| `flake.nix` | sources (nixpkgs, unstable, home-manager, Stylix, niri-flake, Zen) et liste des machines |
| `hosts/<machine>/` | **propre à une machine** : disques, démarrage, matériel, clavier |
| `modules/` | **système, commun** : socle, bureau, thème, réseau, VPN, SearXNG, musique, outils |
| `home/` | **utilisateur, commun** : le rice et les applis |
| `home/bureau/` | niri, waybar, anyrun, mako, veille, petits services, scripts de la barre |
| `home/<machine>.nix` | réglages utilisateur propres à une machine (ex. `home/pc.nix` : écrans, jeux, VR) |
| `pkgs/` | paquets maison : pilote Wi-Fi Realtek du PC, commande `vpn` |
| `dotfiles/` | fichiers modifiables reliés directement (Neovim, favoris, configs de jeux) |
| `wallpapers/` | fond d'écran (source de la palette) |

Règle simple : **le rice et les applis dans `home/` et `modules/`**,
**les particularités de chaque machine dans `hosts/` et `home/<machine>.nix`**.

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
  `modules/theme.nix` si le nom change), `git add -A`, rebuild, se reconnecter.
- **Favoris** (Zen et Firefox) : exportés à la fermeture du navigateur dans
  `dotfiles/favoris.html`, réimportés au démarrage. Les commiter pour les garder.
- **Neovim** : config dans `dotfiles/nvim`, modifiable sans rebuild.
- **VPN** : clic sur 󰖂 dans la barre, ou `sudo vpn <pays> | off | status | list`.
  Les fichiers Mullvad restent dans `/etc/wireguard/<pays>/` (hors dépôt).
- **SearXNG** : http://localhost:8888
- **GitHub** : une seule fois par machine, `gh auth login`.
- **Paquets très récents** : `pkgs-unstable.<nom>` ; pour les mettre à jour,
  `nix flake update nixpkgs-unstable` puis rebuild.

## Nushell : les pièges

Nushell n'est pas compatible bash :
- `&&` → `;` (ou `and` dans un test) ;
- pas de `$(…)`, `export`, `VAR=x commande` ;
- pour une commande trouvée sur internet : `bash -c "…"`.

## Ménage

```
sudo nix-collect-garbage --delete-older-than 7d
sudo nixos-rebuild boot --flake .#<machine>
```
Le ménage automatique (`nix.gc`) supprime aussi chaque semaine les générations de plus de 14 jours.
