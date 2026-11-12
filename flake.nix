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

    # Tes données personnelles (IP du homelab, certificat, e-mail, favoris…),
    # dans un dépôt PRIVÉ : seul toi peux le récupérer (clé SSH GitHub).
    # Sans accès, utiliser l'exemple fourni :
    #   nixos-rebuild build --flake .#<machine> --override-input private path:./private-example
    private = {
      url = "git+ssh://git@github.com/PurpleFlood/nix-private";
      flake = false;
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
      private,
      ...
    }:
    let
      system = "x86_64-linux";

      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      # Les valeurs du dépôt privé (son default.nix), passées à tous les modules.
      privateData = import "${private}";

      # Fabrique une machine à partir de son dossier hosts/<nom>.
      # Toutes les machines chargent les MÊMES modules (modules/default.nix) :
      # le socle est toujours actif ; le profil (rice.profile) et les modules
      # (rice.<module>.enable) se choisissent dans hosts/<nom>/configuration.nix.
      mkHost =
        host:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit pkgs-unstable;
            private = privateData;
            # Modules home-manager venant d'autres flakes (utilisés par le profil niri et le module zen)
            hmInputs = {
              niri = niri.homeModules;
              zen-browser = zen-browser.homeModules;
            };
          };
          modules = [
            ./hosts/${host}/configuration.nix
            ./modules # socle + profils + modules optionnels
            { networking.hostName = nixpkgs.lib.mkDefault host; }
            stylix.nixosModules.stylix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-backup";
              home-manager.extraSpecialArgs = {
                inherit pkgs-unstable;
                private = privateData;
              };
            }
          ];
        };
    in
    {
      # Profil niri seul, pour installer n'importe quel PC (voir hosts/minimal).
      nixosConfigurations.minimal = mkHost "minimal";
      # Le portable prêté (profil simple, Cinnamon).
      nixosConfigurations.sl510 = mkHost "sl510";
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
