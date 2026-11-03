# rice

Nouveau rice NixOS sous **Wayland**, construit d'abord dans une machine virtuelle.

## Lancer la VM

Depuis la racine du dépôt :

```
nix run .#vm
```

NixOS construit la machine et l'ouvre dans une fenêtre QEMU, sans rien installer.
La session s'ouvre toute seule sur le terminal (utilisateur `asap`, mot de passe `nixos`).

- Le dépôt est visible dans la VM, dans `/mnt/rice`.
- Le disque de la VM est le fichier `rice-vm.qcow2` (ignoré par git).
  Supprime-le pour repartir d'une VM vierge.

## Boucle de travail

1. Modifier la config sur ta machine (`home/asap.nix`, `modules/…`).
2. Fermer la VM, puis relancer `nix run .#vm` : la nouvelle config est appliquée.

## Organisation

| Fichier | Rôle |
|---|---|
| `flake.nix` | point d'entrée, liste des machines |
| `hosts/vm/configuration.nix` | réglages propres à la VM (RAM, écran, 3D…) |
| `modules/base.nix` | socle commun : Nix, langue, utilisateur, son, réseau |
| `modules/wayland.nix` | socle Wayland ; le compositeur s'ajoutera ici |
| `home/asap.nix` | ton utilisateur : applis, dotfiles, rice |

## Si l'affichage de la VM ne marche pas

La VM utilise l'accélération 3D virtuelle (`virtio-vga-gl`). Si la fenêtre reste noire
ou si QEMU refuse de démarrer, remplace dans `hosts/vm/configuration.nix` :

```nix
"-device virtio-vga-gl"
"-display gtk,gl=on,zoom-to-fit=off"
```

par :

```nix
"-device virtio-vga"
"-display gtk"
```

(sans 3D : suffisant pour sway, moins pour Hyprland).
