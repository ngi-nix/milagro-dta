# When you use pkgs.callPackage, parameters here will be filled with packages from Nixpkgs (if there's a match)
{ lib, stdenv, buildGoModule, fetchFromGitHub, cmake, liboqs, amcl, pqnist, ... } @ args:

buildGoModule rec {
  # Specify package name and version
  pname = "milagro-dta";
  version = "0.0.1";

  # Download source code from GitHub
  src = fetchFromGitHub ({
    owner = "apache";
    repo = "incubator-milagro-dta";
    # Commit or tag, note that fetchFromGitHub cannot follow a branch!
    rev = "2c2efe10124205fee885fffa8f7dbad83fcc1050";
    # Download git submodules, most packages don't need this
    fetchSubmodules = false;
    # Don't know how to calculate the SHA256 here? Comment it out and build the package
    # Nix will raise an error and show the correct hash
    sha256 = "07qdy0zr7qz4fv1k54hwbl8n4527wx2dm7f0illwygyxzliz3r8r";
  });

  vendorSha256 = "EQ/Xa+9cX/kdM+e16ZBtgQBbswDkdtzHRmXsR+DQiIA=";

  postInstall =
    ''
    mv $out/bin/service $out/bin/milagro
    '';
  
  buildInputs = [ liboqs amcl pqnist ];
  doCheck = false;
  meta = {
    description = "The Apache Milagro (Incubating) Decentralized Trust Authority (D-TA) is a collaborative key management server.";
    homepage = https://github.com/apache/incubator-milagro-dta;
    license = lib.licenses.asl20;
    # maintainers = [ maintainers.svaes ];
  };
}
