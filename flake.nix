{
  description = "The Apache Milagro (Incubating) Decentralized Trust Authority (D-TA) is a collaborative key management server.";

  inputs = {
    # Nixpkgs / NixOS version to use.
    nixpkgs.url = "nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
    
    # Upstream source tree(s).
    dta = {
      #url = "github:S-Vaes/incubator-milagro-dta";
      url = "github:apache/incubator-milagro-dta";
      flake = false;
    };

    # liboqs = {
    #   url = "github:ngi-nix/liboqs";
    #   flake = true;
    # };

    liboqs = {
      url = "github:s-vaes/liboqs/pqnist";
      flake = false;
    };
    
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
        ];
        inherit system;
      };
    in flake-utils.lib.eachDefaultSystem (system: rec {
      legacyPackages = pkgsForSystem system;

      packages = flake-utils.lib.flattenTree {
        liboqs = legacyPackages.dta.liboqs;
        pqnist = legacyPackages.dta.pqnist;
        amcl = legacyPackages.dta.amcl;
      };
      
    });
}
