{
  description = "Nouveau rice NixOS sous Wayland — banc d'essai en machine virtuelle";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";

      # Fabrique une machine à partir de son dossier hosts/<nom>.
      # Pour ajouter une machine plus tard : hosts/<nom>/ + une ligne plus bas.
      mkHost =
        host:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit host; };
          modules = [
            ./hosts/${host}/configuration.nix
            ./modules/base.nix
            ./modules/wayland.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "avant-hm";
              home-manager.extraSpecialArgs = { inherit host; };
              home-manager.users.asap = import ./home/asap.nix;
            }
          ];
        };
    in
    {
      nixosConfigurations.vm = mkHost "vm";

      # `nix run .#vm` : construit et lance la machine virtuelle, sans installation.
      apps.${system}.vm = {
        type = "app";
        program = nixpkgs.lib.getExe self.nixosConfigurations.vm.config.system.build.vm;
      };
    };
}
