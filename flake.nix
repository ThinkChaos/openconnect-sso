{
  inputs = {
    flake-utils.url = github:numtide/flake-utils;

    poetry2nix = {
      #url = github:nix-community/poetry2nix;
      url = github:TyberiusPrime/poetry2nix/no_setuptools;
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-github-actions.follows = "nix-github-actions";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.systems.follows = "systems";
    };


    # Unused but allows downstream to override versions and avoids duplicates

    nix-github-actions = {
      url = github:nix-community/nix-github-actions;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    systems.url = github:nix-systems/default;

    treefmt-nix = {
      url = github:numtide/treefmt-nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, poetry2nix, ... }@inputs: (inputs.flake-utils.lib.eachDefaultSystem (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      poetry2nix = inputs.poetry2nix.lib.mkPoetry2Nix { inherit pkgs; };

      openconnect-pkgs = import ./nix {
        inherit pkgs poetry2nix;
      };
    in
    {
      packages = rec {
        inherit (openconnect-pkgs) openconnect-sso;

        default = openconnect-sso;
      };

      devShells.default = openconnect-pkgs.shell;
    }
  ) // {
    overlays = rec {
      default = openconnect-sso;
      inherit (import ./nix { inherit poetry2nix; }) openconnect-sso;
    };
  });
}
