{
  description = "The Apache Milagro (Incubating) Decentralized Trust Authority (D-TA) is a collaborative key management server.";

  inputs = {
    # Nixpkgs / NixOS version to use.
    nixpkgs.url = "nixpkgs/nixos-22.05";
    nixpkgs_oldgo.url = "github:NixOS/nixpkgs?rev=c83e13315caadef275a5d074243c67503c558b3b";
    
    flake-utils.url = "github:numtide/flake-utils";
    
    # Upstream source tree(s).
    dta = {
      #url = "github:S-Vaes/incubator-milagro-dta";
      url = "github:apache/incubator-milagro-dta";
      flake = false;
    };

    liboqs = {
      url = "github:open-quantum-safe/liboqs/0.2.0";
      flake = false;
    };

    # -- Need to fix current flake for amcl
    # amcl = {
    #   url = "github:ngi-nix/incubator-milagro?dir=amcl";
    #   flake = true;
    # };

    amcl = {
      url = "github:apache/incubator-milagro-crypto-c";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let      
      # Generate a user-friendly version numer.
      versions =
        let
          generateVersion = builtins.substring 0 8;
        in
          nixpkgs.lib.genAttrs
            [ "dta" "liboqs" "amcl" ]
            (n: generateVersion inputs."${n}".lastModifiedDate);

      local_overlay = import ./pkgs inputs versions;
      
      pkgsForSystem = system: import nixpkgs {
        # if you have additional overlays, you may add them here
        overlays = [
          local_overlay
          (final: prev: {
            go = inputs.nixpkgs_oldgo.legacyPackages.${prev.system}.go_1_13;
            buildGoModule = inputs.nixpkgs_oldgo.legacyPackages.${prev.system}.buildGoModule;
          })
        ];
        inherit system;
      };
    in flake-utils.lib.eachSystem [ flake-utils.lib.system.x86_64-linux ]  (system: rec {
      legacyPackages = pkgsForSystem system;

      packages = flake-utils.lib.flattenTree {
        liboqs = legacyPackages.dta.liboqs;
        pqnist = legacyPackages.dta.pqnist;
        # amcl = legacyPackages.dta.amcl;
        amcl = inputs.amcl;
        dta = legacyPackages.dta.dta;
        default = legacyPackages.dta.dta;
      };

      # Default shell
      devShells.default = legacyPackages.mkShell {
        packages = [
          legacyPackages.go
          packages.default
        ];
      };
    });
}
