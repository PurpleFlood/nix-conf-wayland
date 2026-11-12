{
  description = "Nouveau rice NixOS sous Wayland (niri) — testé d'abord en machine virtuelle";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # Version la plus récente, pour quelques paquets qui doivent être très à jour
    # (SearXNG, ani-cli…). Utilisable partout sous le nom `pkgs-unstable`.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Thème global : une palette (tirée du fond d'écran) appliquée partout.
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Navigateur Zen (pas dans nixpkgs).
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
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
      nixpkgs-unstable,
      home-manager,
      stylix,
      niri,
      zen-browser,
      ...
    }:
    let
      system = "x86_64-linux";

      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      # Fabrique une machine à partir de son dossier hosts/<nom>.
      # Toutes les machines chargent les MÊMES modules (modules/default.nix) :
      # la base est toujours active, le reste s'allume dans hosts/<nom>/configuration.nix
      # avec `rice.<module>.enable = true;`.
      mkHost =
        host:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit pkgs-unstable; };
          modules = [
            ./hosts/${host}/configuration.nix
            ./modules # base + modules optionnels
            { networking.hostName = nixpkgs.lib.mkDefault host; }
            stylix.nixosModules.stylix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-backup";
              home-manager.extraSpecialArgs = { inherit pkgs-unstable; };
              home-manager.sharedModules = [
                niri.homeModules.config # option programs.niri.settings
                niri.homeModules.stylix # couleurs Stylix appliquées à niri
                zen-browser.homeModules.beta # option programs.zen-browser
              ];
              home-manager.users.asap = import ./home/asap.nix; # le rice de base
            }
          ];
        };
    in
    {
      # Base seule, pour installer n'importe quel PC (voir hosts/minimal).
      nixosConfigurations.minimal = mkHost "minimal";
      nixosConfigurations.vm = mkHost "vm";
      nixosConfigurations.t470 = mkHost "t470";
      nixosConfigurations.pc = mkHost "pc";
      nixosConfigurations.r400 = mkHost "r400";

      # `nix run .#vm` : construit et lance la machine virtuelle, sans installation.
      apps.${system}.vm = {
        type = "app";
        program = nixpkgs.lib.getExe self.nixosConfigurations.vm.config.system.build.vm;
      };
    };
}
