# MACHINE VIRTUELLE de test du rice.
#
# Se lance depuis la racine du dépôt avec :   nix run .#vm
# Rien à installer : NixOS construit la VM et l'ouvre dans une fenêtre QEMU.
# Le disque de la VM est le fichier ./rice-vm.qcow2 (supprime-le pour repartir de zéro).
{ lib, ... }:

{
  networking.hostName = "rice-vm";

  # ─── Réglages de la VM (appliqués seulement par `nix run .#vm`) ───────────
  virtualisation.vmVariant = {
    systemd.services.greetd.environment.WLR_RENDERER = "pixman";
    # Accès SSH depuis ton PC : ssh -p 2222 asap@localhost
    services.openssh.enable = true;
    virtualisation.forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }
    ];
    # Dans la VM : pas d'écran de connexion, niri démarre directement.
    programs.regreet.enable = lib.mkForce false;
    services.greetd.settings.default_session = {
      command = "niri-session";
      user = "asap";
    };
    virtualisation = {
      memorySize = 8192; # Mo de RAM
      cores = 4;
      diskSize = 20480; # Mo de disque
      resolution = {
        x = 1920;
        y = 1080;
      };

      # Carte graphique virtuelle avec accélération 3D (virgl) :
      # nécessaire pour niri et l'écran de connexion ReGreet.
      qemu.options = [
        "-vga none"
        "-device virtio-vga"
        "-display sdl"
      ];

      # Le dossier depuis lequel tu lances la VM (ton dépôt) est visible
      # dans la VM, dans /mnt/rice : pratique pour lire ou tester des fichiers.
      sharedDirectories.rice = {
        source = "$PWD";
        target = "/mnt/rice";
      };
    };
  };

  # ─── Pour une vraie installation plus tard (virt-manager, portable…) ──────
  # Ces lignes ne servent pas à `nix run .#vm`, mais NixOS les exige.
  # À remplacer par un hardware-configuration.nix généré lors d'une installation.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Outils invité : copier-coller, redimensionnement auto (virt-manager).
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  system.stateVersion = "26.05";
}
