# VIRTUALISATION : conteneurs (podman, compatible docker) et machines
# virtuelles (virt-manager / libvirt).
#
#   rice.virtualisation.enable = true;
{ config, lib, pkgs, ... }:

{
  options.rice.virtualisation.enable = lib.mkEnableOption "les conteneurs et machines virtuelles";

  config = lib.mkIf config.rice.virtualisation.enable {
    # Conteneurs
    virtualisation.podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    # Machines virtuelles
    virtualisation.libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
    programs.virt-manager.enable = true;
    users.users.${config.rice.user}.extraGroups = [ "libvirtd" ];

    environment.systemPackages = [ pkgs.podman-compose ];
  };
}
