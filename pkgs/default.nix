inputs: versions: _: final: rec {
  maintainers.svaes = {
    email = "sil.g.vaes@gmail.com";
    matrix = "@egyptian_cowboy:matrix";
    name = "Sil Vaes";
    github = "s-vaes";
    githubId = 8971074;
  };
  
  dta = {
    amcl = (final.callPackage ./amcl { }).overrideAttrs (oldAttrs: {
      src = inputs.amcl;
      version = versions.amcl;
    });
    liboqs = (final.callPackage ./liboqs { }).overrideAttrs (oldAttrs: {
      src = inputs.liboqs;
      version = versions.liboqs;
    });

    pqnist = (final.callPackage ./pqnist {
      liboqs = dta.liboqs;
      amcl = dta.amcl;
    }).overrideAttrs (oldAttrs: {
      repo = inputs.dta;
      version = versions.dta;
    });

    dta = (final.callPackage ./dta {
      liboqs = dta.liboqs;
      amcl = dta.amcl;
      pqnist = dta.pqnist;
    }).overrideAttrs (oldAttrs: {
      src = inputs.dta;
      version = versions.dta;
    });
  };

  # default = dta.dta;

  # devShells.default = final.callPackage ./shell.nix { };
}
