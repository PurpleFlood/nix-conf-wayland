# OUTILS SYSTÈME communs : conteneurs, machines virtuelles, Flatpak, AppImage.
{ ... }:

{
  # Conteneurs (podman, compatible docker) — podman-compose est dans home/applis.nix
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Machines virtuelles (virt-manager)
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };
  programs.virt-manager.enable = true;
  users.users.asap.extraGroups = [ "libvirtd" ];

  services.flatpak.enable = true;

  # Lancer les AppImage directement (./fichier.AppImage)
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
