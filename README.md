# rice

Rice NixOS sous **Wayland**, autour de **niri**, construit d'abord dans une machine virtuelle.

## Lancer la VM

Depuis la racine du dépôt :

```
nix run .#vm
```

NixOS construit la machine et l'ouvre dans une fenêtre QEMU, sans rien installer.
L'écran de connexion ReGreet s'affiche : utilisateur `asap`, mot de passe `nixos`.

- Pour l'éteindre proprement : `Super + Shift + Échap` → Éteindre (ou `sudo poweroff` dans un terminal).
- Le dépôt est visible dans la VM, dans `/mnt/rice`.
- Le disque de la VM est `rice-vm.qcow2` (ignoré par git) : supprime-le pour repartir de zéro.

Le premier lancement est long : tout est téléchargé, et Stylix compile son petit
générateur de palette (une seule fois).

## Boucle de travail

1. Modifier la config sur ta machine.
2. Éteindre la VM, relancer `nix run .#vm` : la nouvelle config est appliquée.

## Organisation

| Fichier | Rôle |
|---|---|
| `flake.nix` | point d'entrée : sources (nixpkgs, home-manager, Stylix, niri-flake), machines |
| `hosts/vm/configuration.nix` | réglages propres à la VM (RAM, écran, 3D…) |
| `modules/base.nix` | socle : Nix, langue, utilisateur, réseau, son, Bluetooth, énergie |
| `modules/bureau.nix` | niri, écran de connexion (ReGreet), verrouillage (gtklock), Thunar |
| `modules/theme.nix` | Stylix : palette tirée de `wallpapers/fond.jpg`, police, curseur |
| `home/asap.nix` | ton utilisateur : importe tout le reste |
| `home/bureau/niri.nix` | fenêtres, raccourcis, captures |
| `home/bureau/waybar.nix` | barre |
| `home/bureau/lanceur.nix` | anyrun + menus presse-papiers et extinction |
| `home/bureau/notifications.nix` | mako |
| `home/bureau/veille.nix` | swayidle (verrouillage et écrans éteints après inactivité) |
| `home/bureau/services.nix` | fond d'écran, presse-papiers, OSD, lumière bleue, polkit, USB |
| `home/terminal.nix` | Ghostty + Nushell, starship, zoxide, carapace |
| `home/applis.nix` | yazi, satty, images, PDF, vidéo, son, Bluetooth |

## Raccourcis principaux (Super = touche Windows)

| Raccourci | Action |
|---|---|
| `Super + Entrée` | terminal (Ghostty + Nushell) |
| `Super + D` | lanceur (anyrun) |
| `Super + E` / `Super + Shift + E` | yazi / Thunar |
| `Super + V` | historique du presse-papiers |
| `Super + Q` | fermer la fenêtre |
| `Super + flèches` ou `h j k l` | se déplacer entre fenêtres |
| `Super + Ctrl + flèches` | déplacer la fenêtre |
| `Super + & é " ' (` | bureaux 1 à 5 (`+ Shift` : y envoyer la fenêtre) |
| `Super + R` | changer la largeur de la colonne (⅓, ½, ⅔) |
| `Super + F` / `Super + Shift + F` | colonne pleine largeur / plein écran |
| `Super + Tab` | vue d'ensemble |
| `Impr` / `Super + Impr` | capture zone / fenêtre (→ presse-papiers + fichier) |
| `Super + Shift + S` | capture annotée (satty) |
| `Super + Alt + L` | verrouiller |
| `Super + Shift + Échap` | menu d'extinction |
| `Super + Shift + /` | aide : tous les raccourcis |

## Changer de fond d'écran (et donc de palette)

Remplace `wallpapers/fond.jpg` par ton image (même nom), `git add`, puis relance la VM.
Stylix recalcule toutes les couleurs à partir de l'image.

## Si l'affichage de la VM ne marche pas

Si la fenêtre reste noire, remplace dans `hosts/vm/configuration.nix`
`"-device virtio-vga-gl"` et `"-display gtk,gl=on,zoom-to-fit=off"`
par `"-device virtio-vga"` et `"-display gtk"` (sans 3D : niri risque d'être lent).
