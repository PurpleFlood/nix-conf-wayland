{
  description = "Nouveau rice NixOS sous Wayland (niri) — testé d'abord en machine virtuelle";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Thème global : une palette (tirée du fond d'écran) appliquée partout.
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pour écrire la config de niri en Nix (vérifiée pendant le rebuild).
    # On n'en prend que la partie « réglages » : niri lui-même vient de nixpkgs.
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      stylix,
      niri,
      ...
    }:
    let
      system = "x86_64-linux";

      # Fabrique une machine à partir de son dossier hosts/<nom>.
      mkHost =
        host:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit host; };
          modules = [
            ./hosts/${host}/configuration.nix
            ./modules/base.nix
            ./modules/bureau.nix
            ./modules/theme.nix
            stylix.nixosModules.stylix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "avant-hm";
              home-manager.extraSpecialArgs = { inherit host; };
              home-manager.sharedModules = [
                niri.homeModules.config # option programs.niri.settings
                niri.homeModules.stylix # couleurs Stylix appliquées à niri
              ];
              home-manager.users.asap = import ./home/asap.nix;
            }
          ];
        };
    in
    {
      nixosConfigurations.vm = mkHost "vm";
      nixosConfigurations.t470 = mkHost "t470";

      # `nix run .#vm` : construit et lance la machine virtuelle, sans installation.
      apps.${system}.vm = {
        type = "app";
        program = nixpkgs.lib.getExe self.nixosConfigurations.vm.config.system.build.vm;
      };
    };
}
