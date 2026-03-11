{
  description = "Colmena submodule reproducer 1";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    colmena.url = "github:zhaofengli/colmena/main";
    colmena.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }: let
    verifySubmodules = x:
      if !builtins.pathExists ./submodule/overlay.nix
      then throw ''
        This flake requires submodules to be enabled.

        Did you mean to use the following command?
          nix build '.?submodules=1'
      '' else x;

    supportedSystems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin" 
    ];

    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    mkOverlay = _system: import ./submodule/overlay.nix;

    mkShells = system:
      let 
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ 
            self.inputs.colmena.overlays.default
          ];
        };

        deploy = let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ 
              (mkOverlay system) 
              self.inputs.colmena.overlays.default
            ];
          };
        in pkgs.mkShellNoCC {
            buildInputs = [
              pkgs.colmena
              pkgs.sops
            ];
          };
      in rec {
        inherit deploy;
        default = deploy;
      };
  in {
    colmena = import ./hive.nix {
      inputs = self.inputs;
      overlay = mkOverlay "x86_64-linux";
    };
    colmenaHive = verifySubmodules (self.inputs.colmena.lib.makeHive self.outputs.colmena);
    nixosConfigurations = verifySubmodules self.outputs.colmenaHive.nodes;
    devShells = verifySubmodules (forAllSystems mkShells);
  };
}
